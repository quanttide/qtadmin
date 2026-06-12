# QuantTide HR 用户指南

## 这套东西是干什么的

公司招聘邮箱每天会收到大量简历邮件。这个工具帮你：

1. **自动识别**邮件里的候选人信息（姓名、应聘职位）
2. **自动归类**到招聘流程的对应阶段（新联系、笔试中、面试中...）
3. **推送到系统**里，HR 确认后在看板上统一查看和管理

数据来自**真实飞书邮箱**，通过 `lark-cli` 拉取，`qtadmin human` 推送到本地服务端。

---

## 系统架构

两个仓库配合使用：

```
quanttide-hr-toolkit-main/          ← 后端 + 看板（本仓库）
├── packages/fastapi/               ← FastAPI 库包（领域模型 + API）
├── integrations/feishu/            ← 飞书邮件拉取集成（服务端自动轮询用）
└── packages/examples/provider/     ← 宿主应用（app.py + Web 看板）

qtadmin-human-cli/                  ← CLI 工具（独立仓库）
└── qtadmin human                   ← 封装 lark-cli 的 HR 操作命令行
```

### 数据流

```
lark-cli（本地安装并登录飞书）
    │
    ▼
qtadmin human mail list       ← 拉取飞书邮件，终端预览分类
qtadmin human mail ingest     ← POST /ingest → 服务端待确认队列
                                           │
                                   Web 看板（HR 确认/调整/忽略）
                                           │
                                   └── 确认 → 创建候选人 → Pipeline 看板
```

---

## 快速开始（连接飞书）

### 前置要求

- Python >= 3.12
- Node.js >= 18（用于安装飞书官方 CLI）

### 1. 安装飞书 CLI（lark-cli）

> **注意**：请使用 npm 安装 `@larksuite/cli`。PyPI 上的 `lark-cli` 是另一个无关包，不能用于飞书邮箱。

```bash
npm install -g @larksuite/cli
```

验证安装：

```bash
lark-cli --version
# 应输出类似: lark-cli version 1.0.52
```

### 2. 初始化飞书应用并登录

```bash
lark-cli config init --new
```

执行后终端会显示一个二维码和链接。用**飞书扫描二维码**或在浏览器中打开链接，按指引创建应用。创建成功后终端会显示：

```
OK: 应用配置成功! App ID: cli_xxxxxxxxxxxxxxxx
```

> **注意**：如果你之前用企业飞书账号创建过应用但权限不足、或个人账号无法登录，请用个人飞书账号重新执行 `lark-cli config init --new` 创建一个新应用。

登录授权邮件读取权限：

```bash
lark-cli auth login --domain mail --recommend
```

授权成功后显示：

```
OK: 授权成功! 用户: xxx (ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
```

验证登录状态和权限：

```bash
lark-cli auth status
```

确认输出中包含以下邮件相关权限：

- `mail:user_mailbox:readonly`
- `mail:user_mailbox.message.subject:read`
- `mail:user_mailbox.message.body:read`
- `mail:user_mailbox.mail_contact:read`
- `mail:user_mailbox.message.address:read`

测试邮箱连接（`--mailbox` 可省略，默认读取当前登录用户邮箱）：

```bash
lark-cli mail +triage --format json --max 5
```

查询你的飞书邮箱地址（用于后续配置）：

```bash
lark-cli mail user_mailboxes profile --params '{"user_mailbox_id":"me"}' --format json
# 返回 data.primary_email_address 即为邮箱地址
```

### 3. 安装后端依赖

在仓库根目录下依次安装三个 Python 包：

```bash
cd quanttide-hr-toolkit-main/packages/fastapi
pip install -e .

cd ../../integrations/feishu
pip install -e .

cd ../../packages/examples/provider
pip install -e .
```

### 4. 安装 CLI 工具

```bash
cd qtadmin-human-cli
pip install -e .

qtadmin --version
# 应输出: qtadmin 2.0.0
```

### 5. 启动服务

```bash
cd quanttide-hr-toolkit-main/packages/examples/provider
uvicorn app:app --host 0.0.0.0 --port 8000
```

首次启动会在 `quanttide-hr-toolkit-main/data/sqlite/` 下创建空数据库（不含模拟数据）。

浏览器打开 `http://localhost:8000`，即可看到：

| 区域 | 说明 |
|------|------|
| **左侧：确认队列** | 新邮件分类结果，HR 确认/调整/忽略 |
| **中间：看板** | 8 阶段招聘管道，候选人卡片按阶段排列 |
| **右侧：人才库** | 已入库的候选人（关闭后可重新出池） |

### 6. 配置 qtadmin 并拉取邮件

```bash
# 配置服务端地址
qtadmin config set-provider http://localhost:8000

# 配置飞书邮箱（替换为上一步查到的 primary_email_address）
qtadmin config set-mailbox "yourname@company.com"

# 验证连通性
qtadmin human status pending

# 查看收件箱中的招聘邮件
qtadmin human mail list

# 推送到服务端（进入待确认队列）
qtadmin human mail ingest
```

推送后在浏览器刷新 `http://localhost:8000`，左侧确认队列即可看到邮件。

---

## Windows 额外配置

在 Windows 上可能遇到以下问题，按顺序检查：

### lark-cli 找不到（FileNotFoundError）

npm 全局安装的 `lark-cli` 是 `.cmd` 脚本，Python 子进程无法直接调用 `lark-cli`。需指定完整路径：

```powershell
# 查找路径
where.exe lark-cli
# 通常位于 C:\Users\<用户名>\AppData\Roaming\npm\lark-cli.cmd

qtadmin config set-lark-path "C:\Users\<用户名>\AppData\Roaming\npm\lark-cli.cmd"
```

### 中文邮件乱码 / JSON 解析失败

设置 UTF-8 模式后再运行 qtadmin：

```powershell
$env:PYTHONUTF8 = "1"
qtadmin human mail list
```

建议写入用户环境变量，长期生效。

### qtadmin 访问本地服务返回 502

若系统配置了 HTTP 代理，Python 请求 `127.0.0.1` 可能被代理拦截。设置：

```powershell
$env:NO_PROXY = "127.0.0.1,localhost"
qtadmin human status pending
```

### 环境变量写法

文档中 Linux/macOS 的 `export VAR=value` 在 PowerShell 中对应：

```powershell
$env:QTADMIN_MAILBOX = "yourname@company.com"
$env:QTADMIN_DATA_DIR = "D:\hr-data"   # 可选，自定义数据目录
```

---

## CLI 命令一览

```bash
qtadmin config set-provider <url>      # 配置服务端地址
qtadmin config set-lark-path <path>    # 配置 lark-cli 路径（Windows 常用）
qtadmin config set-mailbox <email>     # 配置飞书邮箱
qtadmin config show                    # 查看当前配置

qtadmin human mail list                # 列出收件箱中的招聘邮件
qtadmin human mail classify <id>       # 预览单封邮件的分类详情
qtadmin human mail ingest              # 推送分类结果到服务端
qtadmin human mail send                # 发送待发邮件
qtadmin human status pending           # 查看服务端待确认队列数量
```

---

## 自动轮询模式（可选）

如果设置了 `QTADMIN_MAILBOX` 环境变量，服务端会每 5 分钟自动通过 lark-cli 拉取新邮件：

```bash
# Linux/macOS
export QTADMIN_MAILBOX="yourname@company.com"
uvicorn app:app --host 0.0.0.0 --port 8000

# Windows PowerShell
$env:QTADMIN_MAILBOX = "yourname@company.com"
uvicorn app:app --host 0.0.0.0 --port 8000
```

手动推送（`qtadmin human mail ingest`）与自动轮询可二选一，也可同时使用。

---

## 日常使用

### 1. 处理待确认邮件

队列中每封邮件显示：主题、发件人、建议状态、置信度。

操作：
- **确认** — 接受系统建议，推入看板对应阶段
- **调整** — 修改阶段/姓名/邮箱后再推入
- **忽略** — 丢弃该邮件（不是候选人）

### 2. 查看和推进候选人

在看板中点击候选人卡片，详情面板展示：
- 基本信息（姓名、邮箱、当前阶段、子阶段、质量标记）
- 飞书邮件原文（关联的原始邮件）
- 阶段结果（各阶段通过/淘汰记录）
- **阶段变更** — 点击目标阶段按钮推进（系统自动校验跳转合法性）

### 3. 人才库管理

已关闭的候选人进入人才库，可以：
- 查看候选人信息和入池记录
- **出池** — 重新分配到新的招聘批次

---

## 状态说明

八个阶段及允许的跳转：

```
新进入       → 已联系 / 关闭
已联系       → 已发卷 / 关闭
已发卷       → 已收卷 / 关闭
已收卷       → 评卷中 / 关闭
评卷中       → 面试 / 已发卷（重评）/ 关闭
面试         → 发Offer / 关闭
发Offer      → 关闭
关闭         → （终态，不可跳转）
```

---

## 故障排除

### lark-cli 报 "permission denied" / 4017

当前应用可能是用企业账号创建的，个人账号没有权限。重新创建：

```bash
lark-cli config init --new
# 用个人飞书扫码创建
lark-cli auth login --domain mail --recommend
# 再用个人飞书扫码授权
```

### lark-cli 报 "mailbox not found"

邮箱地址不对，或该邮箱未在飞书开通邮箱功能。在飞书「设置」→「账号与安全」→「邮箱」中确认，或用 `lark-cli mail user_mailboxes profile` 查询正确地址。

### lark-cli 返回 JSON 解析错误

升级到最新版：`npm update -g @larksuite/cli`

### qtadmin 报 "Provider URL not configured"

运行 `qtadmin config set-provider http://localhost:8000` 设置服务端地址。

### qtadmin 报 FileNotFoundError（Windows）

见上文 [Windows 额外配置](#windows-额外配置)，设置 `lark-cli.cmd` 完整路径。

### qtadmin 报 HTTP 502 访问本地服务

见上文 [Windows 额外配置](#windows-额外配置)，设置 `NO_PROXY=127.0.0.1,localhost`。

### 推送后看板没有数据

1. 确认后端运行：`curl http://localhost:8000/queue`
2. 检查队列状态：`qtadmin human status pending`
3. 推送后再刷新页面

### 推完后报 404

后台没启动。确认 `uvicorn app:app` 还在运行。

### 重置数据

```bash
# 删除数据库和附件（路径相对于 quanttide-hr-toolkit-main）
rm -rf quanttide-hr-toolkit-main/data/
# 重启 uvicorn，自动创建空数据库
```

Windows PowerShell：

```powershell
Remove-Item -Recurse -Force quanttide-hr-toolkit-main\data\
```

### 分类不准

CLI 本地预览分类规则在 `qtadmin-human-cli/src/qtadmin/classifier.py`，编辑后重启终端生效。服务端分类在 `quanttide-hr-toolkit-main/packages/fastapi/src/fastapi_quanttide_hr/services/classifier.py`，修改后重启 uvicorn 生效。
