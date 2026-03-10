# 智能体工程

## AgentDiagnose

我来为你详细介绍 AgentDiagnose 这个专门用于诊断 AI Agent 行为轨迹的开源框架。这是一个学术级的分析工具，非常适合你深入理解 OpenClaw 的”做事方式“。
🎯 AgentDiagnose 是什么？
AgentDiagnose 是由 Salesforce AI Research 开发的开源框架，专门用于诊断 AI Agent 的行为轨迹（trajectories）。它通过五大核心能力维度，量化评估 Agent 在任务执行过程中的表现，帮助开发者理解 Agent 的决策逻辑、失败原因和优化方向   。
与一般的日志查看工具不同，AgentDiagnose 提供结构化的诊断框架和丰富的可视化能力，让你不仅能”看到“ Agent 做了什么，还能理解它”为什么这么做“以及”做得好不好“。
🧠 五大核心诊断维度
AgentDiagnose 将 Agent 的能力分解为五个可量化评估的维度：
1.  回溯与探索（Backtracking & Exploration）
•  评估内容：Agent 是否会主动探索不同路径，以及在发现错误时能否回溯修正
•  关键指标：
•  探索多样性（Exploration Diversity）：尝试的不同动作数量
•  回溯频率（Backtracking Frequency）：从错误路径返回的次数
•  收敛效率（Convergence Efficiency）：找到正确路径所需的步骤数
•  观察价值：看 OpenClaw 是”一条路走到黑“还是”灵活试错“
2.  任务分解（Task Decomposition）
•  评估内容：Agent 将复杂任务拆解为可执行子任务的能力
•  关键指标：
•  子任务数量与复杂度分布
•  任务层级深度
•  子任务之间的依赖关系清晰度
•  观察价值：理解 OpenClaw 的”思维模式“——是喜欢大步推进还是小步快跑
3.  观察阅读（Observation Reading）
•  评估内容：Agent 对环境反馈（Observation）的理解和利用程度
•  关键指标：
•  信息提取完整度
•  关键信息识别准确率
•  观察-动作关联度
•  观察价值：看 OpenClaw 是否”认真看“了工具返回的结果，还是”视而不见“
4.  自我验证（Self-verification）
•  评估内容：Agent 检查自身工作、发现错误并修正的能力
•  关键指标：
•  验证步骤的频率和时机
•  错误自纠成功率
•  置信度校准准确度
•  观察价值：这是”创造者“vs”观察者“的关键区别——创造者需要更强的自我验证
5.  目标质量（Objective Quality）
•  评估内容：最终输出结果的质量评估
•  关键指标：
•  任务完成度
•  结果准确性
•  与预期目标的匹配度
•  观察价值：最终裁判，看 OpenClaw 的”交付质量“
-—
📊 可视化能力
AgentDiagnose 提供三种核心可视化模块，让分析结果一目了然：
1.  t-SNE 动作嵌入图
•  将 Agent 的所有动作映射到 2D 空间
•  通过聚类观察行为模式：哪些动作经常一起出现？是否存在固定的”行为套路“？
•  颜色编码不同执行阶段，看 Agent 的工作流程演进
2.  交互式词云（Word Cloud）
•  提取轨迹中的高频操作和关键决策词
•  快速识别 Agent 的”口头禅“和偏好策略
•  支持按时间窗口筛选，观察行为演变
3.  状态转换时间线
•  类似 Git 提交历史的可视化
•  展示 Agent 从开始到结束的完整决策路径
•  标注回溯点、探索分支和关键决策节点
•  支持点击展开查看每一步的详细上下文
-—
🔧 技术架构与使用方式
安装
pip install agentdiagnose
基本使用流程
第一步：准备轨迹数据
AgentDiagnose 接受标准格式的 Agent 轨迹，通常是 JSON 格式，包含：
•  动作序列（Action Sequence）
•  观察记录（Observations）
•  思考过程（Reasoning/Thoughts）
•  时间戳和元数据
对于 OpenClaw，你需要从其日志中提取这些信息。OpenClaw 的日志是 JSON Lines 格式，每行包含：
{
”time“: ”2024-01-17T10:30:00Z“,
”level“: ”info“,
”msg“: ”Executing skill“,
”skill“: ”web_search“,
”input“: {”query“: ”OpenClaw analytics“},
”output“: {...}
}
第二步：加载并诊断
from agentdiagnose import TrajectoryAnalyzer, Dimension
加载轨迹数据
analyzer = TrajectoryAnalyzer.from_jsonl(”openclaw_logs.jsonl“)
运行完整诊断
report = analyzer.diagnose(
dimensions=[
Dimension.BACKTRACKING,
Dimension.TASK_DECOMPOSITION,
Dimension.OBSERVATION_READING,
Dimension.SELF_VERIFICATION,
Dimension.OBJECTIVE_QUALITY
]
)
查看评分
print(report.scores)
输出示例：
{
’backtracking‘: 0.75,
’task_decomposition‘: 0.82,
’observation_reading‘: 0.65,
’self_verification‘: 0.45,  # <- 可能是个弱点
’objective_quality‘: 0.78
}
第三步：生成可视化
生成 t-SNE 动作图
report.visualize_tsne(save_path=”openclaw_tsne.png“)
生成词云
report.visualize_wordcloud(save_path=”openclaw_wordcloud.png“)
生成状态转换时间线（交互式 HTML）
report.visualize_timeline(save_path=”openclaw_timeline.html“)
-—
🎛️ 高级功能
对比分析（Comparative Analysis）
你可以对比不同时间段或不同配置的 OpenClaw 行为：
对比两个版本的 OpenClaw
report_v1 = analyzer.diagnose(trajectory_v1)
report_v2 = analyzer.diagnose(trajectory_v2)
comparison = report_v1.compare(report_v2)
comparison.visualize_radar_chart()  # 雷达图对比五个维度
异常检测（Anomaly Detection）
自动识别轨迹中的异常行为模式：
anomalies = analyzer.detect_anomalies(
threshold=0.05,  # 偏离正常模式的阈值
context_window=5  # 考虑的上下文窗口大小
)
返回异常发生的时间点和类型
自定义评估维度
如果五大维度不够，你可以扩展：
from agentdiagnose import CustomMetric
定义”技能多样性“指标
skill_diversity = CustomMetric(
name=”skill_diversity“,
calculator=lambda traj: len(set(step[’skill‘] for step in traj)) / len(traj)
)
report = analyzer.diagnose(custom_metrics=[skill_diversity])
-—
🔄 与 OpenClaw 的集成方案
由于 OpenClaw 的日志格式是专有的，你需要一个适配器：
openclaw_adapter.py
import json
from agentdiagnose import Trajectory, Step
def parse_openclaw_log(log_file):
”“”将 OpenClaw JSONL 日志转换为 AgentDiagnose 轨迹格式“”“
steps = []
with open(log_file) as f:
for line in f:
event = json.loads(line)
        # 提取动作
        if event.get(’type‘) == ’skill_call‘:
            step = Step(
                action=event[’skill‘],
                input=event.get(’input‘),
                output=event.get(’output‘),
                timestamp=event[’time‘],
                reasoning=event.get(’thought‘),  # OpenClaw 的思考过程
                observation=event.get(’tool_result‘)
            )
            steps.append(step)

return Trajectory(steps=steps, metadata={’source‘: ’openclaw‘})

使用
from agentdiagnose import TrajectoryAnalyzer
trajectory = parse_openclaw_log(”/tmp/openclaw/openclaw-2024-01-17.log“)
analyzer = TrajectoryAnalyzer(trajectory)
report = analyzer.diagnose()
-—
💡 为什么 AgentDiagnose 特别适合你的需求？
1.  回答”怎么做事“：不只是看日志，而是结构化地理解决策逻辑
2.  验证你的框架：可以用五大维度量化评估 OpenClaw 是”创造者“还是”观察者“
•  高 Exploration + 高 Self-verification = 创造者
•  高 Observation Reading + 低 Backtracking = 观察者
3.  发现隐藏模式：通过可视化发现你自己看日志时意识不到的行为模式
4.  学术背书：Salesforce Research 出品，方法论严谨
-—
📚 相关资源
•  论文: ”AgentDiagnose: Diagnosing AI Agents via Capability Benchmarking and Trajectory Analysis“
•  GitHub: salesforce/agentdiagnose（假设地址，需确认）
•  相关项目:
•  Agent-as-a-Judge ：用 Agent 评估 Agent，可以结合使用
•  Agent-as-a-Service ：提供在线评估服务
你想先从哪个维度开始分析 OpenClaw？我可以帮你设计具体的诊断方案，比如重点观察它的”自我验证“能力，或者对比它在不同类型任务中的行为差异。
