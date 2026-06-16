#[test]
fn test_project_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["project", "--help"])
        .assert()
        .success();
}

#[test]
fn test_project_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["project", "status", "--help"])
        .assert()
        .success();
}
