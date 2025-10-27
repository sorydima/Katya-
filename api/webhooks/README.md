# Katya API Webhooks

## Обзор

Webhooks позволяют вашему приложению получать уведомления о событиях в Katya в реальном времени. Вместо постоянного опроса API, webhooks отправляют HTTP POST запросы на указанные URL при возникновении событий.

## Поддерживаемые события

### Сеть доверия

| Событие                      | Описание                   | Данные         |
| ---------------------------- | -------------------------- | -------------- |
| `trust.identity.created`     | Создана новая идентичность | `identity`     |
| `trust.identity.updated`     | Обновлена идентичность     | `identity`     |
| `trust.verification.created` | Создана новая верификация  | `verification` |
| `trust.verification.updated` | Обновлена верификация      | `verification` |
| `trust.reputation.updated`   | Обновлена репутация        | `reputation`   |

### Сообщения

| Событие           | Описание                | Данные    |
| ----------------- | ----------------------- | --------- |
| `message.created` | Создано новое сообщение | `message` |
| `message.updated` | Обновлено сообщение     | `message` |
| `message.deleted` | Удалено сообщение       | `message` |

### Комнаты

| Событие              | Описание                             | Данные           |
| -------------------- | ------------------------------------ | ---------------- |
| `room.created`       | Создана новая комната                | `room`           |
| `room.updated`       | Обновлена комната                    | `room`           |
| `room.member.joined` | Пользователь присоединился к комнате | `room`, `member` |
| `room.member.left`   | Пользователь покинул комнату         | `room`, `member` |

### Аналитика

| Событие                      | Описание           | Данные   |
| ---------------------------- | ------------------ | -------- |
| `analytics.report.created`   | Создан новый отчет | `report` |
| `analytics.report.completed` | Отчет завершен     | `report` |
| `analytics.metric.updated`   | Обновлена метрика  | `metric` |

### Безопасность

| Событие                   | Описание               | Данные  |
| ------------------------- | ---------------------- | ------- |
| `security.alert.created`  | Создан новый алерт     | `alert` |
| `security.alert.updated`  | Обновлен алерт         | `alert` |
| `security.scan.completed` | Завершено сканирование | `scan`  |

### Система

| Событие                    | Описание                             | Данные        |
| -------------------------- | ------------------------------------ | ------------- |
| `system.maintenance.start` | Начало технического обслуживания     | `maintenance` |
| `system.maintenance.end`   | Завершение технического обслуживания | `maintenance` |
| `system.status.changed`    | Изменен статус системы               | `status`      |

## Настройка Webhooks

### Создание Webhook

```bash
POST /v1/webhooks
```

**Запрос:**

```json
{
  "name": "My Webhook",
  "url": "https://myapp.com/webhooks/katya",
  "events": ["message.created", "trust.verification.created", "security.alert.created"],
  "secret": "my_webhook_secret",
  "active": true,
  "retryPolicy": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "backoffMultiplier": 2
  }
}
```

**Ответ (201):**

```json
{
  "success": true,
  "data": {
    "id": "webhook_123",
    "name": "My Webhook",
    "url": "https://myapp.com/webhooks/katya",
    "events": ["message.created", "trust.verification.created", "security.alert.created"],
    "secret": "my_webhook_secret",
    "active": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "lastDelivery": null,
    "retryPolicy": {
      "maxRetries": 3,
      "retryDelay": 1000,
      "backoffMultiplier": 2
    }
  }
}
```

### Получение списка Webhooks

```bash
GET /v1/webhooks?limit=50&offset=0
```

**Ответ (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "webhook_123",
      "name": "My Webhook",
      "url": "https://myapp.com/webhooks/katya",
      "events": ["message.created"],
      "active": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "lastDelivery": "2024-01-01T12:00:00Z"
    }
  ],
  "pagination": {
    "total": 1,
    "limit": 50,
    "offset": 0,
    "hasMore": false
  }
}
```

### Обновление Webhook

```bash
PUT /v1/webhooks/{webhook_id}
```

**Запрос:**

```json
{
  "name": "Updated Webhook Name",
  "events": ["message.created", "trust.verification.created", "security.alert.created", "analytics.report.completed"],
  "active": true
}
```

### Удаление Webhook

```bash
DELETE /v1/webhooks/{webhook_id}
```

**Ответ (204):**

```
No Content
```

## Формат Webhook запросов

### Заголовки

```http
POST https://myapp.com/webhooks/katya HTTP/1.1
Content-Type: application/json
X-Katya-Event: message.created
X-Katya-Signature: sha256=abc123def456...
X-Katya-Delivery: delivery_123
X-Katya-Timestamp: 1640995200
User-Agent: Katya-Webhooks/1.0
```

### Тело запроса

```json
{
  "id": "evt_123",
  "type": "message.created",
  "createdAt": "2024-01-01T12:00:00Z",
  "data": {
    "id": "msg_456",
    "roomId": "room_789",
    "senderId": "user_101",
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

### Валидация подписи

Для проверки подлинности webhook запросов используйте HMAC-SHA256:

```javascript
const crypto = require("crypto");

function verifyWebhookSignature(payload, signature, secret) {
  const expectedSignature = crypto.createHmac("sha256", secret).update(payload).digest("hex");

  const providedSignature = signature.replace("sha256=", "");

  return crypto.timingSafeEqual(Buffer.from(expectedSignature, "hex"), Buffer.from(providedSignature, "hex"));
}

// Пример использования
app.post("/webhooks/katya", (req, res) => {
  const signature = req.headers["x-katya-signature"];
  const payload = JSON.stringify(req.body);

  if (!verifyWebhookSignature(payload, signature, process.env.WEBHOOK_SECRET)) {
    return res.status(401).send("Invalid signature");
  }

  // Обработка webhook
  console.log("Received event:", req.headers["x-katya-event"]);
  console.log("Data:", req.body.data);

  res.status(200).send("OK");
});
```

```python
import hmac
import hashlib
import json

def verify_webhook_signature(payload, signature, secret):
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()

    provided_signature = signature.replace('sha256=', '')

    return hmac.compare_digest(expected_signature, provided_signature)

# Пример использования с Flask
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhooks/katya', methods=['POST'])
def handle_webhook():
    signature = request.headers.get('X-Katya-Signature')
    payload = json.dumps(request.get_json())

    if not verify_webhook_signature(payload, signature, os.getenv('WEBHOOK_SECRET')):
        return jsonify({'error': 'Invalid signature'}), 401

    # Обработка webhook
    event_type = request.headers.get('X-Katya-Event')
    data = request.get_json()

    print(f'Received event: {event_type}')
    print(f'Data: {data["data"]}')

    return jsonify({'status': 'OK'})

if __name__ == '__main__':
    app.run(debug=True)
```

## Обработка событий

### Пример обработчика на Node.js

```javascript
const express = require("express");
const crypto = require("crypto");

const app = express();
app.use(express.json());

// Middleware для валидации webhook
function validateWebhook(req, res, next) {
  const signature = req.headers["x-katya-signature"];
  const payload = JSON.stringify(req.body);

  if (!signature || !verifyWebhookSignature(payload, signature, process.env.WEBHOOK_SECRET)) {
    return res.status(401).send("Invalid signature");
  }

  next();
}

// Обработка webhook
app.post("/webhooks/katya", validateWebhook, (req, res) => {
  const eventType = req.headers["x-katya-event"];
  const { data } = req.body;

  switch (eventType) {
    case "message.created":
      handleNewMessage(data);
      break;

    case "trust.verification.created":
      handleNewVerification(data);
      break;

    case "security.alert.created":
      handleSecurityAlert(data);
      break;

    default:
      console.log(`Unhandled event type: ${eventType}`);
  }

  res.status(200).send("OK");
});

function handleNewMessage(message) {
  console.log(`New message from ${message.senderId} in room ${message.roomId}: ${message.content}`);

  // Отправка уведомления пользователям
  // Обновление UI в реальном времени
  // Логирование для аналитики
}

function handleNewVerification(verification) {
  console.log(`New verification for identity ${verification.identityId}`);

  // Обновление репутации пользователя
  // Отправка уведомления о верификации
  // Обновление списка доверенных контактов
}

function handleSecurityAlert(alert) {
  console.log(`Security alert: ${alert.title} (${alert.severity})`);

  // Отправка уведомления администраторам
  // Логирование в систему мониторинга
  // Автоматические действия по безопасности
}

app.listen(3000, () => {
  console.log("Webhook server running on port 3000");
});
```

### Пример обработчика на Python

```python
from flask import Flask, request, jsonify
import hmac
import hashlib
import json
import os

app = Flask(__name__)

def verify_webhook_signature(payload, signature, secret):
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()

    provided_signature = signature.replace('sha256=', '')

    return hmac.compare_digest(expected_signature, provided_signature)

@app.route('/webhooks/katya', methods=['POST'])
def handle_webhook():
    signature = request.headers.get('X-Katya-Signature')
    payload = json.dumps(request.get_json())

    if not verify_webhook_signature(payload, signature, os.getenv('WEBHOOK_SECRET')):
        return jsonify({'error': 'Invalid signature'}), 401

    event_type = request.headers.get('X-Katya-Event')
    data = request.get_json()

    if event_type == 'message.created':
        handle_new_message(data['data'])
    elif event_type == 'trust.verification.created':
        handle_new_verification(data['data'])
    elif event_type == 'security.alert.created':
        handle_security_alert(data['data'])
    else:
        print(f'Unhandled event type: {event_type}')

    return jsonify({'status': 'OK'})

def handle_new_message(message):
    print(f'New message from {message["senderId"]} in room {message["roomId"]}: {message["content"]}')

    # Отправка уведомления пользователям
    # Обновление UI в реальном времени
    # Логирование для аналитики

def handle_new_verification(verification):
    print(f'New verification for identity {verification["identityId"]}')

    # Обновление репутации пользователя
    # Отправка уведомления о верификации
    # Обновление списка доверенных контактов

def handle_security_alert(alert):
    print(f'Security alert: {alert["title"]} ({alert["severity"]})')

    # Отправка уведомления администраторам
    # Логирование в систему мониторинга
    # Автоматические действия по безопасности

if __name__ == '__main__':
    app.run(debug=True)
```

## Политика повторов

### Настройка повторов

```json
{
  "retryPolicy": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "backoffMultiplier": 2,
    "maxRetryDelay": 30000
  }
}
```

### Логика повторов

1. **Первая попытка**: Немедленно
2. **Вторая попытка**: Через 1 секунду
3. **Третья попытка**: Через 2 секунды
4. **Четвертая попытка**: Через 4 секунды
5. **Максимальная задержка**: 30 секунд

### Заголовки повторов

```http
X-Katya-Retry-Count: 2
X-Katya-Retry-Reason: timeout
X-Katya-Retry-After: 4
```

## Мониторинг и логирование

### Статистика доставки

```bash
GET /v1/webhooks/{webhook_id}/stats?startDate=2024-01-01&endDate=2024-01-02
```

**Ответ (200):**

```json
{
  "success": true,
  "data": {
    "webhookId": "webhook_123",
    "period": {
      "startDate": "2024-01-01T00:00:00Z",
      "endDate": "2024-01-02T00:00:00Z"
    },
    "delivery": {
      "total": 150,
      "successful": 145,
      "failed": 5,
      "successRate": 0.967
    },
    "events": {
      "message.created": 100,
      "trust.verification.created": 30,
      "security.alert.created": 20
    },
    "responseTimes": {
      "average": 150,
      "p50": 120,
      "p95": 300,
      "p99": 500
    }
  }
}
```

### Логи доставки

```bash
GET /v1/webhooks/{webhook_id}/logs?limit=50&offset=0
```

**Ответ (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "log_123",
      "eventId": "evt_456",
      "eventType": "message.created",
      "status": "delivered",
      "responseTime": 150,
      "attempts": 1,
      "deliveredAt": "2024-01-01T12:00:00Z",
      "response": {
        "statusCode": 200,
        "body": "OK"
      }
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 50,
    "offset": 0,
    "hasMore": true
  }
}
```

## Безопасность

### Рекомендации

1. **Используйте HTTPS**: Всегда используйте HTTPS для webhook URL
2. **Валидируйте подписи**: Проверяйте HMAC подписи для каждого запроса
3. **Используйте секреты**: Храните webhook секреты в безопасном месте
4. **Ограничьте доступ**: Используйте firewall для ограничения доступа
5. **Логируйте события**: Ведите логи всех webhook событий

### Пример безопасного обработчика

```javascript
const express = require("express");
const crypto = require("crypto");
const rateLimit = require("express-rate-limit");

const app = express();

// Rate limiting для webhook endpoint
const webhookLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 минута
  max: 100, // максимум 100 запросов в минуту
  message: "Too many webhook requests",
});

app.use("/webhooks/katya", webhookLimiter);
app.use(express.json({ limit: "10mb" }));

// Валидация webhook
function validateWebhook(req, res, next) {
  const signature = req.headers["x-katya-signature"];
  const timestamp = req.headers["x-katya-timestamp"];
  const payload = JSON.stringify(req.body);

  // Проверка временной метки (защита от replay атак)
  const now = Math.floor(Date.now() / 1000);
  const requestTime = parseInt(timestamp);

  if (Math.abs(now - requestTime) > 300) {
    // 5 минут
    return res.status(401).send("Request too old");
  }

  // Проверка подписи
  if (!signature || !verifyWebhookSignature(payload, signature, process.env.WEBHOOK_SECRET)) {
    return res.status(401).send("Invalid signature");
  }

  next();
}

app.post("/webhooks/katya", validateWebhook, (req, res) => {
  try {
    const eventType = req.headers["x-katya-event"];
    const { data } = req.body;

    // Обработка события
    handleWebhookEvent(eventType, data);

    res.status(200).send("OK");
  } catch (error) {
    console.error("Webhook processing error:", error);
    res.status(500).send("Internal server error");
  }
});

function handleWebhookEvent(eventType, data) {
  // Логирование события
  console.log(`Processing webhook event: ${eventType}`, {
    eventType,
    timestamp: new Date().toISOString(),
    dataId: data.id,
  });

  // Обработка в зависимости от типа события
  switch (eventType) {
    case "message.created":
      // Асинхронная обработка
      processMessageCreated(data).catch(console.error);
      break;

    case "security.alert.created":
      // Критическое событие - немедленная обработка
      processSecurityAlert(data);
      break;

    default:
      console.log(`Unhandled event type: ${eventType}`);
  }
}

async function processMessageCreated(message) {
  // Асинхронная обработка нового сообщения
  // Отправка уведомлений, обновление UI, etc.
}

function processSecurityAlert(alert) {
  // Немедленная обработка алерта безопасности
  // Отправка уведомлений администраторам
  // Логирование в систему мониторинга
}

app.listen(3000, () => {
  console.log("Secure webhook server running on port 3000");
});
```

## Тестирование

### Локальное тестирование с ngrok

```bash
# Установка ngrok
npm install -g ngrok

# Запуск локального сервера
node webhook-server.js

# В другом терминале
ngrok http 3000

# Использование ngrok URL для webhook
curl -X POST https://api.katya.wtf/v1/webhooks \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Webhook",
    "url": "https://abc123.ngrok.io/webhooks/katya",
    "events": ["message.created"],
    "secret": "test_secret"
  }'
```

### Тестовые события

```bash
POST /v1/webhooks/{webhook_id}/test
```

**Запрос:**

```json
{
  "eventType": "message.created",
  "data": {
    "id": "test_msg_123",
    "roomId": "test_room_456",
    "senderId": "test_user_789",
    "content": "Test message",
    "messageType": "text",
    "createdAt": "2024-01-01T12:00:00Z"
  }
}
```

## Troubleshooting

### Частые проблемы

1. **Timeout ошибки**

   - Увеличьте timeout на вашем сервере
   - Оптимизируйте обработку webhook
   - Используйте асинхронную обработку

2. **Ошибки подписи**

   - Проверьте правильность webhook секрета
   - Убедитесь в корректности payload
   - Проверьте алгоритм HMAC

3. **Дублирование событий**
   - Используйте idempotency ключи
   - Проверяйте event ID перед обработкой
   - Реализуйте дедупликацию

### Отладка

```javascript
// Включение debug режима
app.use("/webhooks/katya", (req, res, next) => {
  if (process.env.DEBUG_WEBHOOKS === "true") {
    console.log("Webhook headers:", req.headers);
    console.log("Webhook body:", JSON.stringify(req.body, null, 2));
  }
  next();
});
```

## Поддержка

### Контакты

- **Email**: webhooks@katya.wtf
- **Discord**: https://discord.gg/katya
- **GitHub Issues**: https://github.com/katya/katya/issues

### Документация

- **API Reference**: https://docs.katya.wtf/api/webhooks
- **Event Types**: https://docs.katya.wtf/api/webhooks/events
- **Examples**: https://github.com/katya/webhook-examples
