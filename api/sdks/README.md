# Katya API SDKs

## Обзор

Katya предоставляет официальные SDK для популярных языков программирования, упрощающие интеграцию с API. Все SDK следуют единым принципам дизайна и обеспечивают полную совместимость с API.

## Доступные SDK

### JavaScript/TypeScript

**Установка:**

```bash
npm install @katya/api-client
# или
yarn add @katya/api-client
```

**Использование:**

```javascript
import { KatyaClient } from "@katya/api-client";

const client = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
  apiKey: "YOUR_API_KEY",
  timeout: 30000,
});

// Аутентификация
await client.auth.login("user@example.com", "password");

// Отправка сообщения
const message = await client.messages.send({
  roomId: "room_123",
  content: "Hello, world!",
  messageType: "text",
});

// Получение репутации
const reputation = await client.trust.getReputation("user_456");
```

### Python

**Установка:**

```bash
pip install katya-api-client
```

**Использование:**

```python
from katya_api import KatyaClient

client = KatyaClient(
    base_url='https://api.katya.wtf/v1',
    api_key='YOUR_API_KEY',
    timeout=30
)

# Аутентификация
client.auth.login('user@example.com', 'password')

# Отправка сообщения
message = client.messages.send({
    'roomId': 'room_123',
    'content': 'Hello, world!',
    'messageType': 'text'
})

# Получение репутации
reputation = client.trust.get_reputation('user_456')
```

### Dart/Flutter

**Установка:**

```yaml
dependencies:
  katya_api_client: ^1.0.0
```

**Использование:**

```dart
import 'package:katya_api_client/katya_api_client.dart';

final client = KatyaClient(
  baseUrl: 'https://api.katya.wtf/v1',
  apiKey: 'YOUR_API_KEY',
  timeout: Duration(seconds: 30),
);

// Аутентификация
await client.auth.login('user@example.com', 'password');

// Отправка сообщения
final message = await client.messages.send(MessageRequest(
  roomId: 'room_123',
  content: 'Hello, world!',
  messageType: MessageType.text,
));

// Получение репутации
final reputation = await client.trust.getReputation('user_456');
```

### Go

**Установка:**

```bash
go get github.com/katya/katya-api-go
```

**Использование:**

```go
package main

import (
    "context"
    "fmt"
    "github.com/katya/katya-api-go"
)

func main() {
    client := katya.NewClient(&katya.Config{
        BaseURL: "https://api.katya.wtf/v1",
        APIKey:  "YOUR_API_KEY",
        Timeout: 30 * time.Second,
    })

    // Аутентификация
    auth, err := client.Auth.Login(context.Background(), &katya.LoginRequest{
        Email:    "user@example.com",
        Password: "password",
    })
    if err != nil {
        panic(err)
    }

    // Отправка сообщения
    message, err := client.Messages.Send(context.Background(), &katya.SendMessageRequest{
        RoomID:      "room_123",
        Content:     "Hello, world!",
        MessageType: "text",
    })
    if err != nil {
        panic(err)
    }

    // Получение репутации
    reputation, err := client.Trust.GetReputation(context.Background(), "user_456")
    if err != nil {
        panic(err)
    }

    fmt.Printf("Message sent: %s\n", message.ID)
    fmt.Printf("Reputation score: %.2f\n", reputation.Score)
}
```

### Java

**Установка (Maven):**

```xml
<dependency>
    <groupId>com.katya</groupId>
    <artifactId>katya-api-client</artifactId>
    <version>1.0.0</version>
</dependency>
```

**Использование:**

```java
import com.katya.api.KatyaClient;
import com.katya.api.models.*;

public class Example {
    public static void main(String[] args) {
        KatyaClient client = new KatyaClient.Builder()
            .baseUrl("https://api.katya.wtf/v1")
            .apiKey("YOUR_API_KEY")
            .timeout(30000)
            .build();

        try {
            // Аутентификация
            LoginResponse auth = client.auth().login(
                new LoginRequest("user@example.com", "password")
            );

            // Отправка сообщения
            Message message = client.messages().send(
                new SendMessageRequest()
                    .roomId("room_123")
                    .content("Hello, world!")
                    .messageType(MessageType.TEXT)
            );

            // Получение репутации
            Reputation reputation = client.trust().getReputation("user_456");

            System.out.println("Message sent: " + message.getId());
            System.out.println("Reputation score: " + reputation.getScore());

        } catch (KatyaException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```

### C#

**Установка (NuGet):**

```bash
Install-Package Katya.ApiClient
```

**Использование:**

```csharp
using Katya.ApiClient;
using Katya.ApiClient.Models;

class Program
{
    static async Task Main(string[] args)
    {
        var client = new KatyaClient(new KatyaConfig
        {
            BaseUrl = "https://api.katya.wtf/v1",
            ApiKey = "YOUR_API_KEY",
            Timeout = TimeSpan.FromSeconds(30)
        });

        try
        {
            // Аутентификация
            var auth = await client.Auth.LoginAsync(new LoginRequest
            {
                Email = "user@example.com",
                Password = "password"
            });

            // Отправка сообщения
            var message = await client.Messages.SendAsync(new SendMessageRequest
            {
                RoomId = "room_123",
                Content = "Hello, world!",
                MessageType = MessageType.Text
            });

            // Получение репутации
            var reputation = await client.Trust.GetReputationAsync("user_456");

            Console.WriteLine($"Message sent: {message.Id}");
            Console.WriteLine($"Reputation score: {reputation.Score:F2}");

        }
        catch (KatyaException ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
        }
    }
}
```

### PHP

**Установка (Composer):**

```bash
composer require katya/api-client
```

**Использование:**

```php
<?php
require_once 'vendor/autoload.php';

use Katya\ApiClient\KatyaClient;
use Katya\ApiClient\Models\LoginRequest;
use Katya\ApiClient\Models\SendMessageRequest;

$client = new KatyaClient([
    'base_url' => 'https://api.katya.wtf/v1',
    'api_key' => 'YOUR_API_KEY',
    'timeout' => 30
]);

try {
    // Аутентификация
    $auth = $client->auth()->login(new LoginRequest(
        'user@example.com',
        'password'
    ));

    // Отправка сообщения
    $message = $client->messages()->send(new SendMessageRequest([
        'roomId' => 'room_123',
        'content' => 'Hello, world!',
        'messageType' => 'text'
    ]));

    // Получение репутации
    $reputation = $client->trust()->getReputation('user_456');

    echo "Message sent: " . $message->getId() . "\n";
    echo "Reputation score: " . number_format($reputation->getScore(), 2) . "\n";

} catch (KatyaException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
```

### Ruby

**Установка (Gem):**

```bash
gem install katya-api-client
```

**Использование:**

```ruby
require 'katya-api-client'

client = Katya::Client.new(
  base_url: 'https://api.katya.wtf/v1',
  api_key: 'YOUR_API_KEY',
  timeout: 30
)

begin
  # Аутентификация
  auth = client.auth.login(
    email: 'user@example.com',
    password: 'password'
  )

  # Отправка сообщения
  message = client.messages.send(
    room_id: 'room_123',
    content: 'Hello, world!',
    message_type: 'text'
  )

  # Получение репутации
  reputation = client.trust.get_reputation('user_456')

  puts "Message sent: #{message.id}"
  puts "Reputation score: #{'%.2f' % reputation.score}"

rescue Katya::Error => e
  puts "Error: #{e.message}"
end
```

### Rust

**Установка (Cargo.toml):**

```toml
[dependencies]
katya-api-client = "1.0.0"
tokio = { version = "1.0", features = ["full"] }
```

**Использование:**

```rust
use katya_api_client::{KatyaClient, Config};
use katya_api_client::models::{LoginRequest, SendMessageRequest};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = KatyaClient::new(Config {
        base_url: "https://api.katya.wtf/v1".to_string(),
        api_key: Some("YOUR_API_KEY".to_string()),
        timeout: Some(std::time::Duration::from_secs(30)),
    });

    // Аутентификация
    let auth = client.auth().login(LoginRequest {
        email: "user@example.com".to_string(),
        password: "password".to_string(),
    }).await?;

    // Отправка сообщения
    let message = client.messages().send(SendMessageRequest {
        room_id: "room_123".to_string(),
        content: "Hello, world!".to_string(),
        message_type: "text".to_string(),
    }).await?;

    // Получение репутации
    let reputation = client.trust().get_reputation("user_456").await?;

    println!("Message sent: {}", message.id);
    println!("Reputation score: {:.2}", reputation.score);

    Ok(())
}
```

## Общие возможности SDK

### 1. Аутентификация

Все SDK поддерживают различные методы аутентификации:

```javascript
// JWT токен
const client = new KatyaClient({
  accessToken: "jwt_token_here",
});

// API ключ
const client = new KatyaClient({
  apiKey: "api_key_here",
});

// OAuth токен
const client = new KatyaClient({
  oauthToken: "oauth_token_here",
});
```

### 2. Автоматическое обновление токенов

SDK автоматически обновляют истекшие токены:

```javascript
client.on("tokenRefreshed", (newToken) => {
  console.log("Token refreshed:", newToken);
});

client.on("tokenRefreshFailed", (error) => {
  console.error("Token refresh failed:", error);
});
```

### 3. Rate Limiting

Встроенная поддержка rate limiting:

```javascript
const client = new KatyaClient({
  rateLimit: {
    enabled: true,
    retryAfter: true, // Автоматическое ожидание
    maxRetries: 3,
  },
});
```

### 4. Retry логика

Автоматические повторы при временных ошибках:

```javascript
const client = new KatyaClient({
  retry: {
    enabled: true,
    maxRetries: 3,
    backoff: "exponential", // exponential, linear, fixed
    baseDelay: 1000, // миллисекунды
  },
});
```

### 5. Кэширование

Встроенное кэширование для часто запрашиваемых данных:

```javascript
const client = new KatyaClient({
  cache: {
    enabled: true,
    ttl: 300, // секунды
    maxSize: 1000, // количество элементов
  },
});
```

### 6. WebSocket поддержка

Real-time обновления через WebSocket:

```javascript
const ws = client.websocket();

ws.on("message.new", (message) => {
  console.log("New message:", message);
});

ws.on("alert.created", (alert) => {
  console.log("New alert:", alert);
});

ws.subscribe(["messages", "alerts"]);
```

### 7. Batch операции

Группировка запросов для повышения эффективности:

```javascript
const batch = client.batch();

batch.add("messages.send", {
  roomId: "room_1",
  content: "Message 1",
});

batch.add("messages.send", {
  roomId: "room_2",
  content: "Message 2",
});

const results = await batch.execute();
```

### 8. Типизация (TypeScript)

Полная поддержка TypeScript с типами:

```typescript
import { KatyaClient, Message, User, Reputation } from "@katya/api-client";

const client = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
});

// Полная типизация
const message: Message = await client.messages.send({
  roomId: "room_123",
  content: "Hello!",
  messageType: "text",
});

const user: User = await client.users.getProfile("user_456");
const reputation: Reputation = await client.trust.getReputation("user_456");
```

## Конфигурация

### Переменные окружения

SDK поддерживают конфигурацию через переменные окружения:

```bash
# .env файл
KATYA_API_BASE_URL=https://api.katya.wtf/v1
KATYA_API_KEY=your_api_key_here
KATYA_API_TIMEOUT=30000
KATYA_API_RETRY_ENABLED=true
KATYA_API_RETRY_MAX_RETRIES=3
```

```javascript
// Автоматическое использование переменных окружения
const client = new KatyaClient(); // Читает из process.env
```

### Конфигурационные файлы

```yaml
# katya.yml
api:
  base_url: https://api.katya.wtf/v1
  api_key: your_api_key_here
  timeout: 30
  retry:
    enabled: true
    max_retries: 3
    backoff: exponential
  rate_limit:
    enabled: true
    retry_after: true
  cache:
    enabled: true
    ttl: 300
```

## Тестирование

### Mock сервер

SDK включают встроенный mock сервер для тестирования:

```javascript
import { MockKatyaServer } from "@katya/api-client/testing";

const mockServer = new MockKatyaServer({
  port: 3001,
  delay: 100, // Имитация задержки сети
});

// Настройка mock ответов
mockServer.mock("GET", "/v1/trust/identities", {
  status: 200,
  body: {
    success: true,
    data: [
      { id: "user_1", name: "Alice" },
      { id: "user_2", name: "Bob" },
    ],
  },
});

const client = new KatyaClient({
  baseUrl: "http://localhost:3001/v1",
});
```

### Unit тесты

```javascript
import { KatyaClient } from "@katya/api-client";
import { MockKatyaServer } from "@katya/api-client/testing";

describe("KatyaClient", () => {
  let mockServer;
  let client;

  beforeEach(() => {
    mockServer = new MockKatyaServer({ port: 3001 });
    client = new KatyaClient({ baseUrl: "http://localhost:3001/v1" });
  });

  afterEach(() => {
    mockServer.close();
  });

  it("should send message", async () => {
    mockServer.mock("POST", "/v1/messages", {
      status: 201,
      body: {
        success: true,
        data: { id: "msg_123", content: "Hello!" },
      },
    });

    const message = await client.messages.send({
      roomId: "room_123",
      content: "Hello!",
    });

    expect(message.id).toBe("msg_123");
    expect(message.content).toBe("Hello!");
  });
});
```

## Миграция между версиями

### Semver

Все SDK следуют семантическому версионированию:

- **Major** (X.0.0): Breaking changes
- **Minor** (0.X.0): Новые функции, обратная совместимость
- **Patch** (0.0.X): Исправления багов

### Changelog

```bash
# Проверка доступных обновлений
npm outdated @katya/api-client

# Обновление до последней версии
npm update @katya/api-client

# Обновление до конкретной версии
npm install @katya/api-client@2.0.0
```

### Migration Guide

Для major версий предоставляются подробные migration guides:

````markdown
# Migration Guide v1.x -> v2.x

## Breaking Changes

1. **Изменение API клиента**

   ```javascript
   // v1.x
   const client = new KatyaClient({ apiKey: "key" });

   // v2.x
   const client = new KatyaClient({
     authentication: { apiKey: "key" },
   });
   ```
````

2. **Изменение методов**

   ```javascript
   // v1.x
   client.messages.sendMessage(data);

   // v2.x
   client.messages.send(data);
   ```

```

## Поддержка

### Документация

- **API Reference**: https://docs.katya.wtf/api
- **SDK Guides**: https://docs.katya.wtf/sdks
- **Examples**: https://github.com/katya/examples

### Сообщество

- **GitHub**: https://github.com/katya
- **Discord**: https://discord.gg/katya
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/katya

### Контакты

- **Email**: sdk-support@katya.wtf
- **Issues**: https://github.com/katya/api-clients/issues
- **Status**: https://status.katya.wtf

## Лицензия

Все SDK распространяются под лицензией MIT. См. [LICENSE](./LICENSE) для подробностей.
```
