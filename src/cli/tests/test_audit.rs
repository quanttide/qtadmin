#[test]
fn test_audit_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["asset", "audit", "--help"])
        .assert()
        .success();
}
