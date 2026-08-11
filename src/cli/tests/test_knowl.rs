#[test]
fn test_knowl_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["knowl", "--help"])
        .assert()
        .success();
}

#[test]
fn test_knowl_acquire_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["knowl", "acquire", "--help"])
        .assert()
        .success();
}
