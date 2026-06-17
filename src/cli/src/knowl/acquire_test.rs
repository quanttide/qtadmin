use super::*;
use std::io::Write;

#[test]
fn test_default_sources_returns_four() {
    let sources = default_sources();
    assert_eq!(sources.len(), 4);
    assert!(sources.iter().any(|(n, _)| n == "bylaw"));
    assert!(sources.iter().any(|(n, _)| n == "handbook"));
    assert!(sources.iter().any(|(n, _)| n == "tutorial"));
    assert!(sources.iter().any(|(n, _)| n == "profile"));
}

#[test]
fn test_read_text_returns_content() {
    let dir = std::env::temp_dir();
    let path = dir.join("_test_acquire_read.txt");
    let mut f = std::fs::File::create(&path).unwrap();
    writeln!(f, "hello world").unwrap();
    assert_eq!(read_text(&path), "hello world\n");
    let _ = std::fs::remove_file(&path);
}

#[test]
fn test_read_text_missing_file() {
    let path = PathBuf::from("/nonexistent/file.md");
    assert_eq!(read_text(&path), "");
}

#[test]
fn test_run_custom_input_file_reading() {
    let dir = std::env::temp_dir();
    let input = dir.join("_test_acquire_input.txt");
    std::fs::write(&input, "simple test content").unwrap();

    let args = AcquireArgs {
        input: input.to_string_lossy().to_string(),
        output: dir.join("_test_acquire_out").to_string_lossy().to_string(),
    };

    let result = run(&args);
    if env::var("DEEPSEEK_API_KEY").is_ok() {
        assert!(result.is_ok(), "LLM 调用应成功（有 API key）");
    } else {
        assert!(result.is_err(), "无 API key 时应报错");
    }

    let _ = std::fs::remove_file(&input);
    let _ = std::fs::remove_dir_all(&args.output);
}
