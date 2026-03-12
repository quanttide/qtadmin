# Working - Journal - Diary - Founder

raw format like `raw/2016-03-12_0.md`, split by `_`
merge them to one event file and diary file.
event file name like:`memory/event/2016-03-12.jsonl`
and diary file name like:`journal/diary/2016-03-12.md`

the raw like 
```
# 2026-03-12

在考虑手机端用essay代替handbook，essay比较适合倾诉，handbook才是指导工作的正式参考。

bylaws也可以逐步开始写起来了。这样可以给团队提供清晰的示范。

我在考虑建一个从内部到外部的工作流。比如说，我在本地连通飞书知识库和GitHub。

我对这个产品的想象是，我在 data 文件夹里下载飞书知识库的数据到本地，然后下载 GitHub 仓库，然后半自动化地编辑这个知识库，再让 AI 帮忙自动提交。一会半会开发不出来的功能可以请 AI 帮忙代劳。模型还是更喜欢 DeepSeek，得去百炼重新配一下模型参数。然后得把百炼加入收藏夹。也可以看看能不能用命令行直接配，配合网页版检查。这样也可以逐渐地了解 opencode 的能力，也不要完全信任。

AI 的协议考虑移到基础设施标准里。因为感觉 AI 的社区标准很成熟，不需要我从头造。从云计算标准改为基础设施标准以后，这个标准可以更纯粹地兼容外部协议而不需要纠结各种细节。

比如说屏蔽供应商细节就是一个不错的需求。

我刚才又想了一遍工作日志有利于外化想法和帮助团队接入工作流的想法。

工作札记还是要尽快创建，感觉工作档案里已经比较拥挤了。工作手册又还不太顺利。明显工作日志到工作档案的流程很顺利，工作档案到札记的流程也有一定可能会顺利。

RuyiX 的想法很有意思，刚好是我希望整合进通用知识工作平台的方案。在尝试看能不能深度合作，不能就看其他替代或者看情况决定怎么自研替代方案。
 file:///private/var/mobile/Containers/Shared/AppGroup/61ED6C34-36F7-4BDE-915B-74105500012B/File%20Provider%20Storage/Repositories/quanttide-journal-of-founder/daily/2026-03-12_1.md
``

prompt:

```
这是原始文件，我们现在要提取其中的事件记忆
```

define `Event` model:
- id: uuid
- title: str
- description: str
it is not the final version.


the event like
```json
[
  {
    ”title“: ”文档策略调整“,
    ”description“: ”考虑在手机端用 essay（随笔）替代 handbook（手册），因为 essay 更适合个人倾诉和灵感记录，而 handbook 应作为团队正式的工作参考文档。“
  },
  {
    ”title“: ”bylaws 编写启动“,
    ”description“: ”计划逐步开始编写 bylaws（规章制度），旨在为团队提供清晰的行为准则和操作示范，规范内部管理。“
  },
  {
    ”title“: ”工作流构想“,
    ”description“: ”设想建立从内部到外部的工作流，即在本地连通飞书知识库和 GitHub 仓库，实现数据下载、半自动化编辑，并借助 AI 自动提交，以提升知识管理效率。“
  },
  {
    ”title“: ”AI 工具配置“,
    ”description“: ”偏好使用 DeepSeek 模型，需前往阿里云百炼重新配置模型参数，并将百炼加入浏览器收藏夹；同时探索命令行配置方式，结合网页版检查，以逐步了解 opencode 能力，避免完全依赖单一工具。“
  },
  {
    ”title“: ”标准调整“,
    ”description“: ”考虑将 AI 相关协议从“云计算标准”移至“基础设施标准”，因为 AI 社区标准已成熟，无需自研；改为基础设施标准后可更纯粹地兼容外部协议，屏蔽供应商细节，增强通用性。“
  },
  {
    ”title“: ”工作日志价值重申“,
    ”description“: ”重新认识到工作日志有助于外化个人想法，帮助团队快速接入工作流，促进信息同步和协作。“
  },
  {
    ”title“: ”工作札记创建计划“,
    ”description“: ”尽快创建“工作札记”，以缓解工作档案的拥挤，并应对工作手册进展不顺；观察到工作日志→工作档案流程顺畅，推测工作档案→札记也可能顺利，形成良性知识沉淀路径。“
  },
  {
    ”title“: ”RuyiX 合作评估“,
    ”description“: ”对 RuyiX 的想法感兴趣，希望将其整合进通用知识工作平台；目前正在尝试深度合作，若不可行则考虑替代方案或根据情况决定自研。“
  }
]
```

process to a cleaer version：
```
使用这个事件记忆生成一个新的工作日志，保留raw flow and raw content 但是清洗干净express
```

result

```
2026-03-12

今天梳理了几个关于工作方式和工具链的想法，记录一下。

文档体系调整

手机端写东西越来越频繁，发现用 essay 的形式比 handbook 顺手多了。essay 更适合倾诉和捕捉灵感，不需要太正式；而 handbook 还是应该作为团队的正式参考文档，保持结构化和权威性。所以打算把手机端的写作默认设为 essay，handbook 则留在电脑上集中编写。

另外，bylaws 也可以开始动笔了。规章制度需要给团队清晰的示范，早点写出来有助于规范大家的操作，减少沟通成本。

工作流与技术配置

一直在想怎么打通内部知识库和外部代码仓库。理想的工作流是：在本地把飞书知识库的数据同步下来，同时拉取 GitHub 仓库，然后半自动化地编辑内容，最后让 AI 帮忙自动提交 PR。这样既能利用飞书的协作便利，又能把沉淀下来的东西开源出去。短期内开发不出来的部分，可以让 AI 代劳。

模型还是更习惯 DeepSeek，得去阿里云百炼重新配一下参数。顺便把百炼加到收藏夹，方便访问。也想试试用命令行直接配置，结合网页版检查，这样对 opencode 的能力边界会有更直观的了解——不能完全信任工具，得自己掌握主动权。

标准与协议

之前把 AI 相关协议放在“云计算标准”里，现在觉得不太合适。AI 的社区标准已经很成熟了，没必要自己再造轮子。准备挪到“基础设施标准”里，这样标准可以更纯粹地兼容外部协议，聚焦在屏蔽供应商细节上，增强通用性。

知识沉淀与协作

最近越发觉得工作日志是个好东西。不仅能帮自己外化想法，还能让团队快速了解我的思考，接入工作流也更顺畅。现在工作档案里内容有点挤，工作手册进展又不太顺，所以打算尽快开辟一个“工作札记”板块。目前看工作日志→工作档案的流程很顺，工作档案→札记应该也能走通，形成一条良性的知识沉淀路径。

关于 RuyiX

RuyiX 的想法很有意思，刚好跟我想要的通用知识工作平台方向吻合。正在尝试跟他们深度合作，如果谈不成，再看有没有其他替代方案，或者根据情况决定自研。总之这块值得持续跟进。

—

今天就记这些，明天继续推进 bylaws 和工具链的实验。
```
write a example python module first.
`examples/work/journal.py`

检查：

检查原始文本和润色文本，看看是否有信息丢失

检查结果：

```json
[
  {
    "original_point": "手机端用 essay 代替 handbook",
    "covered_in_polished": true,
    "note": "明确说明 essay 适合灵感记录，handbook 作为正式文档"
  },
  {
    "original_point": "bylaws 编写启动",
    "covered_in_polished": true,
    "note": "提及为团队提供示范，规范操作"
  },
  {
    "original_point": "打通飞书知识库和 GitHub 的工作流构想",
    "covered_in_polished": true,
    "note": "涵盖本地同步、半自动化编辑、AI 自动提交 PR"
  },
  {
    "original_point": "偏好 DeepSeek，配置百炼",
    "covered_in_polished": true,
    "note": "提到阿里云百炼、参数配置、命令行探索、opencode 能力边界"
  },
  {
    "original_point": "AI 协议移至基础设施标准",
    "covered_in_polished": true,
    "note": "解释原因：社区标准成熟，屏蔽供应商细节"
  },
  {
    "original_point": "工作日志价值",
    "covered_in_polished": true,
    "note": "外化想法，帮助团队接入工作流"
  },
  {
    "original_point": "工作札记创建计划",
    "covered_in_polished": true,
    "note": "缓解档案拥挤，形成知识沉淀路径"
  },
  {
    "original_point": "RuyiX 合作评估",
    "covered_in_polished": true,
    "note": "尝试深度合作，否则考虑替代或自研"
  }
]
```
