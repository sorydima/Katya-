# Katya API WebSocket

## Обзор

Katya API предоставляет WebSocket подключения для получения обновлений в реальном времени. WebSocket позволяет получать события, метрики и уведомления без необходимости постоянного опроса API.

## Подключение

### URL подключения

```
wss://api.katya.wtf/v1/ws
```

### Аутентификация

WebSocket поддерживает следующие методы аутентификации:

#### Bearer Token

```javascript
const ws = new WebSocket('wss://api.katya.wtf/v1/ws', {
  headers: {
    'Authorization': 'Bearer YOUR_ACCESS_TOKEN'
  }
});
```

#### Query Parameter

```javascript
const ws = new WebSocket('wss://api.katya.wtf/v1/ws?token=YOUR_ACCESS_TOKEN');
```

#### Подключение после установления соединения

```javascript
const ws = new WebSocket('wss://api.katya.wtf/v1/ws');

ws.onopen = function() {
  // Отправляем сообщение аутентификации
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'YOUR_ACCESS_TOKEN'
  }));
};
```

## Формат сообщений

### Структура сообщения

```json
{
  "type": "event|response|error|ping|pong",
  "id": "message_id_123",
  "timestamp": "2024-01-01T12:00:00Z",
  "data": {
    // Данные в зависимости от типа сообщения
  }
}
```

### Типы сообщений

| Тип | Описание |
|-----|----------|
| `event` | Событие от системы |
| `response` | Ответ на запрос |
| `error` | Ошибка |
| `ping` | Ping от сервера |
| `pong` | Pong от клиента |

## Подписка на события

### Подписка на каналы

```javascript
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: ['messages', 'alerts', 'metrics']
}));
```

### Отписка от каналов

```javascript
ws.send(JSON.stringify({
  type: 'unsubscribe',
  channels: ['messages', 'alerts']
}));
```

### Подписка на конкретные события

```javascript
ws.send(JSON.stringify({
  type: 'subscribe',
  events: [
    'message.created',
    'message.updated',
    'trust.verification.created',
    'security.alert.created'
  ]
}));
```

## Доступные каналы

### Сообщения (`messages`)

События, связанные с сообщениями:

- `message.created` - Создано новое сообщение
- `message.updated` - Обновлено сообщение
- `message.deleted` - Удалено сообщение

### Комнаты (`rooms`)

События, связанные с комнатами:

- `room.created` - Создана новая комната
- `room.updated` - Обновлена комната
- `room.member.joined` - Пользователь присоединился
- `room.member.left` - Пользователь покинул комнату

### Сеть доверия (`trust`)

События, связанные с сетью доверия:

- `trust.identity.created` - Создана идентичность
- `trust.identity.updated` - Обновлена идентичность
- `trust.verification.created` - Создана верификация
- `trust.verification.updated` - Обновлена верификация
- `trust.reputation.updated` - Обновлена репутация

### Аналитика (`analytics`)

События, связанные с аналитикой:

- `analytics.metric.updated` - Обновлена метрика
- `analytics.report.created` - Создан отчет
- `analytics.report.completed` - Завершен отчет

### Безопасность (`security`)

События, связанные с безопасностью:

- `security.alert.created` - Создан алерт
- `security.alert.updated` - Обновлен алерт
- `security.scan.started` - Начато сканирование
- `security.scan.completed` - Завершено сканирование

### Система (`system`)

Системные события:

- `system.status.changed` - Изменен статус системы
- `system.maintenance.start` - Начато обслуживание
- `system.maintenance.end` - Завершено обслуживание

## Примеры событий

### Новое сообщение

```json
{
  "type": "event",
  "id": "evt_123",
  "timestamp": "2024-01-01T12:00:00Z",
  "event": "message.created",
  "channel": "messages",
  "data": {
    "id": "msg_456",
    "roomId": "room_789",
    "senderId": "user_101",
    "senderName": "Alice",
    "content": "Hello, world!",
    "messageType": "text",
    "createdAt": "2024-01-01T12:00:00Z",
    "metadata": {
      "priority": "normal",
      "encrypted": true
    }
  }
}
```

### Алерт безопасности

```json
{
  "type": "event",
  "id": "evt_124",
  "timestamp": "2024-01-01T12:01:00Z",
  "event": "security.alert.created",
  "channel": "security",
  "data": {
    "id": "alert_789",
    "title": "Suspicious login attempt",
    "description": "Multiple failed login attempts detected",
    "severity": "high",
    "category": "authentication",
    "source": "192.168.1.100",
    "createdAt": "2024-01-01T12:01:00Z",
    "metadata": {
      "userId": "user_123",
      "attempts": 5,
      "timeWindow": "5m"
    }
  }
}
```

### Обновление метрики

```json
{
  "type": "event",
  "id": "evt_125",
  "timestamp": "2024-01-01T12:02:00Z",
  "event": "analytics.metric.updated",
  "channel": "analytics",
  "data": {
    "name": "cpu_usage",
    "value": 75.5,
    "unit": "percent",
    "timestamp": "2024-01-01T12:02:00Z",
    "metadata": {
      "server": "web-01",
      "region": "us-east-1"
    }
  }
}
```

## JavaScript клиент

### Простое подключение

```javascript
const ws = new WebSocket('wss://api.katya.wtf/v1/ws?token=YOUR_ACCESS_TOKEN');

ws.onopen = function() {
  console.log('Connected to Katya WebSocket');
  
  // Подписываемся на события
  ws.send(JSON.stringify({
    type: 'subscribe',
    channels: ['messages', 'alerts', 'metrics']
  }));
};

ws.onmessage = function(event) {
  const message = JSON.parse(event.data);
  
  switch (message.type) {
    case 'event':
      handleEvent(message);
      break;
    case 'ping':
      // Отвечаем на ping
      ws.send(JSON.stringify({ type: 'pong' }));
      break;
    case 'error':
      console.error('WebSocket error:', message.data);
      break;
  }
};

ws.onclose = function(event) {
  console.log('WebSocket closed:', event.code, event.reason);
};

ws.onerror = function(error) {
  console.error('WebSocket error:', error);
};

function handleEvent(message) {
  console.log(`Received event: ${message.event}`, message.data);
  
  switch (message.event) {
    case 'message.created':
      displayNewMessage(message.data);
      break;
    case 'security.alert.created':
      showSecurityAlert(message.data);
      break;
    case 'analytics.metric.updated':
      updateMetric(message.data);
      break;
  }
}

function displayNewMessage(message) {
  const messageElement = document.createElement('div');
  messageElement.className = 'message';
  messageElement.innerHTML = `
    <div class="sender">${message.senderName}</div>
    <div class="content">${message.content}</div>
    <div class="timestamp">${new Date(message.createdAt).toLocaleTimeString()}</div>
  `;
  document.getElementById('messages').appendChild(messageElement);
}

function showSecurityAlert(alert) {
  const alertElement = document.createElement('div');
  alertElement.className = `alert alert-${alert.severity}`;
  alertElement.innerHTML = `
    <div class="alert-title">${alert.title}</div>
    <div class="alert-description">${alert.description}</div>
  `;
  document.getElementById('alerts').appendChild(alertElement);
}

function updateMetric(metric) {
  const metricElement = document.getElementById(`metric-${metric.name}`);
  if (metricElement) {
    metricElement.textContent = `${metric.value}${metric.unit}`;
  }
}
```

### Расширенный клиент с переподключением

```javascript
class KatyaWebSocketClient {
  constructor(options = {}) {
    this.url = options.url || 'wss://api.katya.wtf/v1/ws';
    this.token = options.token;
    this.channels = options.channels || [];
    this.events = options.events || [];
    this.autoReconnect = options.autoReconnect !== false;
    this.reconnectInterval = options.reconnectInterval || 5000;
    this.maxReconnectAttempts = options.maxReconnectAttempts || 10;
    
    this.ws = null;
    this.reconnectAttempts = 0;
    this.isConnecting = false;
    this.eventHandlers = new Map();
    
    this.connect();
  }
  
  connect() {
    if (this.isConnecting || this.ws?.readyState === WebSocket.OPEN) {
      return;
    }
    
    this.isConnecting = true;
    
    try {
      const wsUrl = new URL(this.url);
      if (this.token) {
        wsUrl.searchParams.set('token', this.token);
      }
      
      this.ws = new WebSocket(wsUrl.toString());
      this.setupEventListeners();
    } catch (error) {
      console.error('Failed to create WebSocket:', error);
      this.isConnecting = false;
      this.scheduleReconnect();
    }
  }
  
  setupEventListeners() {
    this.ws.onopen = () => {
      console.log('Connected to Katya WebSocket');
      this.isConnecting = false;
      this.reconnectAttempts = 0;
      
      // Подписываемся на каналы и события
      if (this.channels.length > 0) {
        this.subscribe(this.channels);
      }
      
      if (this.events.length > 0) {
        this.subscribeToEvents(this.events);
      }
      
      this.emit('connected');
    };
    
    this.ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        this.handleMessage(message);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };
    
    this.ws.onclose = (event) => {
      console.log('WebSocket closed:', event.code, event.reason);
      this.isConnecting = false;
      this.emit('disconnected', { code: event.code, reason: event.reason });
      
      if (this.autoReconnect && event.code !== 1000) {
        this.scheduleReconnect();
      }
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      this.isConnecting = false;
      this.emit('error', error);
    };
  }
  
  handleMessage(message) {
    switch (message.type) {
      case 'event':
        this.handleEvent(message);
        break;
      case 'ping':
        this.send({ type: 'pong' });
        break;
      case 'response':
        this.handleResponse(message);
        break;
      case 'error':
        console.error('WebSocket error:', message.data);
        this.emit('error', message.data);
        break;
    }
  }
  
  handleEvent(message) {
    this.emit('event', message);
    this.emit(message.event, message.data);
  }
  
  handleResponse(message) {
    this.emit('response', message);
  }
  
  send(data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    } else {
      console.warn('WebSocket is not open');
    }
  }
  
  subscribe(channels) {
    this.send({
      type: 'subscribe',
      channels: Array.isArray(channels) ? channels : [channels]
    });
  }
  
  unsubscribe(channels) {
    this.send({
      type: 'unsubscribe',
      channels: Array.isArray(channels) ? channels : [channels]
    });
  }
  
  subscribeToEvents(events) {
    this.send({
      type: 'subscribe',
      events: Array.isArray(events) ? events : [events]
    });
  }
  
  scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnection attempts reached');
      this.emit('maxReconnectAttemptsReached');
      return;
    }
    
    this.reconnectAttempts++;
    console.log(`Reconnecting in ${this.reconnectInterval}ms (attempt ${this.reconnectAttempts})`);
    
    setTimeout(() => {
      this.connect();
    }, this.reconnectInterval);
  }
  
  // Event emitter methods
  on(event, handler) {
    if (!this.eventHandlers.has(event)) {
      this.eventHandlers.set(event, []);
    }
    this.eventHandlers.get(event).push(handler);
  }
  
  off(event, handler) {
    if (this.eventHandlers.has(event)) {
      const handlers = this.eventHandlers.get(event);
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    }
  }
  
  emit(event, data) {
    if (this.eventHandlers.has(event)) {
      this.eventHandlers.get(event).forEach(handler => {
        try {
          handler(data);
        } catch (error) {
          console.error(`Error in event handler for ${event}:`, error);
        }
      });
    }
  }
  
  close() {
    this.autoReconnect = false;
    if (this.ws) {
      this.ws.close(1000, 'Client closing');
    }
  }
}

// Использование
const client = new KatyaWebSocketClient({
  token: 'YOUR_ACCESS_TOKEN',
  channels: ['messages', 'alerts', 'metrics'],
  autoReconnect: true,
  reconnectInterval: 5000
});

client.on('connected', () => {
  console.log('Connected to Katya WebSocket');
});

client.on('message.created', (message) => {
  console.log('New message:', message);
});

client.on('security.alert.created', (alert) => {
  console.log('Security alert:', alert);
});

client.on('analytics.metric.updated', (metric) => {
  console.log('Metric updated:', metric);
});

client.on('error', (error) => {
  console.error('WebSocket error:', error);
});
```

## Python клиент

```python
import asyncio
import websockets
import json
import logging
from typing import List, Callable, Dict, Any

class KatyaWebSocketClient:
    def __init__(self, url: str = 'wss://api.katya.wtf/v1/ws', 
                 token: str = None, 
                 channels: List[str] = None,
                 events: List[str] = None):
        self.url = url
        self.token = token
        self.channels = channels or []
        self.events = events or []
        self.websocket = None
        self.event_handlers = {}
        self.is_connected = False
        
    async def connect(self):
        """Подключение к WebSocket"""
        try:
            uri = self.url
            if self.token:
                uri += f'?token={self.token}'
            
            self.websocket = await websockets.connect(uri)
            self.is_connected = True
            logging.info('Connected to Katya WebSocket')
            
            # Подписываемся на каналы и события
            if self.channels:
                await self.subscribe(self.channels)
            
            if self.events:
                await self.subscribe_to_events(self.events)
            
            # Обрабатываем сообщения
            await self.handle_messages()
            
        except Exception as e:
            logging.error(f'Failed to connect to WebSocket: {e}')
            self.is_connected = False
    
    async def handle_messages(self):
        """Обработка входящих сообщений"""
        async for message in self.websocket:
            try:
                data = json.loads(message)
                await self.process_message(data)
            except json.JSONDecodeError as e:
                logging.error(f'Failed to parse message: {e}')
            except Exception as e:
                logging.error(f'Error processing message: {e}')
    
    async def process_message(self, message: Dict[str, Any]):
        """Обработка сообщения в зависимости от типа"""
        message_type = message.get('type')
        
        if message_type == 'event':
            await self.handle_event(message)
        elif message_type == 'ping':
            await self.send({'type': 'pong'})
        elif message_type == 'response':
            await self.handle_response(message)
        elif message_type == 'error':
            logging.error(f'WebSocket error: {message.get("data")}')
            await self.emit('error', message.get('data'))
    
    async def handle_event(self, message: Dict[str, Any]):
        """Обработка события"""
        event = message.get('event')
        data = message.get('data')
        
        await self.emit('event', message)
        await self.emit(event, data)
    
    async def handle_response(self, message: Dict[str, Any]):
        """Обработка ответа"""
        await self.emit('response', message)
    
    async def send(self, data: Dict[str, Any]):
        """Отправка сообщения"""
        if self.websocket and self.is_connected:
            await self.websocket.send(json.dumps(data))
    
    async def subscribe(self, channels: List[str]):
        """Подписка на каналы"""
        await self.send({
            'type': 'subscribe',
            'channels': channels
        })
    
    async def unsubscribe(self, channels: List[str]):
        """Отписка от каналов"""
        await self.send({
            'type': 'unsubscribe',
            'channels': channels
        })
    
    async def subscribe_to_events(self, events: List[str]):
        """Подписка на события"""
        await self.send({
            'type': 'subscribe',
            'events': events
        })
    
    def on(self, event: str, handler: Callable):
        """Регистрация обработчика события"""
        if event not in self.event_handlers:
            self.event_handlers[event] = []
        self.event_handlers[event].append(handler)
    
    async def emit(self, event: str, data: Any = None):
        """Вызов обработчиков события"""
        if event in self.event_handlers:
            for handler in self.event_handlers[event]:
                try:
                    if asyncio.iscoroutinefunction(handler):
                        await handler(data)
                    else:
                        handler(data)
                except Exception as e:
                    logging.error(f'Error in event handler for {event}: {e}')
    
    async def close(self):
        """Закрытие соединения"""
        self.is_connected = False
        if self.websocket:
            await self.websocket.close()

# Пример использования
async def main():
    client = KatyaWebSocketClient(
        token='YOUR_ACCESS_TOKEN',
        channels=['messages', 'alerts', 'metrics'],
        events=['message.created', 'security.alert.created']
    )
    
    # Регистрация обработчиков
    async def on_connected():
        print('Connected to Katya WebSocket')
    
    async def on_message_created(message):
        print(f'New message: {message}')
    
    async def on_security_alert(alert):
        print(f'Security alert: {alert}')
    
    async def on_metric_updated(metric):
        print(f'Metric updated: {metric}')
    
    client.on('connected', on_connected)
    client.on('message.created', on_message_created)
    client.on('security.alert.created', on_security_alert)
    client.on('analytics.metric.updated', on_metric_updated)
    
    try:
        await client.connect()
    except KeyboardInterrupt:
        print('Disconnecting...')
        await client.close()

if __name__ == '__main__':
    asyncio.run(main())
```

## Обработка ошибок

### Типы ошибок

| Код | Описание |
|-----|----------|
| `4001` | Неверный токен аутентификации |
| `4002` | Недостаточно прав для подписки на канал |
| `4003` | Неверный формат сообщения |
| `4004` | Превышен лимит подписок |
| `4005` | Канал не существует |
| `5001` | Внутренняя ошибка сервера |
| `5002` | Сервис недоступен |

### Пример обработки ошибок

```javascript
ws.onmessage = function(event) {
  const message = JSON.parse(event.data);
  
  if (message.type === 'error') {
    const error = message.data;
    
    switch (error.code) {
      case '4001':
        console.error('Authentication failed');
        // Перенаправляем на страницу входа
        window.location.href = '/login';
        break;
        
      case '4002':
        console.error('Insufficient permissions');
        // Показываем уведомление пользователю
        showNotification('You do not have permission to access this channel');
        break;
        
      case '4004':
        console.error('Subscription limit exceeded');
        // Отписываемся от старых каналов
        unsubscribeOldChannels();
        break;
        
      default:
        console.error('Unknown error:', error);
    }
  }
};
```

## Мониторинг и диагностика

### Ping/Pong

Сервер отправляет ping сообщения каждые 30 секунд. Клиент должен отвечать pong:

```javascript
ws.onmessage = function(event) {
  const message = JSON.parse(event.data);
  
  if (message.type === 'ping') {
    ws.send(JSON.stringify({ type: 'pong' }));
  }
};
```

### Статистика подключения

```javascript
class WebSocketStats {
  constructor() {
    this.connectedAt = null;
    this.messagesReceived = 0;
    this.messagesSent = 0;
    this.errors = 0;
    this.lastPing = null;
  }
  
  onConnect() {
    this.connectedAt = new Date();
  }
  
  onMessage(type) {
    if (type === 'incoming') {
      this.messagesReceived++;
    } else if (type === 'outgoing') {
      this.messagesSent++;
    }
  }
  
  onError() {
    this.errors++;
  }
  
  onPing() {
    this.lastPing = new Date();
  }
  
  getStats() {
    const uptime = this.connectedAt ? 
      new Date() - this.connectedAt : 0;
    
    return {
      uptime,
      messagesReceived: this.messagesReceived,
      messagesSent: this.messagesSent,
      errors: this.errors,
      lastPing: this.lastPing
    };
  }
}

const stats = new WebSocketStats();
// Используйте stats для мониторинга
```

## Безопасность

### Рекомендации

1. **Используйте WSS**: Всегда используйте зашифрованное соединение
2. **Валидируйте токены**: Проверяйте токены на сервере
3. **Ограничивайте подписки**: Контролируйте количество подписок
4. **Логируйте события**: Ведите логи всех WebSocket событий
5. **Обрабатывайте ошибки**: Корректно обрабатывайте все типы ошибок

### Пример безопасного клиента

```javascript
class SecureKatyaWebSocketClient {
  constructor(options = {}) {
    this.url = options.url || 'wss://api.katya.wtf/v1/ws';
    this.token = options.token;
    this.maxSubscriptions = options.maxSubscriptions || 10;
    this.pingInterval = options.pingInterval || 30000;
    
    this.ws = null;
    this.subscriptions = new Set();
    this.pingTimer = null;
    
    this.connect();
  }
  
  connect() {
    // Валидация URL
    if (!this.url.startsWith('wss://')) {
      throw new Error('WebSocket URL must use WSS');
    }
    
    // Валидация токена
    if (!this.token) {
      throw new Error('Access token is required');
    }
    
    this.ws = new WebSocket(`${this.url}?token=${this.token}`);
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    this.ws.onopen = () => {
      console.log('Connected to Katya WebSocket');
      this.startPing();
    };
    
    this.ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        this.handleMessage(message);
      } catch (error) {
        console.error('Failed to parse message:', error);
      }
    };
    
    this.ws.onclose = (event) => {
      console.log('WebSocket closed:', event.code, event.reason);
      this.stopPing();
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }
  
  subscribe(channels) {
    if (this.subscriptions.size + channels.length > this.maxSubscriptions) {
      throw new Error('Subscription limit exceeded');
    }
    
    channels.forEach(channel => this.subscriptions.add(channel));
    
    this.send({
      type: 'subscribe',
      channels: channels
    });
  }
  
  startPing() {
    this.pingTimer = setInterval(() => {
      if (this.ws?.readyState === WebSocket.OPEN) {
        this.send({ type: 'ping' });
      }
    }, this.pingInterval);
  }
  
  stopPing() {
    if (this.pingTimer) {
      clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
  }
  
  send(data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }
  
  close() {
    this.stopPing();
    if (this.ws) {
      this.ws.close(1000, 'Client closing');
    }
  }
}
```

## Поддержка

### Контакты

- **Email**: websocket@katya.wtf
- **Discord**: https://discord.gg/katya
- **GitHub Issues**: https://github.com/katya/katya/issues

### Документация

- **API Reference**: https://docs.katya.wtf/api/websocket
- **Event Types**: https://docs.katya.wtf/api/websocket/events
- **Examples**: https://github.com/katya/websocket-examples
