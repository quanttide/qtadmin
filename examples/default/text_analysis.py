"""
日志文本分析工具
分析 docs/archive/journal/default/ 下的每日思维流日志。

用法:
  python text_analysis.py                          # 基本词频分析
  python text_analysis.py --trend 认知              # 追踪某个概念随时间的变化
  python text_analysis.py --burst                   # 检测突发性高频词
  python text_analysis.py --cooccur 管理            # 与某个词共现的词
  python text_analysis.py --topic                   # 每日主题摘要（TF-IDF 关键词）
"""

import os
import re
import sys
from collections import Counter
from datetime import datetime

import jieba
import jieba.analyse
from dotenv import load_dotenv

load_dotenv()

DATA_DIR = os.getenv("JOURNAL_DIR")
REPORT_DIR = os.getenv("REPORT_DIR", ".")
STOP_WORDS = {
    "这个", "那个", "什么", "怎么", "如何", "可以", "就是", "一个",
    "没有", "不是", "我们", "他们", "你们", "自己", "因为", "所以",
    "但是", "如果", "而且", "或者", "然后", "已经", "可以", "知道",
    "觉得", "这样", "那么", "时候", "还是", "这些", "一些", "不会",
    "可能", "只是", "非常", "比较", "需要", "应该", "不要", "通过",
    "之后", "之前", "现在", "今天", "已经", "还有", "对于", "当中",
    "其实", "这种", "那个", "这个", "就是", "的话", "一种", "一下",
    "开始", "之后", "之后", "方式", "来说", "看到", "到了", "有关",
    "其中", "所谓", "是否", "能够", "成为", "带来", "提出", "进入",
    "出来", "过来", "起来", "回到", "变得", "作为", "作为", "不同",
    "一样", "一点", "越来越", "越来越", "越来越",
}


def load_journals():
    """加载所有日志文件，返回 {date_str: text} 字典"""
    journals = {}
    pattern = re.compile(r"^\d{4}-\d{2}-\d{2}\.md$")
    for fname in sorted(os.listdir(DATA_DIR)):
        if not pattern.match(fname):
            continue
        date_str = fname.replace(".md", "")
        with open(os.path.join(DATA_DIR, fname), encoding="utf-8") as f:
            text = f.read()
        text = re.sub(r"^# .+", "", text, flags=re.MULTILINE)
        journals[date_str] = text.strip()
    return journals


def segment(text):
    """分词并过滤停用词"""
    words = jieba.cut(text)
    return [w.strip() for w in words if w.strip() and len(w.strip()) > 1 and w.strip() not in STOP_WORDS]


def basic_stats():
    """基础统计：总词频"""
    journals = load_journals()
    counter = Counter()
    for date_str, text in journals.items():
        words = segment(text)
        counter.update(words)
    print(f"日志总数: {len(journals)} 天")
    print(f"去重词数: {len(counter)}")
    print(f"\n总词频 Top 50:")
    print(f"{'词':<10} {'频次':<6}  {'出现天数':<8}")
    print("-" * 30)
    for word, count in counter.most_common(50):
        day_count = sum(1 for text in journals.values() if word in text)
        print(f"{word:<10} {count:<6}  {day_count:<8}")


def daily_keywords(top_n=10):
    """每日 TF-IDF 关键词"""
    journals = load_journals()
    for date_str, text in journals.items():
        if not text.strip():
            continue
        keywords = jieba.analyse.extract_tags(text, topK=top_n, withWeight=True)
        words = ", ".join(f"{w}({v:.2f})" for w, v in keywords)
        print(f"{date_str}: {words}")


def trend(concept):
    """追踪概念随时间的变化频率"""
    journals = load_journals()
    dates = []
    freqs = []
    for date_str, text in sorted(journals.items()):
        if not text.strip():
            continue
        words = segment(text)
        count = words.count(concept)
        if count > 0:
            dates.append(date_str)
            freqs.append(count)
    if not dates:
        print(f"未找到概念: {concept}")
        return
    max_freq = max(freqs)
    bar_len = 40
    print(f"概念「{concept}」出现趋势 (共 {sum(freqs)} 次, {len(dates)} 天):\n")
    for d, f in zip(dates, freqs):
        bar = "█" * int(f / max_freq * bar_len) if max_freq else ""
        print(f"{d} │{bar:<{bar_len}} {f}")
    print(f"\n首次出现: {dates[0]}")
    print(f"最近出现: {dates[-1]}")


def burst_detection(window=7, threshold=2.0):
    """突发词检测：某词在某天的频率超过其平均频率的 threshold 倍"""
    journals = load_journals()
    date_list = sorted(journals.keys())
    word_daily = {}
    for date_str in date_list:
        words = segment(journals[date_str])
        word_daily[date_str] = Counter(words)
    all_words = set()
    for c in word_daily.values():
        all_words.update(c.keys())

    print(f"突发词检测 (窗口={window}天, 阈值={threshold}x):\n")
    for date_str in date_list:
        today = word_daily[date_str]
        window_start = max(0, date_list.index(date_str) - window)
        window_dates = date_list[window_start:date_list.index(date_str)]
        if not window_dates:
            continue
        window_counter = Counter()
        for wd in window_dates:
            window_counter.update(word_daily[wd])
        for word, count in today.most_common(50):
            avg = window_counter.get(word, 0) / len(window_dates) if window_dates else 0
            if avg > 0 and count >= avg * threshold and count >= 3:
                print(f"{date_str} 爆发: {word} ({count}次, 平时均{avg:.1f})")


def cooccur(concept, top_n=20):
    """与目标词共现频率最高的词"""
    journals = load_journals()
    counter = Counter()
    for text in journals.values():
        if concept not in text:
            continue
        words = segment(text)
        idxs = [i for i, w in enumerate(words) if w == concept]
        window = 10
        for idx in idxs:
            start = max(0, idx - window)
            end = min(len(words), idx + window + 1)
            for w in words[start:end]:
                if w != concept:
                    counter[w] += 1
    total = sum(counter.values())
    print(f"与「{concept}」最常共现的词 (总共现 {total} 次):\n")
    print(f"{'词':<10} {'共现':<6} {'比例':<8}")
    print("-" * 30)
    for word, count in counter.most_common(top_n):
        pct = count / total * 100
        print(f"{word:<10} {count:<6} {pct:.1f}%")


def generate_report():
    """生成综合分析报告，输出到 REPORT_DIR"""
    journals = load_journals()
    date_list = sorted(journals.keys())

    counter = Counter()
    for text in journals.values():
        counter.update(segment(text))

    word_daily = {}
    for d in date_list:
        word_daily[d] = Counter(segment(journals[d]))

    lines = []
    lines.append("# 日志分析报告\n")
    lines.append(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
    lines.append(f"日志天数: {len(journals)} 天 ({date_list[0]} ~ {date_list[-1]})\n")
    lines.append(f"去重词数: {len(counter)}\n")
    lines.append("---\n")

    lines.append("## 总词频 Top 30\n\n")
    lines.append("| 词 | 频次 | 出现天数 |\n")
    lines.append("|---|---|---|\n")
    for word, count in counter.most_common(30):
        day_count = sum(1 for t in journals.values() if word in t)
        lines.append(f"| {word} | {count} | {day_count} |\n")

    lines.append("\n## 每日关键词\n\n")
    for d in date_list:
        keywords = jieba.analyse.extract_tags(journals[d], topK=5, withWeight=True)
        words = ", ".join(f"{w}({v:.2f})" for w, v in keywords)
        lines.append(f"- **{d}**: {words}\n")

    top_concepts = [w for w, _ in counter.most_common(20)]
    lines.append("\n## 概念趋势\n\n")
    for concept in top_concepts[:10]:
        freq_by_day = [(d, word_daily[d][concept]) for d in date_list if word_daily[d][concept] > 0]
        if len(freq_by_day) < 2:
            continue
        total = sum(f for _, f in freq_by_day)
        first = freq_by_day[0][0]
        last = freq_by_day[-1][0]
        lines.append(f"- **{concept}**: 共 {total} 次, {len(freq_by_day)} 天, 首现 {first}, 最近 {last}\n")

    lines.append("\n## 突发词（按天）\n\n")
    for i, d in enumerate(date_list):
        today = word_daily[d]
        window_start = max(0, i - 7)
        if i == window_start:
            continue
        window_dates = date_list[window_start:i]
        window_counter = Counter()
        for wd in window_dates:
            window_counter.update(word_daily[wd])
        bursts = []
        for word, count in today.most_common(30):
            avg = window_counter.get(word, 0) / len(window_dates) if window_dates else 0
            if avg > 0 and count >= avg * 2 and count >= 3:
                bursts.append(f"{word}({count}/{avg:.1f})")
        if bursts:
            lines.append(f"- **{d}**: {', '.join(bursts)}\n")

    os.makedirs(REPORT_DIR, exist_ok=True)
    path = os.path.join(REPORT_DIR, "journal_report.md")
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines)
    print(f"报告已生成: {path}")


def main():
    if len(sys.argv) == 1:
        basic_stats()
    elif sys.argv[1] == "--trend" and len(sys.argv) > 2:
        trend(sys.argv[2])
    elif sys.argv[1] == "--burst":
        burst_detection()
    elif sys.argv[1] == "--cooccur" and len(sys.argv) > 2:
        cooccur(sys.argv[2])
    elif sys.argv[1] == "--topic":
        daily_keywords()
    elif sys.argv[1] == "--report":
        generate_report()
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
