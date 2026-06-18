# Task: Provider 覆盖测试

基于现有 Go 代码（标准库 net/http + store 文件层），为所有域编写测试。

每个 handler 测试使用 `httptest.NewRecorder` + `httptest.NewRequest`，存储用临时目录。

## 任务

### 1. JWT 工具测试 — internal/auth/jwt_test.go
- TestSignAndVerify: 签发并验证正常 token
- TestVerifyInvalidFormat: 不完整 token 返回错误
- TestVerifyBadSignature: 篡改 token 返回错误
- TestVerifyExpired: 过期 token 返回错误

### 2. Store 测试 — internal/store/filestore_test.go
- TestCreateAndGet: 创建记录后能获取
- TestList: 空集合返回空列表，有数据返回排序结果
- TestUpdate: 更新后数据一致
- TestDelete: 删除后获取返回 not found
- TestConcurrency: 并发读写不 panic（`go test -race`）

### 3. Human API 测试 — internal/api/human_test.go
- TestHealth: GET /health 返回 200
- TestEmployeeCRUD: 完整 CRUD 流程（Create → Get → List → Update → Delete）
- TestEmployeeValidation: 创建员工缺少 name 返回 400
- TestDepartmentCRUD: 部门 CRUD
- TestPositionCRUD: 岗位 CRUD

### 4. Auth API 测试 — internal/api/auth_test.go
- TestRegisterAndLogin: 注册后登录成功
- TestLoginInvalid: 错误密码返回 401
- TestAuthMiddleware: 无 token 返回 401，有效 token 通过

### 5. Connect API 测试 — internal/api/connect_test.go
- TestNotifyAndList: 发送通知后历史中有记录
- TestNotifyValidation: 缺少字段返回 400

### 6. Business API 测试 — internal/api/business_test.go
- TestProjectCRUD: 咨询项目完整 CRUD
- TestProjectStageTransition: 阶段流转
- TestCourseCRUD: 课程完整 CRUD
- TestResourceStatusUpdate: 资源状态更新
- TestDatasetCRUD: 数据集 CRUD
- TestResumeFlow: 简历导入 → 阶段流转 → 面试 → 反馈

### 规范
- 使用 `testing` 标准包
- 每个 handler 测试通过 `testSetup()` 创建临时 store
- 使用 `httptest` 模拟请求/响应
- 用 `t.Run()` 子测试组织
- 编译 + `go test ./...` + `go vet ./...` 全部通过
