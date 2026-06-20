#[test]
fn test_asset_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["asset", "status", "--help"]).assert().success();
}

#[test]
fn test_asset_quality_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["asset", "quality", "--help"]).assert().success();
}

#[test]
fn test_asset_archive_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["asset", "archive", "--help"]).assert().success();
}
