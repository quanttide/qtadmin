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
