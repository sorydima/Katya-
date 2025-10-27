# Руководство по аутентификации Katya API

## Обзор

Katya API использует многоуровневую систему аутентификации, основанную на JWT токенах и ролевой модели доступа. Этот документ описывает все аспекты аутентификации и авторизации.

## Типы аутентификации

### 1. Bearer Token (JWT)

Основной метод аутентификации для API запросов:

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
     https://api.katya.wtf/v1/trust/identities
```

### 2. API Key

Для серверных приложений и автоматизации:

```bash
curl -H "X-API-Key: katya_sk_1234567890abcdef..." \
     https://api.katya.wtf/v1/trust/identities
```

### 3. OAuth 2.0

Для интеграции с внешними приложениями:

```bash
curl -H "Authorization: Bearer oauth_access_token..." \
     https://api.katya.wtf/v1/trust/identities
```

## Регистрация и вход

### Регистрация пользователя

```bash
POST /v1/auth/register
```

**Запрос:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePassword123!",
  "firstName": "John",
  "lastName": "Doe",
  "organization": "Acme Corp",
  "timezone": "UTC",
  "language": "en"
}
```

**Ответ (201):**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "username": "john_doe",
      "email": "john@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "roles": ["user"],
      "permissions": ["read:profile", "write:messages"],
      "createdAt": "2024-01-01T00:00:00Z",
      "lastLoginAt": null
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  }
}
```

### Вход в систему

```bash
POST /v1/auth/login
```

**Запрос:**

```json
{
  "email": "john@example.com",
  "password": "SecurePassword123!",
  "rememberMe": true
}
```

**Ответ (200):**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "username": "john_doe",
      "email": "john@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "roles": ["user"],
      "permissions": ["read:profile", "write:messages"],
      "lastLoginAt": "2024-01-01T12:00:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  }
}
```

### Обновление токена

```bash
POST /v1/auth/refresh
```

**Запрос:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Ответ (200):**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

## JWT токены

### Структура токена

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_123",
    "username": "john_doe",
    "email": "john@example.com",
    "roles": ["user"],
    "permissions": ["read:profile", "write:messages", "read:trust_network"],
    "iat": 1704067200,
    "exp": 1704070800,
    "iss": "katya-api",
    "aud": "katya-client"
  }
}
```

### Время жизни токенов

- **Access Token**: 1 час (3600 секунд)
- **Refresh Token**: 30 дней (2592000 секунд)
- **API Key**: Без ограничения по времени

## Роли и разрешения

### Роли пользователей

| Роль          | Описание                      | Разрешения                 |
| ------------- | ----------------------------- | -------------------------- |
| `guest`       | Неавторизованный пользователь | Только публичные эндпоинты |
| `user`        | Обычный пользователь          | Базовые операции           |
| `premium`     | Премиум пользователь          | Расширенные функции        |
| `moderator`   | Модератор                     | Модерация контента         |
| `admin`       | Администратор                 | Управление системой        |
| `super_admin` | Супер-администратор           | Полный доступ              |

### Разрешения

#### Профиль пользователя

- `read:profile` - Чтение профиля
- `write:profile` - Изменение профиля
- `delete:profile` - Удаление профиля

#### Сообщения

- `read:messages` - Чтение сообщений
- `write:messages` - Отправка сообщений
- `delete:messages` - Удаление сообщений
- `moderate:messages` - Модерация сообщений

#### Сеть доверия

- `read:trust_network` - Чтение сети доверия
- `write:trust_network` - Изменение сети доверия
- `verify:identities` - Верификация идентичностей
- `manage:reputation` - Управление репутацией

#### Аналитика

- `read:analytics` - Чтение аналитики
- `write:analytics` - Создание отчетов
- `export:analytics` - Экспорт данных

#### Администрирование

- `read:admin` - Административная панель
- `write:admin` - Изменение настроек
- `manage:users` - Управление пользователями
- `manage:system` - Управление системой

## Безопасность

### Валидация паролей

Пароли должны соответствовать следующим требованиям:

- Минимум 8 символов
- Содержать заглавные и строчные буквы
- Содержать цифры
- Содержать специальные символы
- Не быть в списке часто используемых паролей

### Двухфакторная аутентификация (2FA)

```bash
POST /v1/auth/2fa/enable
```

**Запрос:**

```json
{
  "method": "totp"
}
```

**Ответ (200):**

```json
{
  "success": true,
  "data": {
    "secret": "JBSWY3DPEHPK3PXP",
    "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  }
}
```

### Вход с 2FA

```bash
POST /v1/auth/login
```

**Запрос:**

```json
{
  "email": "john@example.com",
  "password": "SecurePassword123!",
  "totpCode": "123456"
}
```

### Блокировка аккаунта

Аккаунт блокируется после:

- 5 неудачных попыток входа в течение 15 минут
- 10 неудачных попыток в течение часа
- 20 неудачных попыток в течение дня

### Сброс пароля

```bash
POST /v1/auth/forgot-password
```

**Запрос:**

```json
{
  "email": "john@example.com"
}
```

```bash
POST /v1/auth/reset-password
```

**Запрос:**

```json
{
  "token": "reset_token_123",
  "newPassword": "NewSecurePassword123!"
}
```

## API ключи

### Создание API ключа

```bash
POST /v1/auth/api-keys
```

**Запрос:**

```json
{
  "name": "Production API Key",
  "description": "API key for production application",
  "permissions": ["read:trust_network", "write:messages"],
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

**Ответ (201):**

```json
{
  "success": true,
  "data": {
    "apiKey": {
      "id": "key_123",
      "name": "Production API Key",
      "key": "katya_sk_1234567890abcdef...",
      "permissions": ["read:trust_network", "write:messages"],
      "createdAt": "2024-01-01T00:00:00Z",
      "expiresAt": "2024-12-31T23:59:59Z",
      "lastUsedAt": null
    }
  }
}
```

### Управление API ключами

```bash
GET /v1/auth/api-keys
```

```bash
PUT /v1/auth/api-keys/{id}
```

```bash
DELETE /v1/auth/api-keys/{id}
```

## OAuth 2.0 интеграция

### Поддерживаемые провайдеры

- Google
- GitHub
- Microsoft
- Discord
- Matrix

### Авторизация через OAuth

```bash
GET /v1/auth/oauth/{provider}
```

**Пример для Google:**

```
https://api.katya.wtf/v1/auth/oauth/google?redirect_uri=https://app.katya.wtf/callback
```

### Обработка callback

```bash
POST /v1/auth/oauth/callback
```

**Запрос:**

```json
{
  "provider": "google",
  "code": "authorization_code_123",
  "state": "random_state_string"
}
```

## Обработка ошибок

### Коды ошибок аутентификации

| Код                             | Описание                |
| ------------------------------- | ----------------------- |
| `AUTH_INVALID_CREDENTIALS`      | Неверные учетные данные |
| `AUTH_ACCOUNT_LOCKED`           | Аккаунт заблокирован    |
| `AUTH_TOKEN_EXPIRED`            | Токен истек             |
| `AUTH_TOKEN_INVALID`            | Неверный токен          |
| `AUTH_INSUFFICIENT_PERMISSIONS` | Недостаточно прав       |
| `AUTH_2FA_REQUIRED`             | Требуется 2FA           |
| `AUTH_2FA_INVALID`              | Неверный 2FA код        |

### Примеры ошибок

**401 Unauthorized:**

```json
{
  "success": false,
  "error": {
    "code": "AUTH_TOKEN_EXPIRED",
    "message": "Access token has expired",
    "details": {
      "expiredAt": "2024-01-01T12:00:00Z"
    }
  }
}
```

**403 Forbidden:**

```json
{
  "success": false,
  "error": {
    "code": "AUTH_INSUFFICIENT_PERMISSIONS",
    "message": "Insufficient permissions to access this resource",
    "details": {
      "required": ["admin:manage"],
      "current": ["user:read"]
    }
  }
}
```

## Лучшие практики

### Безопасное хранение токенов

**JavaScript (браузер):**

```javascript
// Используйте httpOnly cookies для refresh токенов
// Храните access токены в memory или sessionStorage
const accessToken = sessionStorage.getItem("accessToken");

// Не храните токены в localStorage для длительного периода
```

**Node.js:**

```javascript
// Используйте переменные окружения для API ключей
const apiKey = process.env.KATYA_API_KEY;

// Храните токены в зашифрованном виде
const encryptedToken = encrypt(token, secretKey);
```

**Python:**

```python
import os
from cryptography.fernet import Fernet

# Используйте переменные окружения
api_key = os.getenv('KATYA_API_KEY')

# Шифрование токенов
cipher_suite = Fernet(encryption_key)
encrypted_token = cipher_suite.encrypt(token.encode())
```

### Автоматическое обновление токенов

```javascript
class KatyaClient {
  constructor(config) {
    this.baseURL = config.baseURL;
    this.accessToken = config.accessToken;
    this.refreshToken = config.refreshToken;
  }

  async makeRequest(endpoint, options = {}) {
    try {
      return await this._request(endpoint, options);
    } catch (error) {
      if (error.status === 401 && error.code === "AUTH_TOKEN_EXPIRED") {
        await this.refreshAccessToken();
        return await this._request(endpoint, options);
      }
      throw error;
    }
  }

  async refreshAccessToken() {
    const response = await fetch(`${this.baseURL}/v1/auth/refresh`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        refreshToken: this.refreshToken,
      }),
    });

    const data = await response.json();
    this.accessToken = data.data.accessToken;
  }
}
```

### Обработка истечения токенов

```python
import requests
import time

class KatyaClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.access_token = None
        self.refresh_token = None
        self.token_expires_at = None

    def _is_token_expired(self):
        if not self.token_expires_at:
            return True
        return time.time() >= self.token_expires_at

    def _refresh_token_if_needed(self):
        if self._is_token_expired():
            self._refresh_access_token()

    def _refresh_access_token(self):
        response = requests.post(
            f"{self.base_url}/v1/auth/refresh",
            json={"refreshToken": self.refresh_token}
        )
        data = response.json()
        self.access_token = data['data']['accessToken']
        self.token_expires_at = time.time() + 3600  # 1 hour

    def make_request(self, method, endpoint, **kwargs):
        self._refresh_token_if_needed()
        headers = kwargs.get('headers', {})
        headers['Authorization'] = f'Bearer {self.access_token}'
        kwargs['headers'] = headers
        return requests.request(method, f"{self.base_url}{endpoint}", **kwargs)
```

## Мониторинг и аудит

### Логи аутентификации

Все события аутентификации логируются:

```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "event": "user_login",
  "userId": "user_123",
  "ipAddress": "192.168.1.1",
  "userAgent": "Mozilla/5.0...",
  "success": true,
  "metadata": {
    "loginMethod": "password",
    "twoFactorUsed": false
  }
}
```

### Получение логов

```bash
GET /v1/auth/logs?userId=user_123&event=login&startDate=2024-01-01&endDate=2024-01-02
```

### Подозрительная активность

Система автоматически детектирует:

- Множественные неудачные попытки входа
- Входы из необычных локаций
- Одновременные входы с разных устройств
- Использование скомпрометированных токенов

## Миграция и обновления

### Обновление токенов

При изменении алгоритма подписи токенов:

1. Старые токены продолжают работать
2. Новые токены используют новый алгоритм
3. Постепенная миграция в течение 30 дней

### Изменение разрешений

При изменении ролей или разрешений:

1. Уведомление пользователей
2. Обновление токенов при следующем refresh
3. Валидация доступа на каждом запросе

## Поддержка

### Контакты

- **Email**: security@katya.wtf
- **Security Issues**: security@katya.wtf
- **Discord**: https://discord.gg/katya

### Документация

- **OpenAPI спецификация**: [openapi.yaml](./openapi.yaml)
- **JWT библиотеки**: https://jwt.io/libraries
- **OAuth 2.0 спецификация**: https://tools.ietf.org/html/rfc6749
