#[test]
fn test_audit_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["asset", "audit", "--help"])
        .assert()
        .success();
}
