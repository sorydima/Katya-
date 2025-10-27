# Руководство по ограничению скорости запросов (Rate Limiting)

## Обзор

Katya API использует систему ограничения скорости запросов для обеспечения стабильной работы сервиса и защиты от злоупотреблений. Этот документ описывает все аспекты rate limiting.

## Типы лимитов

### 1. Пользовательские лимиты

Ограничения основанные на типе пользователя:

| Тип пользователя | Запросов в минуту | Запросов в час | Запросов в день |
| ---------------- | ----------------- | -------------- | --------------- |
| Анонимный        | 60                | 1,000          | 10,000          |
| Авторизованный   | 300               | 10,000         | 100,000         |
| Премиум          | 600               | 20,000         | 200,000         |
| Администратор    | 1,200             | 50,000         | 500,000         |

### 2. Эндпоинт-специфичные лимиты

Дополнительные ограничения для ресурсоемких операций:

| Эндпоинт                       | Лимит                 |
| ------------------------------ | --------------------- |
| `POST /v1/auth/login`          | 5 попыток в минуту    |
| `POST /v1/auth/register`       | 3 регистрации в час   |
| `POST /v1/trust/verifications` | 100 верификаций в час |
| `POST /v1/messages`            | 1000 сообщений в час  |
| `GET /v1/analytics/reports`    | 50 отчетов в час      |
| `POST /v1/security/scan`       | 10 сканирований в час |

### 3. Глобальные лимиты

Системные ограничения для защиты инфраструктуры:

- **WebSocket подключения**: 100 одновременных подключений на пользователя
- **Размер запроса**: 10MB максимум
- **Размер ответа**: 50MB максимум
- **Timeout**: 30 секунд на запрос

## Заголовки ответов

Все ответы API содержат информацию о лимитах:

```http
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 299
X-RateLimit-Reset: 1640995200
X-RateLimit-Window: 60
X-RateLimit-Policy: user_based
```

### Описание заголовков

- `X-RateLimit-Limit`: Максимальное количество запросов в окне
- `X-RateLimit-Remaining`: Количество оставшихся запросов
- `X-RateLimit-Reset`: Unix timestamp сброса лимита
- `X-RateLimit-Window`: Размер окна в секундах
- `X-RateLimit-Policy`: Тип политики лимитирования

## Обработка превышения лимитов

### HTTP статус коды

- `429 Too Many Requests` - Превышен лимит запросов
- `503 Service Unavailable` - Временная недоступность из-за высокой нагрузки

### Пример ответа при превышении лимита

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640995200
Retry-After: 60

{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again later.",
    "details": {
      "limit": 300,
      "remaining": 0,
      "resetAt": "2024-01-01T12:00:00Z",
      "retryAfter": 60
    }
  }
}
```

## Алгоритмы лимитирования

### 1. Fixed Window (Фиксированное окно)

Простой алгоритм с фиксированными временными окнами:

```
Время: 12:00:00 - 12:01:00
Лимит: 300 запросов
Оставшийся лимит: 299

Время: 12:01:00 - 12:02:00
Лимит: 300 запросов (сброс)
Оставшийся лимит: 300
```

### 2. Sliding Window (Скользящее окно)

Более точный алгоритм с плавным сбросом:

```
Текущее время: 12:01:30
Окно: 12:00:30 - 12:01:30 (60 секунд)
Запросы в окне: 150
Лимит: 300
Оставшийся лимит: 150
```

### 3. Token Bucket (Ведро токенов)

Алгоритм с накоплением "токенов":

```
Емкость ведра: 300 токенов
Скорость пополнения: 5 токенов/секунду
Текущее количество: 250 токенов
```

## Реализация на клиенте

### JavaScript

```javascript
class RateLimitHandler {
  constructor() {
    this.queue = [];
    this.processing = false;
  }

  async makeRequest(requestFn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ requestFn, resolve, reject });
      this.processQueue();
    });
  }

  async processQueue() {
    if (this.processing || this.queue.length === 0) {
      return;
    }

    this.processing = true;

    while (this.queue.length > 0) {
      const { requestFn, resolve, reject } = this.queue.shift();

      try {
        const response = await requestFn();

        // Проверяем заголовки rate limit
        const remaining = parseInt(response.headers.get("X-RateLimit-Remaining") || "0");
        const resetTime = parseInt(response.headers.get("X-RateLimit-Reset") || "0");

        if (remaining === 0) {
          const waitTime = resetTime * 1000 - Date.now();
          if (waitTime > 0) {
            await new Promise((resolve) => setTimeout(resolve, waitTime));
          }
        }

        resolve(response);
      } catch (error) {
        if (error.status === 429) {
          const retryAfter = parseInt(error.headers.get("Retry-After") || "60");
          await new Promise((resolve) => setTimeout(resolve, retryAfter * 1000));
          this.queue.unshift({ requestFn, resolve, reject });
        } else {
          reject(error);
        }
      }
    }

    this.processing = false;
  }
}

// Использование
const rateLimitHandler = new RateLimitHandler();

async function apiCall() {
  return rateLimitHandler.makeRequest(async () => {
    const response = await fetch("/api/v1/trust/identities", {
      headers: {
        Authorization: "Bearer " + token,
      },
    });

    if (!response.ok) {
      const error = new Error("Request failed");
      error.status = response.status;
      error.headers = response.headers;
      throw error;
    }

    return response;
  });
}
```

### Python

```python
import time
import asyncio
from typing import Dict, Any
import httpx

class RateLimitHandler:
    def __init__(self):
        self.rate_limit_info = {}
        self.request_queue = asyncio.Queue()
        self.processing = False

    async def make_request(self, request_func, *args, **kwargs):
        """Добавляет запрос в очередь с учетом rate limiting"""
        future = asyncio.Future()
        await self.request_queue.put((request_func, args, kwargs, future))
        await self.process_queue()
        return await future

    async def process_queue(self):
        """Обрабатывает очередь запросов с учетом rate limiting"""
        if self.processing:
            return

        self.processing = True

        try:
            while not self.request_queue.empty():
                request_func, args, kwargs, future = await self.request_queue.get()

                try:
                    # Проверяем rate limit перед запросом
                    await self.check_rate_limit()

                    response = await request_func(*args, **kwargs)

                    # Обновляем информацию о rate limit
                    self.update_rate_limit_info(response.headers)

                    if not future.cancelled():
                        future.set_result(response)

                except httpx.HTTPStatusError as e:
                    if e.response.status_code == 429:
                        # Превышен лимит, добавляем обратно в очередь
                        retry_after = int(e.response.headers.get('Retry-After', 60))
                        await asyncio.sleep(retry_after)
                        await self.request_queue.put((request_func, args, kwargs, future))
                    else:
                        if not future.cancelled():
                            future.set_exception(e)

                except Exception as e:
                    if not future.cancelled():
                        future.set_exception(e)

        finally:
            self.processing = False

    async def check_rate_limit(self):
        """Проверяет и ожидает при необходимости"""
        if 'remaining' in self.rate_limit_info:
            remaining = self.rate_limit_info['remaining']
            if remaining <= 0:
                reset_time = self.rate_limit_info.get('reset', 0)
                wait_time = reset_time - time.time()
                if wait_time > 0:
                    await asyncio.sleep(wait_time)

    def update_rate_limit_info(self, headers: Dict[str, str]):
        """Обновляет информацию о rate limit из заголовков"""
        self.rate_limit_info = {
            'limit': int(headers.get('X-RateLimit-Limit', 0)),
            'remaining': int(headers.get('X-RateLimit-Remaining', 0)),
            'reset': int(headers.get('X-RateLimit-Reset', 0)),
            'window': int(headers.get('X-RateLimit-Window', 0))
        }

# Использование
async def main():
    rate_handler = RateLimitHandler()

    async def api_call():
        async with httpx.AsyncClient() as client:
            response = await client.get(
                'https://api.katya.wtf/v1/trust/identities',
                headers={'Authorization': f'Bearer {token}'}
            )
            return response

    # Выполняем запросы с автоматическим управлением rate limiting
    response = await rate_handler.make_request(api_call)
    print(f"Status: {response.status_code}")
```

### Go

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "strconv"
    "sync"
    "time"
)

type RateLimitHandler struct {
    mu           sync.Mutex
    rateLimitInfo map[string]int
    requestQueue chan *QueuedRequest
}

type QueuedRequest struct {
    RequestFunc func() (*http.Response, error)
    ResponseChan chan *RequestResult
}

type RequestResult struct {
    Response *http.Response
    Error    error
}

func NewRateLimitHandler() *RateLimitHandler {
    handler := &RateLimitHandler{
        rateLimitInfo: make(map[string]int),
        requestQueue:  make(chan *QueuedRequest, 1000),
    }
    go handler.processQueue()
    return handler
}

func (r *RateLimitHandler) MakeRequest(requestFunc func() (*http.Response, error)) (*http.Response, error) {
    resultChan := make(chan *RequestResult, 1)

    r.requestQueue <- &QueuedRequest{
        RequestFunc:  requestFunc,
        ResponseChan: resultChan,
    }

    result := <-resultChan
    return result.Response, result.Error
}

func (r *RateLimitHandler) processQueue() {
    for queuedRequest := range r.requestQueue {
        r.mu.Lock()
        remaining := r.rateLimitInfo["remaining"]
        resetTime := r.rateLimitInfo["reset"]
        r.mu.Unlock()

        // Проверяем rate limit
        if remaining <= 0 && resetTime > 0 {
            waitTime := time.Until(time.Unix(int64(resetTime), 0))
            if waitTime > 0 {
                time.Sleep(waitTime)
            }
        }

        // Выполняем запрос
        response, err := queuedRequest.RequestFunc()

        if err == nil && response.StatusCode == 429 {
            // Превышен лимит, повторяем через Retry-After
            retryAfterStr := response.Header.Get("Retry-After")
            if retryAfter, parseErr := strconv.Atoi(retryAfterStr); parseErr == nil {
                time.Sleep(time.Duration(retryAfter) * time.Second)
                response, err = queuedRequest.RequestFunc()
            }
        }

        // Обновляем информацию о rate limit
        if err == nil {
            r.updateRateLimitInfo(response.Header)
        }

        queuedRequest.ResponseChan <- &RequestResult{
            Response: response,
            Error:    err,
        }
    }
}

func (r *RateLimitHandler) updateRateLimitInfo(headers http.Header) {
    r.mu.Lock()
    defer r.mu.Unlock()

    if limitStr := headers.Get("X-RateLimit-Limit"); limitStr != "" {
        if limit, err := strconv.Atoi(limitStr); err == nil {
            r.rateLimitInfo["limit"] = limit
        }
    }

    if remainingStr := headers.Get("X-RateLimit-Remaining"); remainingStr != "" {
        if remaining, err := strconv.Atoi(remainingStr); err == nil {
            r.rateLimitInfo["remaining"] = remaining
        }
    }

    if resetStr := headers.Get("X-RateLimit-Reset"); resetStr != "" {
        if reset, err := strconv.Atoi(resetStr); err == nil {
            r.rateLimitInfo["reset"] = reset
        }
    }
}

// Использование
func main() {
    rateHandler := NewRateLimitHandler()

    response, err := rateHandler.MakeRequest(func() (*http.Response, error) {
        req, _ := http.NewRequest("GET", "https://api.katya.wtf/v1/trust/identities", nil)
        req.Header.Set("Authorization", "Bearer "+token)

        client := &http.Client{Timeout: 30 * time.Second}
        return client.Do(req)
    })

    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }

    fmt.Printf("Status: %d\n", response.StatusCode)
}
```

## Мониторинг и аналитика

### Метрики rate limiting

Система отслеживает следующие метрики:

```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "metrics": {
    "rate_limit_hits": {
      "total": 1250,
      "by_user_type": {
        "anonymous": 800,
        "authenticated": 300,
        "premium": 100,
        "admin": 50
      },
      "by_endpoint": {
        "/v1/auth/login": 500,
        "/v1/messages": 300,
        "/v1/trust/verifications": 200
      }
    },
    "average_response_time": 150,
    "p95_response_time": 300,
    "error_rate": 0.02
  }
}
```

### Получение статистики

```bash
GET /v1/admin/rate-limits/stats?startDate=2024-01-01&endDate=2024-01-02
```

### Алерты

Система отправляет уведомления при:

- Превышении лимитов более чем на 50% от нормы
- Блокировке пользователей
- Аномальной активности

## Настройка лимитов

### Для разработчиков

```bash
POST /v1/admin/rate-limits/policies
```

**Запрос:**

```json
{
  "name": "high_volume_user",
  "description": "Increased limits for high-volume users",
  "conditions": {
    "userType": "premium",
    "subscription": "enterprise"
  },
  "limits": {
    "perMinute": 1000,
    "perHour": 50000,
    "perDay": 500000
  }
}
```

### Для операторов

Настройка через конфигурационные файлы:

```yaml
rate_limiting:
  policies:
    - name: "anonymous"
      limits:
        per_minute: 60
        per_hour: 1000
        per_day: 10000

    - name: "authenticated"
      limits:
        per_minute: 300
        per_hour: 10000
        per_day: 100000

    - name: "premium"
      limits:
        per_minute: 600
        per_hour: 20000
        per_day: 200000

  endpoint_limits:
    - path: "/v1/auth/login"
      method: "POST"
      limit: 5
      window: "1m"

    - path: "/v1/messages"
      method: "POST"
      limit: 1000
      window: "1h"
```

## Обход лимитов

### Легитимные случаи

1. **Кэширование**: Используйте кэширование для уменьшения количества запросов
2. **Batch API**: Используйте batch эндпоинты для группировки операций
3. **WebSocket**: Используйте WebSocket для real-time обновлений
4. **Pagination**: Используйте пагинацию для больших наборов данных

### Нелегитимные методы

- **IP rotation**: Смена IP адресов для обхода лимитов
- **User agent spoofing**: Подделка User-Agent
- **Distributed requests**: Распределение запросов между аккаунтами

## Troubleshooting

### Частые проблемы

1. **429 ошибки**

   - Проверьте заголовки ответа для информации о сбросе
   - Реализуйте exponential backoff
   - Используйте очереди запросов

2. **Медленные ответы**

   - Проверьте размер запросов и ответов
   - Используйте сжатие (gzip)
   - Оптимизируйте запросы

3. **Неожиданные блокировки**
   - Проверьте логи аутентификации
   - Убедитесь в корректности токенов
   - Проверьте User-Agent и IP

### Отладка

```bash
# Включение debug заголовков
curl -H "X-Debug: true" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.katya.wtf/v1/trust/identities

# Ответ будет содержать дополнительную информацию
```

```json
{
  "success": true,
  "data": [...],
  "debug": {
    "rateLimit": {
      "policy": "authenticated",
      "windowStart": "2024-01-01T12:00:00Z",
      "windowEnd": "2024-01-01T12:01:00Z",
      "requestCount": 150,
      "limit": 300,
      "remaining": 150
    },
    "processingTime": 45,
    "cacheHit": false
  }
}
```

## Поддержка

### Контакты

- **Email**: api-support@katya.wtf
- **Discord**: https://discord.gg/katya
- **Status Page**: https://status.katya.wtf

### Полезные ссылки

- **HTTP Status Codes**: https://httpstatuses.com/
- **Rate Limiting Best Practices**: https://cloud.google.com/architecture/rate-limiting-strategies-techniques
- **Exponential Backoff**: https://cloud.google.com/storage/docs/retry-strategy
