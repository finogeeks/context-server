const express = require('express');
const app = express();
const PORT = 3001;

// 中间件
app.use(express.json());

// 模拟天气数据
const weatherData = {
  '北京': { temperature: 22, weather: '晴朗', humidity: '45%' },
  '上海': { temperature: 26, weather: '多云', humidity: '60%' },
  '广州': { temperature: 30, weather: '小雨', humidity: '75%' },
  '深圳': { temperature: 28, weather: '晴朗', humidity: '65%' }
};

// 天气智能体主接口
app.post('/weather-agent', (req, res) => {
  try {
    const { messages, tools, context } = req.body;
    console.log('收到请求:', { messagesCount: messages?.length, context });

    // 获取最新用户消息
    const latestMessage = messages?.find(m => m.role === 'user');
    if (!latestMessage) {
      return res.json({
        content: '抱歉，我没有收到有效的用户消息。'
      });
    }

    const userInput = latestMessage.content;
    console.log('用户输入:', userInput);

    // 简单的天气查询逻辑
    const response = processWeatherQuery(userInput);

    console.log('智能体响应:', response);
    res.json(response);

  } catch (error) {
    console.error('处理请求出错:', error);
    res.status(500).json({
      content: '抱歉，处理您的请求时出现了错误，请稍后重试。'
    });
  }
});

// 处理天气查询逻辑
function processWeatherQuery(input) {
  // 检查是否包含天气相关关键词
  const weatherKeywords = ['天气', '温度', '下雨', '晴天', '阴天'];
  const hasWeatherKeyword = weatherKeywords.some(keyword => input.includes(keyword));

  if (!hasWeatherKeyword) {
    return {
      content: '我是天气助手，专门帮您查询天气信息。请告诉我您想了解哪个城市的天气？'
    };
  }

  // 提取城市名称
  const cities = Object.keys(weatherData);
  const mentionedCity = cities.find(city => input.includes(city));

  if (mentionedCity) {
    const weather = weatherData[mentionedCity];
    return {
      content: `${mentionedCity}今天的天气情况：\n🌡️ 温度：${weather.temperature}°C\n☁️ 天气：${weather.weather}\n💧 湿度：${weather.humidity}`,
      toolCalls: [{
        id: `weather_query_${Date.now()}`,
        name: 'get_weather',
        parameters: {
          city: mentionedCity,
          ...weather
        }
      }]
    };
  }

  // 如果没有识别到具体城市，提供帮助
  const availableCities = cities.join('、');
  return {
    content: `请告诉我您想查询哪个城市的天气？\n目前支持的城市有：${availableCities}`
  };
}

// 健康检查接口
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'weather-agent',
    timestamp: new Date().toISOString()
  });
});

// 启动服务
app.listen(PORT, () => {
  console.log(`🌤️ 天气智能体服务已启动`);
  console.log(`📡 监听端口: ${PORT}`);
  console.log(`🔗 智能体接口: http://localhost:${PORT}/weather-agent`);
  console.log(`❤️ 健康检查: http://localhost:${PORT}/health`);
});