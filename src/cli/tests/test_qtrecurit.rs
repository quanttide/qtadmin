#[test]
fn test_qtrecurit_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["qtrecurit", "--help"])
        .assert()
        .success();
}

#[test]
fn test_status_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin-cli").unwrap();
    cmd.args(["qtrecurit", "status", "--help"])
        .assert()
        .success();
}
