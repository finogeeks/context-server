# Context Server

> 🤖 服务端智能体运行引擎，为移动端应用提供强大的AI智能体能力

## 概述

Context Server 是一个高性能的服务端 AI 智能体编排引擎，专为移动端应用设计。它提供了完整的智能体生态系统，支持多种专业化智能体、工具集成和实时流式响应。

### 架构图

```
移动端应用
    ↓ (集成)
Agentic SDK (iOS/Android)
    ↓ (SSE 长连接)
Context Server
    ↓ (智能体编排)
专业化智能体 + MCP 工具
```

## 快速开始

### 1. 克隆并配置

```bash
# 克隆仓库
git clone git@github.com:finogeeks/context-server.git

# 修改 docker-compose.yml 的配置
- LLM_API_KEY=your_key
- LLM_BASE_URL=https://api.openai.com/v1
- LLM_MODEL=gpt-4o-mini

# 轻量级 LLM 配置(例如 14B 32B 等模型), 用于一些内部轻量级场景。也可以同LLM_API_KEY等配置一样的
- LIGHTWEIGHT_LLM_API_KEY=your_key
- LIGHTWEIGHT_LLM_BASE_URL=https://api.openai.com/v1
- LIGHTWEIGHT_LLM_MODEL=gpt-4o-mini
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

## 自定义Agent

Context Server 支持注册和管理自定义Agent

### Agent接口规范

自定义Agent需要实现以下 HTTP 接口：

**请求格式 (POST /{agent-endpoint}):**
```json
{
  "messages": [
    {
      "id": "string",
      "role": "user|assistant|system",
      "content": "string"
    }
  ],
  "tools": [],
  "context": {}
}
```

**响应格式:**
```json
{
  "content": "智能体回复内容",
  "toolCalls": [
    {
      "id": "string",
      "name": "string",
      "parameters": {}
    }
  ]
}
```

### 注册智能体

```bash
# 注册新智能体
curl -X POST http://localhost:8123/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "weather-agent",
    "description": "天气查询智能体",
    "llmTag": "weather_llm",
    "toolCategories": ["weather", "general"],
    "endpointUrl": "http://your-server.com/agent-endpoint",
    "endpointMethod": "POST",
    "endpointTimeout": 10000
  }'
```

### 管理智能体

```bash
# 查看所有智能体
curl http://localhost:8123/api/agents

# 更新智能体配置
curl -X PUT http://localhost:8123/api/agents/1 \
  -H "Content-Type: application/json" \
  -d '{"description": "更新后的描述"}'

# 删除智能体
curl -X DELETE http://localhost:8123/api/agents/1

# 刷新智能体注册表
curl -X POST http://localhost:8123/api/agents/refresh
```

### 开发示例

参考 `examples/node-agent-example/` 目录中的完整示例实现。