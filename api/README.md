# Katya API Documentation

## Обзор

Katya API предоставляет комплексный набор эндпоинтов для управления системой доверия, обмена сообщениями, аналитики и мониторинга. API построен на принципах REST и следует стандартам OpenAPI 3.0.

## Быстрый старт

### Аутентификация

Все API запросы требуют аутентификации с использованием Bearer токенов:

```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     https://api.katya.wtf/v1/trust/identities
```

### Базовый URL

- **Production**: `https://api.katya.wtf/v1`
- **Staging**: `https://staging-api.katya.wtf/v1`
- **Development**: `http://localhost:8080/v1`

## Основные разделы API

### 1. Аутентификация (`/auth`)

Управление пользователями и аутентификацией:

- `POST /auth/login` - Вход в систему
- `POST /auth/register` - Регистрация пользователя
- `POST /auth/refresh` - Обновление токена
- `POST /auth/logout` - Выход из системы

### 2. Сеть доверия (`/trust`)

Управление идентичностями и верификацией:

- `GET /trust/identities` - Список идентичностей
- `POST /trust/identities` - Создание идентичности
- `GET /trust/identities/{id}` - Детали идентичности
- `POST /trust/verifications` - Создание верификации
- `GET /trust/reputation/{id}` - Репутация пользователя
- `GET /trust/recommendations` - Рекомендации доверия

### 3. Сообщения (`/messages`)

Обмен сообщениями:

- `GET /messages` - Список сообщений
- `POST /messages` - Отправка сообщения
- `GET /messages/{id}` - Детали сообщения
- `DELETE /messages/{id}` - Удаление сообщения

### 4. Комнаты (`/rooms`)

Управление комнатами:

- `GET /rooms` - Список комнат
- `POST /rooms` - Создание комнаты
- `GET /rooms/{id}` - Детали комнаты
- `PUT /rooms/{id}` - Обновление комнаты

### 5. Дашборд (`/dashboard`)

Управление виджетами и макетами:

- `GET /dashboard/widgets` - Список виджетов
- `GET /dashboard/widgets/{id}/data` - Данные виджета
- `GET /dashboard/layouts` - Макеты пользователя
- `POST /dashboard/layouts` - Создание макета

### 6. Аналитика (`/analytics`)

Метрики и отчеты:

- `GET /analytics/metrics` - Системные метрики
- `GET /analytics/reports` - Аналитические отчеты

### 7. Безопасность (`/security`)

Мониторинг безопасности:

- `GET /security/alerts` - Список алертов
- `POST /security/scan` - Запуск сканирования

## Примеры использования

### Аутентификация

```bash
# Регистрация пользователя
curl -X POST https://api.katya.wtf/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Вход в систему
curl -X POST https://api.katya.wtf/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Управление идентичностями

```bash
# Создание идентичности
curl -X POST https://api.katya.wtf/v1/trust/identities \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "email": "alice@example.com",
    "displayName": "Alice Smith"
  }'

# Получение репутации
curl -X GET https://api.katya.wtf/v1/trust/reputation/user_123 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Обмен сообщениями

```bash
# Отправка сообщения
curl -X POST https://api.katya.wtf/v1/messages \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": "room_456",
    "content": "Hello, world!",
    "messageType": "text"
  }'

# Получение сообщений
curl -X GET "https://api.katya.wtf/v1/messages?roomId=room_456&limit=50" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Работа с дашбордом

```bash
# Получение данных виджета
curl -X GET "https://api.katya.wtf/v1/dashboard/widgets/cpu_metric/data?startDate=2024-01-01T00:00:00Z&endDate=2024-01-02T00:00:00Z" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Создание макета
curl -X POST https://api.katya.wtf/v1/dashboard/layouts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Dashboard",
    "widgetIds": ["cpu_metric", "memory_metric", "alerts_list"],
    "type": "grid"
  }'
```

## Коды ответов

### Успешные ответы

- `200 OK` - Запрос выполнен успешно
- `201 Created` - Ресурс создан
- `204 No Content` - Ресурс удален

### Ошибки клиента

- `400 Bad Request` - Некорректный запрос
- `401 Unauthorized` - Не авторизован
- `403 Forbidden` - Доступ запрещен
- `404 Not Found` - Ресурс не найден
- `429 Too Many Requests` - Превышен лимит запросов

### Ошибки сервера

- `500 Internal Server Error` - Внутренняя ошибка сервера
- `502 Bad Gateway` - Ошибка шлюза
- `503 Service Unavailable` - Сервис недоступен

## Лимиты запросов

API имеет следующие лимиты запросов:

| Тип пользователя | Запросов в минуту | Запросов в час |
| ---------------- | ----------------- | -------------- |
| Анонимный        | 60                | 1000           |
| Авторизованный   | 300               | 10000          |
| Премиум          | 600               | 20000          |
| Администратор    | 1200              | 50000          |

## WebSocket API

Для получения обновлений в реальном времени используйте WebSocket подключение:

```javascript
const ws = new WebSocket("wss://api.katya.wtf/v1/ws");

ws.onopen = function () {
  // Подписка на события
  ws.send(
    JSON.stringify({
      type: "subscribe",
      channels: ["messages", "alerts", "metrics"],
    })
  );
};

ws.onmessage = function (event) {
  const data = JSON.parse(event.data);
  console.log("Received:", data);
};
```

### WebSocket события

- `message.new` - Новое сообщение
- `message.updated` - Сообщение обновлено
- `alert.created` - Создан новый алерт
- `metric.updated` - Обновлена метрика
- `user.status_changed` - Изменился статус пользователя

## SDK и библиотеки

### JavaScript/TypeScript

```bash
npm install @katya/api-client
```

```javascript
import { KatyaClient } from "@katya/api-client";

const client = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
  apiKey: "YOUR_API_KEY",
});

// Аутентификация
await client.auth.login("john@example.com", "password123");

// Отправка сообщения
const message = await client.messages.send({
  roomId: "room_123",
  content: "Hello!",
});

// Получение репутации
const reputation = await client.trust.getReputation("user_456");
```

### Python

```bash
pip install katya-api-client
```

```python
from katya_api import KatyaClient

client = KatyaClient(
    base_url='https://api.katya.wtf/v1',
    api_key='YOUR_API_KEY'
)

# Аутентификация
client.auth.login('john@example.com', 'password123')

# Отправка сообщения
message = client.messages.send({
    'roomId': 'room_123',
    'content': 'Hello!'
})

# Получение репутации
reputation = client.trust.get_reputation('user_456')
```

### Dart/Flutter

```yaml
dependencies:
  katya_api_client: ^1.0.0
```

```dart
import 'package:katya_api_client/katya_api_client.dart';

final client = KatyaClient(
  baseUrl: 'https://api.katya.wtf/v1',
  apiKey: 'YOUR_API_KEY',
);

// Аутентификация
await client.auth.login('john@example.com', 'password123');

// Отправка сообщения
final message = await client.messages.send(MessageRequest(
  roomId: 'room_123',
  content: 'Hello!',
));

// Получение репутации
final reputation = await client.trust.getReputation('user_456');
```

## Тестирование API

### Postman Collection

Импортируйте коллекцию Postman для быстрого тестирования:

[Download Postman Collection](https://api.katya.wtf/v1/docs/postman/collection.json)

### Insomnia

Импортируйте рабочую среду Insomnia:

[Download Insomnia Workspace](https://api.katya.wtf/v1/docs/insomnia/workspace.json)

### cURL примеры

Все эндпоинты API можно тестировать с помощью cURL. Примеры доступны в документации каждого эндпоинта.

## Поддержка

### Документация

- **OpenAPI спецификация**: [openapi.yaml](./openapi.yaml)
- **Интерактивная документация**: https://api.katya.wtf/v1/docs
- **Postman коллекция**: https://api.katya.wtf/v1/docs/postman

### Контакты

- **Email**: api-support@katya.wtf
- **Discord**: https://discord.gg/katya
- **GitHub Issues**: https://github.com/katya/katya/issues

### Статус API

Проверьте статус API и инциденты:

- **Status Page**: https://status.katya.wtf
- **Uptime**: https://uptime.katya.wtf

## Changelog

### v1.0.0 (2024-01-01)

- Первоначальный релиз API
- Поддержка аутентификации и авторизации
- Базовые эндпоинты для сети доверия
- Система обмена сообщениями
- Дашборд и аналитика
- Мониторинг безопасности

### v1.1.0 (2024-02-01) - Планируется

- WebSocket API для реального времени
- Расширенная аналитика
- Интеграция с блокчейном
- Анонимная коммуникация
- IoT интеграция

## Лицензия

API предоставляется под лицензией MIT. См. [LICENSE](../LICENSE) для подробностей.
