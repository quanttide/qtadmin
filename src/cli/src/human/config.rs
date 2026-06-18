use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct PositionRule {
    pub name: String,
    pub keywords: Vec<String>,
    #[serde(default)]
    pub exclude: Vec<String>,
    #[serde(default = "default_priority")]
    pub priority: i32,
}

fn default_priority() -> i32 {
    0
}

#[derive(Debug, Clone, Deserialize)]
pub struct HumanConfig {
    #[serde(default)]
    pub rules: Vec<PositionRule>,
}

fn builtin_rules() -> Vec<PositionRule> {
    vec![
        PositionRule {
            name: "全栈工程师".into(),
            keywords: vec!["全栈".into(), "后端开发".into(), "后端".into(), "AI应用".into()],
            exclude: vec![],
            priority: 10,
        },
        PositionRule {
            name: "数据工程师".into(),
            keywords: vec!["数据".into(), "技术实习生".into(), "技术实习".into()],
            exclude: vec!["运营".into()],
            priority: 0,
        },
        PositionRule {
            name: "新媒体运营".into(),
            keywords: vec!["新媒体运营".into(), "运营".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "商务经理".into(),
            keywords: vec!["商务".into(), "BD".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "项目经理".into(),
            keywords: vec!["PM".into(), "项目经理".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "产品经理".into(),
            keywords: vec!["产品".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "课程助教".into(),
            keywords: vec!["课程助教".into(), "助教".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "销售经理".into(),
            keywords: vec!["销售".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "人事经理".into(),
            keywords: vec!["HR".into(), "人力资源".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "咨询助理".into(),
            keywords: vec!["咨询助理".into(), "咨询".into()],
            exclude: vec![],
            priority: 0,
        },
        PositionRule {
            name: "执行助理".into(),
            keywords: vec!["执行助理".into(), "助理".into()],
            exclude: vec!["咨询".into(), "课程".into()],
            priority: 0,
        },
        PositionRule {
            name: "法务实习生".into(),
            keywords: vec!["法务".into(), "法律".into(), "合规".into()],
            exclude: vec![],
            priority: 0,
        },
    ]
}

fn config_paths() -> Vec<PathBuf> {
    let mut paths = Vec::new();

    if let Ok(env_path) = std::env::var("QTRECURIT_CONFIG") {
        paths.push(PathBuf::from(env_path));
    }

    if let Ok(cwd) = std::env::current_dir() {
        paths.push(cwd.join("qtrecurit.toml"));
    }

    if let Some(config_dir) = dirs::config_dir() {
        paths.push(config_dir.join("qtadmin").join("qtrecurit.toml"));
    }

    paths
}

fn load_from_file(path: &PathBuf) -> Option<HumanConfig> {
    let content = std::fs::read_to_string(path).ok()?;
    toml::from_str(&content).ok()
}

pub fn load_config() -> HumanConfig {
    for path in config_paths() {
        if let Some(config) = load_from_file(&path) {
            if !config.rules.is_empty() {
                return config;
            }
        }
    }
    HumanConfig {
        rules: builtin_rules(),
    }
}

/// 从 Provider 加载分类规则，失败时回退到内置规则。
pub async fn load_rules(client: &crate::provider::ProviderClient) -> Vec<PositionRule> {
    match client.list_rules().await {
        Ok(rules) => {
            if rules.is_empty() {
                return builtin_rules();
            }
            rules
                .into_iter()
                .map(|r| PositionRule {
                    name: r.name,
                    keywords: r.keywords,
                    exclude: r.exclude,
                    priority: r.priority,
                })
                .collect()
        }
        Err(_) => builtin_rules(),
    }
}

pub fn classify<'a>(subject: &str, rules: &'a [PositionRule]) -> Option<&'a str> {
    if subject.is_empty() {
        return None;
    }

    let re = regex::Regex::new(r"[\[【](.*?)[\]】]|岗位[：:]\s*(.*?)\s*[,，|]").ok();
    if let Some(ref re) = re {
        if let Some(caps) = re.captures(subject) {
            let extracted = caps.get(1).or_else(|| caps.get(2)).map(|m| m.as_str());
            if let Some(extracted) = extracted {
                let trimmed = extracted.trim();
                if !trimmed.is_empty() {
                    if let Some(pos) = match_by_priority(trimmed, rules) {
                        return Some(pos);
                    }
                }
            }
        }
    }

    match_by_priority(subject, rules)
}

fn match_by_priority<'a>(text: &str, rules: &'a [PositionRule]) -> Option<&'a str> {
    let mut matched: Vec<&PositionRule> = Vec::new();
    for rule in rules {
        let has_keyword = rule.keywords.iter().any(|kw| text.contains(kw.as_str()));
        if !has_keyword {
            continue;
        }
        let has_exclude = rule.exclude.iter().any(|ex| text.contains(ex.as_str()));
        if has_exclude {
            continue;
        }
        matched.push(rule);
    }
    matched.sort_by(|a, b| b.priority.cmp(&a.priority));
    matched.first().map(|r| r.name.as_str())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_rules() -> Vec<PositionRule> {
        builtin_rules()
    }

    #[test]
    fn test_classify_fullstack() {
        let rules = test_rules();
        assert_eq!(classify("应聘全栈工程师 - 张三", &rules), Some("全栈工程师"));
        assert_eq!(classify("【后端开发】李四 - 3年经验", &rules), Some("全栈工程师"));
    }

    #[test]
    fn test_classify_data_engineer() {
        let rules = test_rules();
        assert_eq!(classify("应聘数据工程师 - 王五", &rules), Some("数据工程师"));
    }

    #[test]
    fn test_classify_exclude_priority() {
        let rules = test_rules();
        assert_eq!(classify("数据运营实习申请", &rules), Some("新媒体运营"));
    }

    #[test]
    fn test_classify_empty() {
        let rules = test_rules();
        assert_eq!(classify("", &rules), None);
        assert_eq!(classify("自动回复：感谢您的投递", &rules), None);
    }

    #[test]
    fn test_classify_bracket_extract() {
        let rules = test_rules();
        assert_eq!(classify("【PM】张三 - 项目经理求职", &rules), Some("项目经理"));
        assert_eq!(classify("岗位：产品经理 - 李四", &rules), Some("产品经理"));
    }

    #[test]
    fn test_builtin_rules_not_empty() {
        let rules = builtin_rules();
        assert!(!rules.is_empty());
        assert_eq!(rules.len(), 12);
    }

    #[test]
    fn test_config_loading_fallback_to_builtin() {
        let config = load_config();
        assert!(!config.rules.is_empty());
    }
}
