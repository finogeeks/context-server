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

### 1. 克隆并配置

```bash
# 克隆仓库
git clone https://github.com/your-org/agentic-sdk-server.git
cd agentic-sdk-server

# 修改 docker-compose.yml 的配置
- LLM_API_KEY=your_model
- LLM_BASE_URL=https://api.openai.com/v1
- LLM_MODEL=gpt-4o-mini

# 轻量级 LLM 配置(14B 模型), 用于一些内部轻量级场景。也可以同LLM_API_KEY等配置一样的
- LIGHTWEIGHT_LLM_API_KEY=${LIGHTWEIGHT_LLM_API_KEY:-${LLM_API_KEY}}
- LIGHTWEIGHT_LLM_BASE_URL=${LIGHTWEIGHT_LLM_BASE_URL:-${LLM_BASE_URL}}
- LIGHTWEIGHT_LLM_MODEL=${LIGHTWEIGHT_LLM_MODEL:-gpt-4o-mini}
```

### 2. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 3. 验证安装

```bash
# 测试 API
curl --location --request POST 'http://113.105.90.181:30301/api/agui' \
--header 'Content-Type: application/json' \
--data-raw '{
      "threadId": "hello",
      "messages": [
        {
          "id": "id1", 
          "role": "user",
          "content": "你好"
        }
      ]
    }'
```