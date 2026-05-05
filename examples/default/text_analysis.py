"""
日志文本分析工具
分析 docs/archive/journal/default/ 下的每日思维流日志。

用法:
  python text_analysis.py                          # 基本词频分析
  python text_analysis.py --trend 认知              # 追踪某个概念随时间的变化
  python text_analysis.py --burst                   # 检测突发性高频词
  python text_analysis.py --cooccur 管理            # 与某个词共现的词
  python text_analysis.py --topic                   # 每日主题摘要（TF-IDF 关键词）
  python text_analysis.py --network                 # 关联网络：桥梁词发现
  python text_analysis.py --decay                   # 沉寂词检测：什么在消失
  python text_analysis.py --meta                    # 写作行为元特征
  python text_analysis.py --tails                   # 长尾重要词拾遗
  python text_analysis.py --sentiment               # 情绪倾向概览
  python text_analysis.py --drift 概念              # 语义漂移：概念上下文变迁
"""

import os
import re
import sys
import math
from collections import Counter, defaultdict
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


def network_analysis(top_n=15):
    """关联网络分析：构建全量共现网络，找出高频边和桥梁词"""
    journals = load_journals()
    pair_counter = Counter()
    word_counter = Counter()
    for text in journals.values():
        words = segment(text)
        word_set = set(words)
        for w in word_set:
            word_counter[w] += 1
        sorted_words = sorted(word_set)
        for i in range(len(sorted_words)):
            for j in range(i + 1, len(sorted_words)):
                a, b = sorted_words[i], sorted_words[j]
                pair_counter[(a, b)] += 1
    print("关联网络：共现强度最高的词对\n")
    print(f"{'词A':<10} {'词B':<10} {'共现天数':<8}")
    print("-" * 35)
    for (a, b), count in pair_counter.most_common(top_n):
        print(f"{a:<10} {b:<10} {count:<8}")
    bridge_candidates = []
    for w in word_counter:
        if word_counter[w] < 5:
            continue
        neighbors = 0
        for (a, b), _ in pair_counter.most_common(1000):
            if a == w or b == w:
                neighbors += 1
        bridge_candidates.append((w, neighbors))
    bridge_candidates.sort(key=lambda x: -x[1])
    print(f"\n桥梁词（出现在最多不同词对中的词）:\n")
    print(f"{'词':<10} {'连接数':<8}")
    print("-" * 20)
    for w, n in bridge_candidates[:top_n]:
        print(f"{w:<10} {n:<8}")


def decay_detection(window=7, gap=3):
    """沉寂词检测：早期高频但在近期连续多日消失的词"""
    journals = load_journals()
    date_list = sorted(journals.keys())
    if len(date_list) < window + gap:
        print("日志天数不足")
        return
    early = date_list[:window]
    recent = date_list[-gap:]
    early_counter = Counter()
    for d in early:
        early_counter.update(segment(journals[d]))
    recent_words = set()
    for d in recent:
        recent_words.update(segment(journals[d]))
        h = f"前{window}天频次"
    print(f"沉寂词检测 (前{window}天高频, 后{gap}天未出现):\n")
    print(f"{'词':<10} {h:<12} {'总频次':<8}")
    print("-" * 35)
    count = 0
    for word, freq in early_counter.most_common(50):
        if word not in recent_words:
            total = sum(1 for t in journals.values() if word in t)
            print(f"{word:<10} {freq:<12} {total:<8}")
            count += 1
            if count >= 15:
                break


def meta_stats():
    """写作行为元特征：统计每日产出模式"""
    journals = load_journals()
    date_list = sorted(journals.keys())
    lengths = []
    for d in date_list:
        text = journals[d]
        paras = [p for p in text.split("\n\n") if p.strip()]
        sentences = [s for s in re.split(r"[。！？\n]", text) if s.strip()]
        words = segment(text)
        lengths.append((d, len(text), len(words), len(sentences), len(paras)))
    total_chars = sum(l[1] for l in lengths)
    print(f"写作行为元特征 ({date_list[0]} ~ {date_list[-1]})\n")
    print(f"日均字数: {total_chars // len(lengths)}")
    print(f"日均词数: {sum(l[2] for l in lengths) // len(lengths)}")
    print(f"最产出日: {max(lengths, key=lambda x: x[1])[0]} ({max(l[1] for l in lengths)}字)")
    print(f"最简短日: {min(lengths, key=lambda x: x[1])[0]} ({min(l[1] for l in lengths)}字)")
    print(f"\n每日产量趋势 (字):\n")
    max_len = max(l[1] for l in lengths)
    bar_len = 30
    for d, chars, nwords, nsent, npara in lengths:
        bar = "█" * int(chars / max_len * bar_len) if max_len else ""
        print(f"{d} │{bar:<{bar_len}} {chars}字")
    print(f"\n高产日 (超过日均2倍):")
    avg = total_chars / len(lengths)
    for d, chars, _, _, _ in lengths:
        if chars > avg * 2:
            print(f"  {d} ({chars}字)")


def long_tails():
    """长尾重要词拾遗：低频但跨天出现，往往是具体事件或事物"""
    journals = load_journals()
    total_counter = Counter()
    day_counter = Counter()
    for text in journals.values():
        words = set(segment(text))
        for w in words:
            day_counter[w] += 1
        for w in segment(text):
            total_counter[w] += 1
    print("长尾词拾遗（低频但跨天出现，往往是具体事件或事物）:\n")
    print(f"{'词':<10} {'天数':<6} {'总频次':<8}")
    print("-" * 28)
    candidates = [(w, day_counter[w], total_counter[w]) for w in day_counter
                  if 2 <= day_counter[w] <= 4 and total_counter[w] <= 6]
    candidates.sort(key=lambda x: -x[1])
    for w, days, total in candidates[:30]:
        print(f"{w:<10} {days:<6} {total:<8}")
    print(f"\n独家词（仅在某一天出现，高度偶发）:\n")
    once = [(w, total_counter[w]) for w in day_counter if day_counter[w] == 1]
    once.sort(key=lambda x: -x[1])
    for w, total in once[:20]:
        print(f"  {w}")


def sentiment_summary():
    """情绪倾向概览：基于简单情感词典打分"""
    pos_words = {
        "好", "不错", "愉快", "快乐", "开心", "期待", "满意", "突破", "成功",
        "进步", "成长", "希望", "信心", "积极", "乐观", "清晰", "稳定", "成熟",
        "顺利", "轻松", "舒适", "享受", "喜欢", "感动", "兴奋", "恭喜", "成就",
        "收获", "领悟", "发现", "惊喜",
    }
    neg_words = {
        "问题", "困难", "麻烦", "焦虑", "压力", "烦躁", "疲惫", "累", "沮丧",
        "失望", "担心", "害怕", "紧张", "混乱", "模糊", "冲突", "矛盾", "失败",
        "错误", "崩溃", "失控", "痛苦", "孤独", "无聊", "消极", "悲观", "批评",
        "惩罚", "罚", "痛", "累死", "受不了", "头疼", "难受", "不安", "忧虑",
    }
    journals = load_journals()
    date_list = sorted(journals.keys())
    print(f"情绪倾向概览 ({date_list[0]} ~ {date_list[-1]})\n")
    print(f"{'日期':<12} {'正向词':<7} {'负向词':<7} {'倾向':<8}")
    print("-" * 40)
    for d in date_list:
        words = segment(journals[d])
        pos = sum(1 for w in words if w in pos_words)
        neg = sum(1 for w in words if w in neg_words)
        delta = pos - neg
        tag = "积极" if delta > 2 else ("消极" if delta < -2 else "中性")
        bar_pos = "■" * min(pos, 10)
        bar_neg = "□" * min(neg, 10)
        print(f"{d:<12} {pos:<7} {neg:<7} {bar_pos}{bar_neg} {tag}")


def drift(concept):
    """语义漂移：概念在不同阶段的上下文词变化"""
    journals = load_journals()
    date_list = sorted(journals.keys())
    n = len(date_list)
    if n < 6:
        print("日志天数不足")
        return
    third = n // 3
    stages = [
        ("早期", date_list[:third]),
        ("中期", date_list[third:2*third]),
        ("近期", date_list[2*third:]),
    ]
    print(f"概念「{concept}」语义漂移 (上下文词 Top 10):\n")
    for label, dates in stages:
        counter = Counter()
        for d in dates:
            text = journals[d]
            if concept not in text:
                continue
            words = segment(text)
            idxs = [i for i, w in enumerate(words) if w == concept]
            for idx in idxs:
                start = max(0, idx - 8)
                end = min(len(words), idx + 9)
                for w in words[start:end]:
                    if w != concept and w not in STOP_WORDS:
                        counter[w] += 1
        top = [w for w, _ in counter.most_common(10)]
        print(f"  {label}: {', '.join(top) if top else '(未出现)'}")


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

    h = "前7天频次"

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

    lines.append("\n## 关联网络：最强共现词对\n\n")
    pair_counter = Counter()
    for text in journals.values():
        words = segment(text)
        s = sorted(set(words))
        for i in range(len(s)):
            for j in range(i + 1, len(s)):
                pair_counter[(s[i], s[j])] += 1
    lines.append("| 词A | 词B | 共现天数 |\n")
    lines.append("|---|---|---|\n")
    for (a, b), count in pair_counter.most_common(15):
        lines.append(f"| {a} | {b} | {count} |\n")

    lines.append("\n## 情绪倾向\n\n")
    pos_words = {
        "好", "不错", "愉快", "快乐", "开心", "期待", "满意", "突破", "成功",
        "进步", "成长", "希望", "信心", "积极", "乐观", "清晰", "稳定", "成熟",
        "顺利", "轻松", "舒适", "享受", "喜欢", "感动", "兴奋", "恭喜", "成就",
        "收获", "领悟", "发现", "惊喜",
    }
    neg_words = {
        "问题", "困难", "麻烦", "焦虑", "压力", "烦躁", "疲惫", "累", "沮丧",
        "失望", "担心", "害怕", "紧张", "混乱", "模糊", "冲突", "矛盾", "失败",
        "错误", "崩溃", "失控", "痛苦", "孤独", "无聊", "消极", "悲观", "批评",
        "惩罚", "罚", "痛", "累死", "受不了", "头疼", "难受", "不安", "忧虑",
    }
    pos_counts = []
    neg_counts = []
    for d in date_list:
        words = segment(journals[d])
        pos = sum(1 for w in words if w in pos_words)
        neg = sum(1 for w in words if w in neg_words)
        pos_counts.append(pos)
        neg_counts.append(neg)
    avg_pos = sum(pos_counts) / len(pos_counts)
    avg_neg = sum(neg_counts) / len(neg_counts)
    lines.append(f"- 日均正向词: {avg_pos:.1f}\n")
    lines.append(f"- 日均负向词: {avg_neg:.1f}\n")
    pos_dates = [(d, pos_counts[i]) for i, d in enumerate(date_list) if pos_counts[i] > avg_pos * 1.5]
    neg_dates = [(d, neg_counts[i]) for i, d in enumerate(date_list) if neg_counts[i] > avg_neg * 1.5]
    if pos_dates:
        lines.append(f"- 最积极日: {', '.join(f'{d}({c})' for d, c in pos_dates[:5])}\n")
    if neg_dates:
        lines.append(f"- 最消极日: {', '.join(f'{d}({c})' for d, c in neg_dates[:5])}\n")

    lines.append("\n## 沉寂词（前7天高频但近期消失）\n\n")
    early = date_list[:7]
    recent = date_list[-3:]
    early_counter = Counter()
    for d in early:
        early_counter.update(segment(journals[d]))
    recent_words = set()
    for d in recent:
        recent_words.update(segment(journals[d]))
    for word, freq in early_counter.most_common(50):
        if word not in recent_words:
            total = sum(1 for t in journals.values() if word in t)
            lines.append(f"- **{word}**: 前7天 {freq} 次, 共 {total} 天\n")

    lines.append("\n## 长尾词拾遗\n\n")
    day_counter = Counter()
    total_counter = Counter()
    for text in journals.values():
        for w in set(segment(text)):
            day_counter[w] += 1
        for w in segment(text):
            total_counter[w] += 1
    tails = [(w, day_counter[w]) for w in day_counter if 2 <= day_counter[w] <= 4 and total_counter[w] <= 6]
    tails.sort(key=lambda x: -x[1])
    for w, d in tails[:15]:
        lines.append(f"- {w} ({d}天)\n")

    lines.append("\n## 写作行为元特征\n\n")
    lengths = []
    for d in date_list:
        words = segment(journals[d])
        lengths.append((d, len(journals[d]), len(words)))
    avg_chars = sum(l[1] for l in lengths) // len(lengths)
    avg_words = sum(l[2] for l in lengths) // len(lengths)
    max_day = max(lengths, key=lambda x: x[1])
    min_day = min(lengths, key=lambda x: x[1])
    lines.append(f"- 日均字数: {avg_chars}\n")
    lines.append(f"- 日均词数: {avg_words}\n")
    lines.append(f"- 最产出日: {max_day[0]} ({max_day[1]}字)\n")
    lines.append(f"- 最简短日: {min_day[0]} ({min_day[1]}字)\n")

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
    elif sys.argv[1] == "--network":
        network_analysis()
    elif sys.argv[1] == "--decay":
        decay_detection()
    elif sys.argv[1] == "--meta":
        meta_stats()
    elif sys.argv[1] == "--tails":
        long_tails()
    elif sys.argv[1] == "--sentiment":
        sentiment_summary()
    elif sys.argv[1] == "--drift" and len(sys.argv) > 2:
        drift(sys.argv[2])
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
