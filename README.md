# Agentic SDK Server

> 🤖 服务端智能体运行引擎，为移动端应用提供强大的AI智能体能力

## 概述

Agentic SDK Server 是一个高性能的服务端 AI 智能体编排引擎，专为移动端应用设计。它提供了完整的智能体生态系统，支持多种专业化智能体、工具集成和实时流式响应。

### 架构图

```
移动端应用
    ↓ (集成)
Agentic SDK (iOS/Android)
    ↓ (SSE 长连接)
Agentic SDK Server
    ↓ (智能体编排)
专业化智能体 + MCP 工具
```

## 快速开始

### 1. Docker Compose 运行

确保已安装 Docker 和 Docker Compose：

```bash
# 检查 Docker 安装
docker --version
docker-compose --version
```

### 2. 克隆并配置

```bash
# 克隆仓库
git clone https://github.com/your-org/agentic-sdk-server.git
cd agentic-sdk-server

# 复制环境配置模板
cp .env.example .env

# 编辑环境变量（必须配置 LLM_API_KEY）
nano .env
```

### 3. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f agentic-server
```

### 4. 验证安装

```bash
# 健康检查
curl http://localhost:3000/health

# 测试 API
curl -N -X POST http://localhost:3000/api/agui \
  -H "Content-Type: application/json" \
  -d '{"threadId":"test-001","message":"Hello, how are you?"}'
```

## 环境配置

### 必需配置

在 `.env` 文件中设置以下必需变量：

```bash
# LLM 服务配置（必需）
LLM_API_KEY=your_llm_api_key_here
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4

# 服务器端口
PORT=3000
```

### 高级配置

```bash
# 轻量级 LLM（用于意图识别等简单任务）
LIGHTWEIGHT_LLM_API_KEY=your_lightweight_llm_api_key
LIGHTWEIGHT_LLM_MODEL=gpt-4o-mini

# 持久化模式
PERSISTENCE_MODE=nats_timescale  # 或 memory

# NATS 配置（生产环境推荐）
NATS_SERVERS=nats://localhost:4222
NATS_MAX_RECONNECT=10

# TimescaleDB 配置
TIMESCALE_HOST=localhost
TIMESCALE_DATABASE=agentic_sessions
TIMESCALE_USER=postgres
TIMESCALE_PASSWORD=your_secure_password
```

## API 文档

### POST /api/agui

智能体对话接口，支持 Server-Sent Events (SSE) 流式响应。

#### 请求格式

```json
{
  "threadId": "my-session-id",
  "message": "你好，请帮我写一个 Python 函数"
}
```

#### 响应格式

流式 SSE 响应：

**1. 开始消息**
```
data: {"type":"start","model":"gpt-4","timestamp":"2025-01-15T10:30:00.000Z"}
```

**2. 内容片段**（多次）
```
data: {"type":"chunk","content":"你好","fullContent":"你好"}
data: {"type":"chunk","content":"！我可以","fullContent":"你好！我可以"}
```

**3. 完成消息**
```
data: {"type":"done","fullContent":"你好！我可以帮你写Python函数...","model":"gpt-4","timestamp":"2025-01-15T10:30:05.000Z"}
```

**4. 错误消息**（如果有）
```
data: {"type":"error","error":"API调用失败","timestamp":"2025-01-15T10:30:02.000Z"}
```

#### 示例请求

```bash
# 实时流式对话
curl -N -X POST http://localhost:3000/api/agui \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "chat-session-001",
    "message": "请帮我分析一下这个错误日志"
  }'
```

### GET /health

服务健康检查端点。

```bash
curl http://localhost:3000/health
# 响应: {"status":"ok","timestamp":"2025-01-15T10:30:00.000Z"}
```

## 部署指南

### 开发环境

使用内存模式进行快速开发：

```bash
# .env 配置
PERSISTENCE_MODE=memory
PORT=3000

# 启动
docker-compose up -d agentic-server
```

### 生产环境

推荐使用完整的持久化配置：

```bash
# .env 生产配置
PERSISTENCE_MODE=nats_timescale
NATS_SERVERS=nats://your-nats-cluster:4222
TIMESCALE_HOST=your-timescale-host
TIMESCALE_PASSWORD=your_secure_password

# 启动所有服务
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 监控和日志

```bash
# 查看实时日志
docker-compose logs -f agentic-server

# NATS 监控面板
open http://localhost:7777

# 数据库管理工具
open http://localhost:8080
```

## LLM 提供商支持

### OpenAI

```bash
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4
LLM_API_KEY=sk-...
```

### Azure OpenAI

```bash
LLM_BASE_URL=https://your-resource.openai.azure.com/openai/deployments/your-deployment
LLM_MODEL=gpt-4
LLM_API_KEY=your-azure-key
```

### 其他 OpenAI 兼容服务

```bash
LLM_BASE_URL=https://api.your-service.com/v1
LLM_MODEL=your-model-name
LLM_API_KEY=your-api-key
```

## 故障排除

### 常见问题

**1. 服务启动失败**
```bash
# 检查端口占用
lsof -i :3000

# 查看详细错误日志
docker-compose logs agentic-server
```

**2. LLM API 调用失败**
```bash
# 验证 API 密钥
curl -H "Authorization: Bearer $LLM_API_KEY" \
  https://api.openai.com/v1/models

# 检查网络连接
docker-compose exec agentic-server ping api.openai.com
```

**3. 数据库连接问题**
```bash
# 检查 TimescaleDB 状态
docker-compose exec timescaledb pg_isready

# 测试连接
docker-compose exec agentic-server nc -zv timescaledb 5432
```

### 性能优化

**1. 内存优化**
```bash
# 调整 TimescaleDB 内存设置
TS_TUNE_MEMORY=1GB
TS_TUNE_NUM_CPUS=4
```

**2. 并发优化**
```bash
# 增加数据库连接池
TIMESCALE_MAX_CONNECTIONS=50

# NATS 连接优化
NATS_MAX_RECONNECT=20
NATS_TIMEOUT=10000
```

## 安全配置

### 生产环境安全清单

- [ ] 更改默认密码
- [ ] 配置 HTTPS 证书
- [ ] 设置防火墙规则
- [ ] 启用访问日志
- [ ] 配置备份策略

### 推荐安全配置

```bash
# 强密码
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# 限制网络访问
# 在 docker-compose.yml 中移除不必要的端口暴露

# 启用 SSL
TIMESCALE_SSL=true
```

## 许可证

MIT License

## 支持

- 📧 Email: support@your-company.com
- 💬 Issues: [GitHub Issues](https://github.com/your-org/agentic-sdk-server/issues)
- 📖 文档: [完整文档](https://docs.your-company.com/agentic-sdk-server)

---

**© 2025 Your Company. 保留所有权利。**