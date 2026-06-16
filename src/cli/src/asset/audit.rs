use std::path::{Path, PathBuf};

use clap::Args;
use regex::Regex;

use crate::git_utils;

#[derive(Args)]
pub struct AuditArgs {
    /// 要审计的 Git 仓库路径
    #[arg(default_value = ".")]
    pub repo_path: String,

    /// 显示所有通过的项目
    #[arg(short, long)]
    pub verbose: bool,
}

#[derive(Debug)]
pub struct AuditResult {
    pub name: String,
    pub passed: bool,
    pub message: String,
    pub suggestion: Option<String>,
}

pub struct AuditReport {
    pub repo_path: String,
    pub results: Vec<AuditResult>,
}

impl AuditReport {
    pub fn passed_count(&self) -> usize {
        self.results.iter().filter(|r| r.passed).count()
    }

    pub fn failed_count(&self) -> usize {
        self.results.iter().filter(|r| !r.passed).count()
    }

    pub fn total_count(&self) -> usize {
        self.results.len()
    }

    pub fn pass_rate(&self) -> f64 {
        if self.results.is_empty() {
            return 0.0;
        }
        self.passed_count() as f64 / self.total_count() as f64 * 100.0
    }

    pub fn print_report(&self, verbose: bool) -> bool {
        println!();
        println!("{}", "=".repeat(60));
        println!("Git 仓库资产审计报告");
        println!("{}", "=".repeat(60));
        println!("仓库路径：{}", self.repo_path);
        println!(
            "审计结果：{}/{} 通过 ({:.1}%)",
            self.passed_count(),
            self.total_count(),
            self.pass_rate()
        );
        println!("{}", "-".repeat(60));

        let failed: Vec<_> = self.results.iter().filter(|r| !r.passed).collect();
        if !failed.is_empty() {
            println!("\n❌ 未通过项目:");
            for result in &failed {
                println!("\n  [{}]", result.name);
                println!("  {}", result.message);
                if let Some(suggestion) = &result.suggestion {
                    println!("  💡 建议：{suggestion}");
                }
            }
        }

        if verbose {
            let passed: Vec<_> = self.results.iter().filter(|r| r.passed).collect();
            if !passed.is_empty() {
                println!("\n✅ 通过项目:");
                for result in &passed {
                    println!("  ✓ {}", result.name);
                }
            }
        }

        println!("\n{}", "=".repeat(60));

        if self.failed_count() > 0 {
            println!("⚠️  审计未通过，请根据建议修复问题");
            false
        } else {
            println!("✅ 审计通过，仓库符合标准资产体系规范");
            true
        }
    }
}

pub struct GitRepoAuditor {
    pub repo_path: PathBuf,
    results: Vec<AuditResult>,
}

impl GitRepoAuditor {
    const REQUIRED_FILES: &'static [(&'static str, &'static str)] = &[
        ("README.md", "项目概述、目录结构"),
        ("CONTRIBUTING.md", "贡献指南、工作流、环境变量"),
        ("AGENTS.md", "Agent 导航"),
        ("CHANGELOG.md", "版本历史"),
        (".gitignore", "Git 忽略规则"),
    ];

    const OPTIONAL_DIRS: &'static [(&'static str, &'static str)] =
        &[("meta", "元数据目录")];

    pub fn new(repo_path: &str) -> Self {
        Self {
            repo_path: PathBuf::from(repo_path).canonicalize().unwrap_or_else(|_| {
                PathBuf::from(repo_path)
            }),
            results: Vec::new(),
        }
    }

    pub fn audit(&mut self) -> AuditReport {
        if !self.repo_path.exists() {
            eprintln!("错误：路径不存在 - {}", self.repo_path.display());
            std::process::exit(1);
        }

        if !self.repo_path.join(".git").exists() {
            eprintln!("错误：不是 Git 仓库 - {}", self.repo_path.display());
            std::process::exit(1);
        }

        self.check_required_files();
        self.check_optional_dirs();
        self.check_readme_content();
        self.check_contributing_content();
        self.check_agents_content();
        self.check_changelog_format();
        self.check_gitignore_content();
        self.check_submodules();
        self.check_recent_commits();
        self.check_release_consistency();

        AuditReport {
            repo_path: self.repo_path.display().to_string(),
            results: std::mem::take(&mut self.results),
        }
    }

    fn add_result(&mut self, result: AuditResult) {
        self.results.push(result);
    }

    fn read_file(&self, path: &Path) -> Option<String> {
        std::fs::read_to_string(path).ok()
    }

    fn check_required_files(&mut self) {
        for (filename, description) in Self::REQUIRED_FILES {
            let file_path = self.repo_path.join(filename);
            let passed = file_path.exists();
            self.add_result(AuditResult {
                name: format!("必需文件：{filename}"),
                passed,
                message: if passed {
                    format!("{filename} - {description}")
                } else {
                    format!("缺少 {filename}")
                },
                suggestion: if !passed {
                    Some(format!("创建 {filename} 文件"))
                } else {
                    None
                },
            });
        }
    }

    fn check_optional_dirs(&mut self) {
        for (dirname, description) in Self::OPTIONAL_DIRS {
            let dir_path = self.repo_path.join(dirname);
            let passed = dir_path.exists() && dir_path.is_dir();
            self.add_result(AuditResult {
                name: format!("可选目录：{dirname}/"),
                passed,
                message: if passed {
                    format!("{dirname}/ - {description}")
                } else {
                    format!("缺少 {dirname}/ 目录")
                },
                suggestion: if !passed {
                    Some(format!("考虑创建 {dirname}/ 目录用于存储元数据"))
                } else {
                    None
                },
            });
        }
    }

    fn check_readme_content(&mut self) {
        let readme_path = self.repo_path.join("README.md");
        let content = match self.read_file(&readme_path) {
            Some(c) => c,
            None => return,
        };

        let lines: Vec<&str> = content.lines().collect();
        let has_intro = lines.first().map(|l| l.replace('#', "").trim().len() > 0).unwrap_or(false);
        let has_structure = content.contains("目录") || content.contains("结构") || content.contains("```");
        let has_quickstart = content.contains("快速")
            || content.contains("开始")
            || content.contains("Quick")
            || content.contains("Start")
            || content.contains("开始使用");

        let passed = has_intro && (has_structure || has_quickstart);
        self.add_result(AuditResult {
            name: "README.md 内容规范".to_string(),
            passed,
            message: if passed {
                "包含项目简介、目录结构、快速开始".to_string()
            } else {
                "内容不完整".to_string()
            },
            suggestion: if !passed {
                Some("添加项目简介、目录结构和快速开始指南".to_string())
            } else {
                None
            },
        });
    }

    fn check_contributing_content(&mut self) {
        let contrib_path = self.repo_path.join("CONTRIBUTING.md");
        let content = match self.read_file(&contrib_path) {
            Some(c) => c,
            None => return,
        };

        let required = [
            ("项目结构", &["结构", "目录", "Project Structure"] as &[&str]),
            ("开发环境", &["开发", "环境", "Environment", "Setup"]),
            ("提交规范", &["提交", "Commit", "规范"]),
            ("发布流程", &["发布", "Release", "版本"]),
        ];

        let mut missing = Vec::new();
        for (section_name, keywords) in &required {
            let has = keywords.iter().any(|kw| content.contains(kw));
            if !has {
                missing.push(*section_name);
            }
        }

        let passed = missing.is_empty();
        self.add_result(AuditResult {
            name: "CONTRIBUTING.md 内容规范".to_string(),
            passed,
            message: if passed {
                "包含项目结构、开发环境、提交规范、发布流程".to_string()
            } else {
                format!("缺少章节：{}", missing.join(", "))
            },
            suggestion: if !passed {
                Some(format!("添加缺失的章节：{}", missing.join(", ")))
            } else {
                None
            },
        });
    }

    fn check_agents_content(&mut self) {
        let agents_path = self.repo_path.join("AGENTS.md");
        let content = match self.read_file(&agents_path) {
            Some(c) => c,
            None => return,
        };

        let line_count = content.lines().count();
        let is_concise = line_count <= 50;
        let has_table = content.contains('|') && content.contains("---");
        let has_index = content.contains("索引")
            || content.contains("Index")
            || content.contains("README")
            || content.contains("CONTRIBUTING");
        let has_self_update = (content.contains("更新") && content.contains("AGENTS"))
            || (content.contains("维护") && content.contains("AGENTS"))
            || content.to_lowercase().contains("self-update")
            || content.to_lowercase().contains("how to update");

        let passed = is_concise && (has_table || has_index) && has_self_update;
        self.add_result(AuditResult {
            name: "AGENTS.md 内容规范".to_string(),
            passed,
            message: if passed {
                format!("简洁 ({line_count}行)，包含使用场景、快速索引和自我更新说明")
            } else {
                format!("需要优化 (共{line_count}行)")
            },
            suggestion: if !passed {
                Some("保持简洁 (~50 行)，添加使用场景表格、快速索引，以及「如何更新 AGENTS.md」的说明".to_string())
            } else {
                None
            },
        });
    }

    fn check_changelog_format(&mut self) {
        let changelog_path = self.repo_path.join("CHANGELOG.md");
        let content = match self.read_file(&changelog_path) {
            Some(c) => c,
            None => return,
        };

        let has_header = content.contains("# Changelog") || content.contains("# CHANGELOG");
        let has_version = Regex::new(r"## \[?v?\d+\.\d+\.\d+")
            .unwrap()
            .is_match(&content);
        let passed = has_header && has_version;
        self.add_result(AuditResult {
            name: "CHANGELOG.md 格式规范".to_string(),
            passed,
            message: if passed {
                "符合语义化版本格式".to_string()
            } else {
                "格式不规范".to_string()
            },
            suggestion: if !passed {
                Some("添加 # Changelog 标题和版本号，使用 ### Added/Changed/Fixed/Removed 分类".to_string())
            } else {
                None
            },
        });
    }

    fn check_gitignore_content(&mut self) {
        let gitignore_path = self.repo_path.join(".gitignore");
        let content = match self.read_file(&gitignore_path) {
            Some(c) => c,
            None => return,
        };

        let common = [
            (".venv", "Python 虚拟环境"),
            ("__pycache__", "Python 缓存"),
            ("*.pyc", "Python 编译文件"),
            (".env", "环境变量文件"),
        ];

        let found: Vec<_> = common
            .iter()
            .filter(|(pattern, _)| content.contains(pattern))
            .collect();

        let passed = found.len() >= 2;
        self.add_result(AuditResult {
            name: ".gitignore 内容规范".to_string(),
            passed,
            message: if passed {
                format!("包含 {} 个常见规则", found.len())
            } else {
                "规则较少".to_string()
            },
            suggestion: if !passed {
                Some("添加常见的忽略规则：.venv, __pycache__, *.pyc, .env 等".to_string())
            } else {
                None
            },
        });
    }

    fn check_submodules(&mut self) {
        let gitmodules_path = self.repo_path.join(".gitmodules");

        if !gitmodules_path.exists() {
            self.add_result(AuditResult {
                name: "子模块配置".to_string(),
                passed: true,
                message: "无子模块配置".to_string(),
                suggestion: None,
            });
            return;
        }

        let content = match self.read_file(&gitmodules_path) {
            Some(c) => c,
            None => return,
        };
        let has_submodule = content.contains("[submodule");

        let submodule_status = git_utils::run_git_cmd(
            &["submodule", "status"],
            &self.repo_path,
        );

        let passed = match submodule_status {
            Ok(out) => {
                let unpushed = out.lines().any(|line| line.starts_with('-') || line.starts_with('+'));
                has_submodule && !unpushed
            }
            Err(_) => has_submodule,
        };

        self.add_result(AuditResult {
            name: "子模块状态".to_string(),
            passed,
            message: if passed {
                "子模块配置正确且已推送".to_string()
            } else {
                "子模块有未推送的提交".to_string()
            },
            suggestion: if !passed {
                Some("请先推送所有子模块的提交，再推送父仓库".to_string())
            } else {
                None
            },
        });
    }

    fn check_recent_commits(&mut self) {
        let log_result = git_utils::run_git_cmd(&["log", "--oneline", "-10"], &self.repo_path);

        let commits = match log_result {
            Ok(out) => {
                let lines: Vec<String> = out
                    .lines()
                    .filter(|l| !l.trim().is_empty())
                    .map(|s| s.to_string())
                    .collect();
                if lines.is_empty() {
                    return;
                }
                lines
            }
            Err(_) => return,
        };

        let conventional_re =
            Regex::new(r"^(feat|fix|docs|test|refactor|chore|style|perf)(\([a-z0-9-]+\))?:\s.+")
                .unwrap();

        let compliant_count = commits
            .iter()
            .filter(|c| {
                let msg = c.split_once(' ').map(|(_, m)| m).unwrap_or(c.as_str());
                conventional_re.is_match(&msg.to_lowercase())
            })
            .count();

        let compliance_rate = compliant_count as f64 / commits.len() as f64 * 100.0;
        let passed = compliance_rate >= 50.0;

        self.add_result(AuditResult {
            name: "提交规范符合度".to_string(),
            passed,
            message: format!(
                "{}/{} 符合 Conventional Commits ({:.0}%)",
                compliant_count,
                commits.len(),
                compliance_rate
            ),
            suggestion: if !passed {
                Some("使用 `cz commit` 创建规范提交，或手动遵循 <type>: <description> 格式".to_string())
            } else {
                None
            },
        });
    }

    fn check_release_consistency(&mut self) {
        let changelog_path = self.repo_path.join("CHANGELOG.md");
        let changelog = match self.read_file(&changelog_path) {
            Some(c) => c,
            None => return,
        };

        // Try pyproject.toml first, then Cargo.toml
        let version = self
            .read_version_from_pyproject()
            .or_else(|| self.read_version_from_cargo());

        let pyproject_version = match version {
            Some(v) => v,
            None => return,
        };

        let changelog_has_version = Regex::new(&format!(
            r"## \[?{}]?",
            regex::escape(&pyproject_version)
        ))
        .unwrap()
        .is_match(&changelog);

        let has_version_commit = git_utils::run_git_cmd(&["log", "--oneline", "-20"], &self.repo_path)
            .map(|out| {
                let pattern = format!(
                    r"bump.*{}|v{}",
                    regex::escape(&pyproject_version),
                    regex::escape(&pyproject_version),
                );
                Regex::new(&pattern)
                    .ok()
                    .map(|re| re.is_match(&out.to_lowercase()))
                    .unwrap_or(true)
            })
            .unwrap_or(true);

        let passed = changelog_has_version && has_version_commit;
        self.add_result(AuditResult {
            name: "版本发布规范一致性".to_string(),
            passed,
            message: if passed {
                "CHANGELOG 和版本文件一致，且有版本提交".to_string()
            } else {
                format!("CHANGELOG 缺少 v{pyproject_version} 或缺少版本提交")
            },
            suggestion: if !passed {
                Some("发布前确保：1) 更新 CHANGELOG.md 2) 更新版本文件 3) 提交版本更新".to_string())
            } else {
                None
            },
        });
    }

    fn read_version_from_pyproject(&self) -> Option<String> {
        let path = self.repo_path.join("pyproject.toml");
        let content = self.read_file(&path)?;
        let re = Regex::new(r#"version\s*=\s*"([^"]+)""#).ok()?;
        re.captures(&content)
            .and_then(|c| c.get(1))
            .map(|m| m.as_str().to_string())
    }

    fn read_version_from_cargo(&self) -> Option<String> {
        let path = self.repo_path.join("Cargo.toml");
        let content = self.read_file(&path)?;
        let re = Regex::new(r#"version\s*=\s*"([^"]+)""#).ok()?;
        re.captures(&content)
            .and_then(|c| c.get(1))
            .map(|m| m.as_str().to_string())
    }
}

pub fn run(args: &AuditArgs) {
    let mut auditor = GitRepoAuditor::new(&args.repo_path);
    let report = auditor.audit();
    let passed = report.print_report(args.verbose);
    if !passed {
        std::process::exit(1);
    }
}
