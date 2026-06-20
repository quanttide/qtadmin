use std::path::Path;
use std::process::Command;

use anyhow::{Context, Result};

pub fn run_git_cmd(args: &[&str], cwd: &Path) -> Result<String> {
    let output = Command::new("git")
        .args(args)
        .current_dir(cwd)
        .output()
        .with_context(|| format!("failed to run git {} in {:?}", args.join(" "), cwd))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("git {} failed: {}", args.join(" "), stderr.trim());
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

pub fn has_uncommitted_changes(repo_path: &Path) -> Result<bool> {
    let out = run_git_cmd(&["status", "--porcelain"], repo_path)?;
    Ok(!out.is_empty())
}

pub fn commit_and_push(
    repo_path: &Path,
    message: &str,
    push: bool,
) -> Result<bool> {
    if !has_uncommitted_changes(repo_path)? {
        return Ok(false);
    }

    run_git_cmd(&["add", "-A"], repo_path)?;
    run_git_cmd(&["commit", "-m", message], repo_path)?;

    if push {
        run_git_cmd(&["push", "origin", "main"], repo_path)?;
    }

    Ok(true)
}

pub fn update_submodule_in_main_repo(
    project_root: &Path,
    submodule_name: &str,
    message: &str,
    push: bool,
) -> Result<()> {
    run_git_cmd(&["add", submodule_name], project_root)?;

    if !has_uncommitted_changes(project_root)? {
        return Ok(());
    }

    run_git_cmd(&["commit", "-m", message], project_root)?;

    if push {
        run_git_cmd(&["push", "origin", "main"], project_root)?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn init_repo(dir: &Path) {
        Command::new("git")
            .args(["init"])
            .current_dir(dir)
            .output()
            .unwrap();
        Command::new("git")
            .args(["config", "user.email", "test@test.com"])
            .current_dir(dir)
            .output()
            .unwrap();
        Command::new("git")
            .args(["config", "user.name", "Test"])
            .current_dir(dir)
            .output()
            .unwrap();
    }

    #[test]
    fn test_run_git_cmd_success() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());

        let out = run_git_cmd(&["status", "--porcelain"], dir.path()).unwrap();
        assert_eq!(out, "");
    }

    #[test]
    fn test_run_git_cmd_failure() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());

        let result = run_git_cmd(&["invalid-command"], dir.path());
        assert!(result.is_err());
    }

    #[test]
    fn test_has_uncommitted_changes_clean() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());

        assert!(!has_uncommitted_changes(dir.path()).unwrap());
    }

    #[test]
    fn test_has_uncommitted_changes_dirty() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(dir.path().join("new.txt"), "content").unwrap();

        assert!(has_uncommitted_changes(dir.path()).unwrap());
    }

    #[test]
    fn test_commit_and_push_no_changes() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());

        let result = commit_and_push(dir.path(), "test", false).unwrap();
        assert!(!result);
    }

    #[test]
    fn test_commit_and_push_success() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(dir.path().join("a.txt"), "content").unwrap();

        let result = commit_and_push(dir.path(), "feat: add a.txt", false).unwrap();
        assert!(result);

        // verify commit was made
        let log = run_git_cmd(&["log", "--oneline", "-1"], dir.path()).unwrap();
        assert!(log.contains("feat: add a.txt"));
    }

    #[test]
    fn test_run_git_cmd_invalid_dir() {
        let result = run_git_cmd(&["status"], Path::new("/nonexistent"));
        assert!(result.is_err());
    }
}
