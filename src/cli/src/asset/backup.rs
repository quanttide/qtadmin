use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use chrono::{Local, NaiveDate};
use clap::Args;
use regex::Regex;
use walkdir::WalkDir;

use crate::git_utils;

#[derive(Args)]
pub struct BackupArgs {
    /// 归档 N 天前的日志（默认 3）
    #[arg(long, default_value = "3")]
    pub days: u32,

    /// 预览模式，不执行实际变更
    #[arg(long)]
    pub dry_run: bool,

    /// 仅提交不推送
    #[arg(long)]
    pub no_push: bool,

    /// 跳过确认直接执行
    #[arg(short, long)]
    pub yes: bool,
}

fn get_project_root() -> Result<PathBuf> {
    let mut current = std::env::current_dir()?;
    loop {
        let journal = current.join("docs").join("journal");
        let archive = current.join("docs").join("archive").join("journal");
        if journal.exists() && archive.exists() {
            return Ok(current);
        }
        if !current.pop() {
            return Ok(std::env::current_dir()?);
        }
    }
}

fn parse_date_from_filename(filename: &str) -> Option<NaiveDate> {
    let re = Regex::new(r"^\d{4}-\d{2}-\d{2}\.md$").unwrap();
    if !re.is_match(filename) {
        return None;
    }
    let date_str = filename.strip_suffix(".md").unwrap();
    NaiveDate::parse_from_str(date_str, "%Y-%m-%d").ok()
}

fn scan_journal_files(journal_dir: &Path) -> Result<Vec<(PathBuf, NaiveDate, String)>> {
    if !journal_dir.exists() {
        anyhow::bail!("journal 目录不存在: {}", journal_dir.display());
    }

    let mut files = Vec::new();

    for entry in WalkDir::new(journal_dir)
        .into_iter()
        .filter_entry(|e| {
            !e.file_name()
                .to_str()
                .map(|s| s.starts_with('.'))
                .unwrap_or(false)
        })
    {
        let entry = entry?;
        if !entry.file_type().is_file() {
            continue;
        }
        let name = entry.file_name().to_string_lossy().to_string();
        if !name.ends_with(".md") {
            continue;
        }

        let date = match parse_date_from_filename(&name) {
            Some(d) => d,
            None => continue,
        };

        let rel = entry.path().strip_prefix(journal_dir).unwrap();
        let category = match rel.parent() {
            Some(p) if p.as_os_str().is_empty() => "default".to_string(),
            Some(p) => p
                .components()
                .next()
                .unwrap()
                .as_os_str()
                .to_string_lossy()
                .to_string(),
            None => "default".to_string(),
        };

        files.push((entry.path().to_path_buf(), date, category));
    }

    Ok(files)
}

fn filter_old_files(
    files: Vec<(PathBuf, NaiveDate, String)>,
    days: u32,
) -> Vec<(PathBuf, NaiveDate, String)> {
    let now = Local::now().naive_local().date();
    files
        .into_iter()
        .filter(|(_, date, _)| {
            let duration = now - *date;
            duration.num_days() > days as i64
        })
        .collect()
}

fn move_files(
    files: &[(PathBuf, NaiveDate, String)],
    archive_dir: &Path,
    journal_dir: &Path,
    project_root: &Path,
    dry_run: bool,
) -> Result<Vec<(PathBuf, PathBuf)>> {
    let mut moved = Vec::new();

    for (source, _date, category) in files {
        let rel = source.strip_prefix(journal_dir).unwrap();
        let rel_parts: Vec<_> = rel.components().collect();

        let target = if rel_parts.len() > 1 {
            let sub_path: PathBuf = rel_parts[1..rel_parts.len() - 1].iter().collect();
            archive_dir.join(category).join(&sub_path).join(
                source.file_name().unwrap(),
            )
        } else {
            archive_dir.join(category).join(source.file_name().unwrap())
        };

        if target.exists() {
            println!(
                "跳过（已存在）：{}",
                target.strip_prefix(project_root).unwrap_or(&target).display()
            );
            continue;
        }

        if dry_run {
            println!(
                "[DRY-RUN] {} -> {}",
                source.strip_prefix(project_root).unwrap_or(source).display(),
                target.strip_prefix(project_root).unwrap_or(&target).display()
            );
        } else {
            if let Some(parent) = target.parent() {
                std::fs::create_dir_all(parent)?;
            }
            if let Err(e) = std::fs::rename(source, &target) {
                if e.kind() == std::io::ErrorKind::CrossesDevices {
                    std::fs::copy(source, &target)
                        .with_context(|| format!("复制文件失败: {} -> {}", source.display(), target.display()))?;
                    std::fs::remove_file(source)
                        .with_context(|| format!("删除源文件失败: {}", source.display()))?;
                } else {
                    return Err(e.into());
                }
            }
            println!(
                "已移动：{} -> {}",
                source.strip_prefix(project_root).unwrap_or(source).display(),
                target.strip_prefix(project_root).unwrap_or(&target).display()
            );
        }

        moved.push((source.clone(), target));
    }

    Ok(moved)
}

pub fn run(args: &BackupArgs) {
    let project_root = get_project_root().unwrap_or_else(|e| {
        eprintln!("错误：{e}");
        std::process::exit(1);
    });
    let journal_dir = project_root.join("docs").join("journal");
    let archive_dir = project_root.join("docs").join("archive").join("journal");

    println!("项目根目录：{}", project_root.display());
    println!("Journal 目录：{}", journal_dir.display());
    println!("Archive 目录：{}", archive_dir.display());
    println!("归档条件：{} 天前\n", args.days);

    let all_files = scan_journal_files(&journal_dir).unwrap_or_else(|e| {
        eprintln!("错误：{e}");
        std::process::exit(1);
    });
    println!("扫描到 {} 个日志文件", all_files.len());

    let old_files = filter_old_files(all_files, args.days);
    if old_files.is_empty() {
        println!("没有 {} 天前的日志需要归档。", args.days);
        return;
    }

    if !args.dry_run && !args.yes {
        println!("\n共找到 {} 个待归档文件：", old_files.len());
        for (_path, date, category) in &old_files {
            println!(
                "  {} [{}] {}",
                date,
                category,
                _path.file_name().unwrap().to_string_lossy()
            );
        }
        println!("\n确认执行归档？[y/N]");
        let mut input = String::new();
        std::io::stdin().read_line(&mut input).unwrap();
        if input.trim().to_lowercase() != "y" {
            println!("已取消。");
            return;
        }
    }

    println!("\n开始归档...");
    let moved = move_files(&old_files, &archive_dir, &journal_dir, &project_root, args.dry_run)
        .unwrap_or_else(|e| {
            eprintln!("错误：{e}");
            std::process::exit(1);
        });

    if args.dry_run {
        println!("\n[DRY-RUN] 共 {} 个文件将被归档。", moved.len());
        return;
    }

    if moved.is_empty() {
        println!("没有文件被移动。");
        return;
    }

    println!("\n提交子模块变更...");
    let commit_message = format!("archive: backup journal logs older than {} days", args.days);
    let push = !args.no_push;

    if let Err(e) = git_utils::commit_and_push(&journal_dir, &commit_message, push) {
        eprintln!("子模块提交失败：{e}");
    }
    if let Err(e) = git_utils::commit_and_push(&archive_dir, &commit_message, push) {
        eprintln!("子模块提交失败：{e}");
    }

    println!("\n更新主仓库子模块引用...");
    if let Err(e) = git_utils::update_submodule_in_main_repo(
        &project_root,
        "journal",
        &format!("Update journal submodule: {commit_message}"),
        push,
    ) {
        eprintln!("主仓库提交失败：{e}");
    }
    if let Err(e) = git_utils::update_submodule_in_main_repo(
        &project_root,
        "archive",
        &format!("Update archive submodule: {commit_message}"),
        push,
    ) {
        eprintln!("主仓库提交失败：{e}");
    }

    println!("\n归档完成！");
}
