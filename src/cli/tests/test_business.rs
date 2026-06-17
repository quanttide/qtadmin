#[test]
fn test_business_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "--help"])
        .assert()
        .success();
}

#[test]
fn test_business_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "status", "--help"])
        .assert()
        .success();
}
