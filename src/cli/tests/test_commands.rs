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
fn test_qtconsult_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtconsult", "--help"]).assert().success();
}

#[test]
fn test_qtconsult_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtconsult", "status", "--help"]).assert().success();
}

#[test]
fn test_qtclass_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtclass", "--help"]).assert().success();
}

#[test]
fn test_qtclass_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtclass", "status", "--help"]).assert().success();
}

#[test]
fn test_qtcloud_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtcloud", "--help"]).assert().success();
}

#[test]
fn test_qtcloud_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtcloud", "status", "--help"]).assert().success();
}

#[test]
fn test_qtdata_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtdata", "--help"]).assert().success();
}

#[test]
fn test_qtdata_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["qtdata", "status", "--help"]).assert().success();
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
fn test_auth_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["auth", "--help"]).assert().success();
}

#[test]
fn test_auth_user_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["auth", "user", "--help"]).assert().success();
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
