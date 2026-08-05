#[test]
fn test_project_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["project", "--help"]).assert().success();
}

#[test]
fn test_project_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["project", "status", "--help"]).assert().success();
}

#[test]
fn test_project_status_output() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["project", "status"]).assert().success();
}

#[test]
fn test_human_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["human", "--help"]).assert().success();
}

#[test]
fn test_human_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["human", "status", "--help"]).assert().success();
}

#[test]
fn test_asset_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["asset", "--help"]).assert().success();
}

#[test]
fn test_connect_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["connect", "--help"]).assert().success();
}

#[test]
fn test_connect_notice_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["connect", "notice", "--help"]).assert().success();
}

#[test]
fn test_human_position_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["human", "position", "--help"]).assert().success();
}
