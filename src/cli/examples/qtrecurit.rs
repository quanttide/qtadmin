// 量潮招聘示例
// 侧重于内部管理和量潮招聘相关的活动。
// 比如从内部讨论中获取招聘政策等。

/// 招聘政策关键词表：内部讨论中命中即视为相关政策
const POLICY_KEYWORDS: &[(&str, &str)] = &[
    ("薪资", "薪酬政策"),
    ("远程", "远程办公政策"),
    ("试用期", "试用期政策"),
    ("转正", "转正政策"),
    ("培训", "培训政策"),
    ("绩效", "绩效考核政策"),
    ("福利", "福利政策"),
];

fn main() {
    // 一段内部讨论的示例文本
    let discussion = "\
成员A：新人试用期多久？建议统一三个月。
成员B：远程办公每周两天，这个要写进政策。
成员A：转正流程走绩效评估，福利按标准执行。";

    println!("=== 从内部讨论中提取招聘政策 ===\n");

    let found: Vec<&str> = POLICY_KEYWORDS
        .iter()
        .filter(|(kw, _)| discussion.contains(kw))
        .map(|(_, policy)| *policy)
        .collect();

    if found.is_empty() {
        println!("未识别到招聘相关政策。");
    } else {
        println!("识别到 {} 项政策：", found.len());
        for policy in &found {
            println!("- {}", policy);
        }
    }
}
