# 人力资源职能

管理员工、部门和岗位信息。

## 使用方式

### 启动 Provider

通过环境变量配置数据存储路径和密钥，启动后端服务：

```bash
source ~/.bashrc
cd src/provider
go run ./cmd/server
```

服务默认监听 `:8000`，数据存储在 `QTADMIN_STORE_PATH` 指定目录。

### 岗位管理

CLI 通过 `--provider` / `-p` 模式调用 Provider API，数据写入服务端统一存储。

创建岗位：

```bash
cd src/cli
cargo run -- --provider human position create \
  --name "全栈工程师" \
  --department "研发部" \
  --description "前后端全栈开发，React + Go"
```

查询岗位列表：

```bash
cargo run -- --provider human position list
```

查询单个岗位：

```bash
cargo run -- --provider human position get <id>
```

输出示例：

```json
[
  {
    "id": "7f47c8731cebc59e51fd86f2f06f0217",
    "name": "全栈工程师",
    "department": "研发部",
    "description": "前后端全栈开发，React + Go"
  }
]
```

### 员工管理

（待接入，当前仅支持岗位的 Provider 模式）

### 部门管理

（待接入，当前仅支持岗位的 Provider 模式）

## 数据存储

Provider 将数据持久化到本地文件系统，按集合分文件存储：

```
$QTADMIN_STORE_PATH/
  human/
    positions.json
    employees.json
    departments.json
```

每个 JSON 文件格式为 `{"records": {"id": {...}}}`，可用脚本手动备份到对象存储。
