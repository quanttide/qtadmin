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

#[test]
fn test_business_quote_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "quote", "--help"])
        .assert()
        .success();
}

#[test]
fn test_business_quote_standard() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "quote", "--hours", "8", "--level", "advanced"])
        .assert()
        .success()
        .stdout(predicates::str::contains("8000 元"))
        .stdout(predicates::str::contains("标准报价"));
}

#[test]
fn test_business_quote_premium() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "quote", "--hours", "36", "--level", "chief", "--premium", "30"])
        .assert()
        .success()
        .stdout(predicates::str::contains("79560 元"))
        .stdout(predicates::str::contains("重大报价"));
}

#[test]
fn test_business_quote_invalid_level() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["business", "quote", "--level", "invalid"])
        .assert()
        .success()
        .stderr(predicates::str::contains("不支持的人员等级"));
}
