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

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::NaiveDate;
    use std::fs;

    #[test]
    fn test_parse_date_from_filename_valid() {
        assert_eq!(
            parse_date_from_filename("2024-01-15.md"),
            NaiveDate::from_ymd_opt(2024, 1, 15)
        );
        assert_eq!(
            parse_date_from_filename("2024-12-31.md"),
            NaiveDate::from_ymd_opt(2024, 12, 31)
        );
    }

    #[test]
    fn test_parse_date_from_filename_invalid() {
        assert_eq!(parse_date_from_filename("invalid.md"), None);
        assert_eq!(parse_date_from_filename("2024-13-01.md"), None);
        assert_eq!(parse_date_from_filename("2024-02-30.md"), None);
        assert_eq!(parse_date_from_filename("not-a-date.txt"), None);
        assert_eq!(parse_date_from_filename(""), None);
        assert_eq!(parse_date_from_filename(".md"), None);
    }

    #[test]
    fn test_parse_date_from_filename_format() {
        assert_eq!(parse_date_from_filename("2024-1-15.md"), None);
        assert_eq!(parse_date_from_filename("24-01-15.md"), None);
        assert_eq!(parse_date_from_filename("2024-01-15.txt"), None);
        assert_eq!(parse_date_from_filename("journal-2024-01-15.md"), None);
    }

    #[test]
    fn test_filter_old_files_by_days() {
        let now = Local::now().naive_local().date();
        let files = vec![
            (PathBuf::from("a.md"), now - chrono::Duration::days(5), "work".to_string()),
            (PathBuf::from("b.md"), now - chrono::Duration::days(2), "work".to_string()),
            (PathBuf::from("c.md"), now - chrono::Duration::days(10), "work".to_string()),
        ];

        let result = filter_old_files(files, 3);
        assert_eq!(result.len(), 2);
        assert_eq!(result[0].0, PathBuf::from("a.md"));
        assert_eq!(result[1].0, PathBuf::from("c.md"));
    }

    #[test]
    fn test_filter_old_files_no_old() {
        let now = Local::now().naive_local().date();
        let files = vec![
            (PathBuf::from("a.md"), now - chrono::Duration::hours(1), "work".to_string()),
            (PathBuf::from("b.md"), now, "work".to_string()),
        ];

        let result = filter_old_files(files, 1);
        assert_eq!(result.len(), 0);
    }

    #[test]
    fn test_filter_old_files_all_old() {
        let now = Local::now().naive_local().date();
        let files = vec![
            (PathBuf::from("a.md"), now - chrono::Duration::days(10), "work".to_string()),
            (PathBuf::from("b.md"), now - chrono::Duration::days(20), "work".to_string()),
        ];

        let result = filter_old_files(files, 3);
        assert_eq!(result.len(), 2);
    }

    #[test]
    fn test_scan_journal_files_empty_dir() {
        let dir = tempfile::tempdir().unwrap();
        let result = scan_journal_files(dir.path()).unwrap();
        assert!(result.is_empty());
    }

    #[test]
    fn test_scan_journal_files_nonexistent() {
        let result = scan_journal_files(Path::new("/nonexistent/path"));
        assert!(result.is_err());
    }

    #[test]
    fn test_scan_journal_files_with_files() {
        let dir = tempfile::tempdir().unwrap();
        let journal = dir.path().join("docs").join("journal");
        fs::create_dir_all(&journal).unwrap();

        fs::write(journal.join("2024-01-15.md"), "content").unwrap();
        fs::write(journal.join("2024-01-16.md"), "content").unwrap();

        let files = scan_journal_files(&journal).unwrap();
        assert_eq!(files.len(), 2);
        assert_eq!(files[0].2, "default");
        assert_eq!(files[1].2, "default");
    }

    #[test]
    fn test_scan_journal_files_nested() {
        let dir = tempfile::tempdir().unwrap();
        let journal = dir.path().join("docs").join("journal");
        fs::create_dir_all(journal.join("qtclass").join("train")).unwrap();
        fs::create_dir_all(journal.join("default")).unwrap();

        fs::write(
            journal.join("qtclass").join("train").join("2024-01-15.md"),
            "content",
        )
        .unwrap();
        fs::write(
            journal.join("default").join("2024-01-16.md"),
            "content",
        )
        .unwrap();

        let files = scan_journal_files(&journal).unwrap();
        assert_eq!(files.len(), 2);

        let qtclass: Vec<_> = files.iter().filter(|(_, _, c)| c == "qtclass").collect();
        assert_eq!(qtclass.len(), 1);
    }

    #[test]
    fn test_scan_journal_files_skip_hidden() {
        let dir = tempfile::tempdir().unwrap();
        let journal = dir.path().join("docs").join("journal");
        fs::create_dir_all(&journal).unwrap();

        fs::write(journal.join(".hidden.md"), "content").unwrap();

        let files = scan_journal_files(&journal).unwrap();
        assert!(files.is_empty());
    }

    #[test]
    fn test_scan_journal_files_skip_non_date() {
        let dir = tempfile::tempdir().unwrap();
        let journal = dir.path().join("docs").join("journal");
        fs::create_dir_all(&journal).unwrap();

        fs::write(journal.join("readme.md"), "content").unwrap();

        let files = scan_journal_files(&journal).unwrap();
        assert!(files.is_empty());
    }

    #[test]
    fn test_scan_journal_files_default_category() {
        let dir = tempfile::tempdir().unwrap();
        let journal = dir.path().join("docs").join("journal");
        fs::create_dir_all(&journal).unwrap();

        fs::write(journal.join("2024-01-15.md"), "content").unwrap();

        let files = scan_journal_files(&journal).unwrap();
        assert_eq!(files.len(), 1);
        assert_eq!(files[0].2, "default");
    }

    #[test]
    fn test_move_files_success() {
        let dir = tempfile::tempdir().unwrap();
        let project_root = dir.path();
        let journal_dir = project_root.join("docs").join("journal");
        let archive_dir = project_root.join("docs").join("archive").join("journal");

        fs::create_dir_all(journal_dir.join("work")).unwrap();
        let source = journal_dir.join("work").join("2024-01-15.md");
        fs::write(&source, "content").unwrap();

        let files = vec![(source.clone(), NaiveDate::from_ymd_opt(2024, 1, 15).unwrap(), "work".to_string())];

        let moved = move_files(&files, &archive_dir, &journal_dir, project_root, false).unwrap();
        assert_eq!(moved.len(), 1);
        assert!(!source.exists());
        assert!(moved[0].1.exists());
        assert_eq!(fs::read_to_string(&moved[0].1).unwrap(), "content");
    }

    #[test]
    fn test_move_files_dry_run() {
        let dir = tempfile::tempdir().unwrap();
        let project_root = dir.path();
        let journal_dir = project_root.join("docs").join("journal");
        let archive_dir = project_root.join("docs").join("archive").join("journal");

        fs::create_dir_all(journal_dir.join("work")).unwrap();
        let source = journal_dir.join("work").join("2024-01-15.md");
        fs::write(&source, "content").unwrap();

        let files = vec![(source.clone(), NaiveDate::from_ymd_opt(2024, 1, 15).unwrap(), "work".to_string())];

        let moved = move_files(&files, &archive_dir, &journal_dir, project_root, true).unwrap();
        assert_eq!(moved.len(), 1);
        assert!(source.exists());
        // target should not exist in dry-run
        assert!(!moved[0].1.exists());
    }

    #[test]
    fn test_move_files_skip_existing() {
        let dir = tempfile::tempdir().unwrap();
        let project_root = dir.path();
        let journal_dir = project_root.join("docs").join("journal");
        let archive_dir = project_root.join("docs").join("archive").join("journal");

        fs::create_dir_all(journal_dir.join("work")).unwrap();
        fs::create_dir_all(archive_dir.join("work")).unwrap();

        let source = journal_dir.join("work").join("2024-01-15.md");
        fs::write(&source, "content").unwrap();
        let target = archive_dir.join("work").join("2024-01-15.md");
        fs::write(&target, "existing").unwrap();

        let files = vec![(source, NaiveDate::from_ymd_opt(2024, 1, 15).unwrap(), "work".to_string())];

        let moved = move_files(&files, &archive_dir, &journal_dir, project_root, false).unwrap();
        assert_eq!(moved.len(), 0);
    }

    #[test]
    fn test_move_files_nested_structure() {
        let dir = tempfile::tempdir().unwrap();
        let project_root = dir.path();
        let journal_dir = project_root.join("docs").join("journal");
        let archive_dir = project_root.join("docs").join("archive").join("journal");

        fs::create_dir_all(journal_dir.join("qtclass").join("train")).unwrap();
        let source = journal_dir.join("qtclass").join("train").join("2024-01-15.md");
        fs::write(&source, "content").unwrap();

        let files = vec![(source.clone(), NaiveDate::from_ymd_opt(2024, 1, 15).unwrap(), "qtclass".to_string())];

        let moved = move_files(&files, &archive_dir, &journal_dir, project_root, false).unwrap();
        assert_eq!(moved.len(), 1);

        let expected = archive_dir.join("qtclass").join("train").join("2024-01-15.md");
        assert!(expected.exists());
        assert_eq!(moved[0].1, expected);
    }
}
