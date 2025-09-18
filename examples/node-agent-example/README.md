# 天气智能体示例

> 第三方智能体开发示例 - 基于 Node.js 的天气查询智能体

## 概述

本示例展示了如何开发一个第三方智能体并集成到 Context Server 中。该智能体提供简单的天气查询功能，支持北京、上海、广州、深圳四个城市的天气信息。

## 快速开始

### 1. 安装依赖

```bash
cd examples/node-agent-example
npm install
```

### 2. 启动智能体服务

```bash
npm start
```

服务将在 http://localhost:3001 启动。

### 3. 注册到 Context Server

确保 Context Server 正在运行，然后注册智能体：

```bash
curl -X POST http://localhost:3000/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "weather-agent",
    "description": "天气查询智能体 - 支持北京、上海、广州、深圳的天气查询",
    "llmTag": "weather_llm",
    "toolCategories": ["weather", "general"],
    "endpointUrl": "http://localhost:3001/weather-agent",
    "endpointMethod": "POST",
    "endpointTimeout": 10000
  }'
```

### 4. 测试智能体

通过 Context Server 测试智能体：

```bash
curl -X POST http://localhost:3000/api/agui \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-weather",
    "messages": [{
      "id": "msg1",
      "role": "user",
      "content": "北京今天天气怎么样？"
    }]
  }'
```

## 接口规范

### 请求格式

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

### 响应格式

```json
{
  "content": "智能体回复内容",
  "toolCalls": [
    {
      "id": "tool_call_id",
      "name": "tool_name",
      "parameters": {}
    }
  ]
}
```

## 功能特性

- ✅ 支持天气查询关键词识别
- ✅ 支持多城市天气信息
- ✅ 返回结构化工具调用信息
- ✅ 错误处理和异常响应
- ✅ 健康检查接口

## 开发说明

### 核心逻辑

1. **消息解析**：从请求中提取用户消息
2. **意图识别**：检测天气查询关键词
3. **城市识别**：从用户输入中提取城市名称
4. **数据查询**：返回对应城市的天气信息
5. **响应构建**：返回文本回复和工具调用信息

### 扩展建议

- 接入真实天气 API
- 支持更多城市和地区
- 添加天气预报功能
- 实现自然语言理解优化

## 管理操作

```bash
# 查看智能体状态
curl http://localhost:3000/api/agents

# 更新智能体
curl -X PUT http://localhost:3000/api/agents/{id} \
  -H "Content-Type: application/json" \
  -d '{"description": "更新后的描述"}'

# 删除智能体
curl -X DELETE http://localhost:3000/api/agents/{id}
```

## 故障排除

### 常见问题

1. **端口占用**：修改 `server.js` 中的 `PORT` 变量
2. **注册失败**：确保 Context Server 正在运行且网络可达
3. **请求超时**：检查 `endpointTimeout` 配置

### 日志调试

启动服务后查看控制台输出，包含详细的请求和响应信息。