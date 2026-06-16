/// Test that the binary compiles and --help works
#[test]
fn test_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.arg("--help")
        .assert()
        .success();
}

#[test]
fn test_version() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.arg("--version")
        .assert()
        .success();
}

#[test]
fn test_asset_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["asset", "--help"])
        .assert()
        .success();
}
