# Work - Journal

This module aims to find event from journal. 
Journal is a event log. It is collected at any time, so it is dirty.
We want to find event memory as knowledge card from the journal,
so that we can cleary understand what happened in the past.

source from `data/asset/quanttide-journal-of-founder`
output to `data/work/event`

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

这是原始文件，我们现在要提取其中的事件记忆

define `Event` model:
- id
- type
- title
- description
- raw
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

write a example python module first.
