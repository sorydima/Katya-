# Katya API Examples

## Обзор

Этот раздел содержит практические примеры использования Katya API для различных сценариев. Примеры организованы по языкам программирования и типам приложений.

## Структура примеров

```
api/examples/
├── README.md                 # Этот файл
├── authentication/           # Примеры аутентификации
├── trust_network/           # Примеры работы с сетью доверия
├── messaging/               # Примеры обмена сообщениями
├── analytics/               # Примеры аналитики
├── security/                # Примеры безопасности
├── web_apps/                # Веб-приложения
├── mobile_apps/             # Мобильные приложения
├── desktop_apps/            # Десктопные приложения
├── bots/                    # Боты и автоматизация
└── integrations/            # Интеграции с внешними сервисами
```

## Быстрый старт

### 1. Аутентификация

```bash
# Регистрация пользователя
curl -X POST https://api.katya.wtf/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "SecurePassword123!",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Вход в систему
curl -X POST https://api.katya.wtf/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePassword123!"
  }'
```

### 2. Отправка сообщения

```bash
# Отправка сообщения (требует авторизации)
curl -X POST https://api.katya.wtf/v1/messages \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": "room_123",
    "content": "Hello, world!",
    "messageType": "text"
  }'
```

### 3. Получение репутации

```bash
# Получение репутации пользователя
curl -X GET https://api.katya.wtf/v1/trust/reputation/user_456 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Примеры по языкам

### JavaScript/Node.js

#### Простое веб-приложение

```javascript
// simple-web-app/index.js
const express = require("express");
const { KatyaClient } = require("@katya/api-client");

const app = express();
const client = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
  apiKey: process.env.KATYA_API_KEY,
});

app.get("/api/reputation/:userId", async (req, res) => {
  try {
    const reputation = await client.trust.getReputation(req.params.userId);
    res.json(reputation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

#### React компонент

```jsx
// react-component/ReputationWidget.jsx
import React, { useState, useEffect } from "react";
import { KatyaClient } from "@katya/api-client";

const ReputationWidget = ({ userId }) => {
  const [reputation, setReputation] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const client = new KatyaClient({
      baseUrl: "https://api.katya.wtf/v1",
      apiKey: process.env.REACT_APP_KATYA_API_KEY,
    });

    client.trust
      .getReputation(userId)
      .then(setReputation)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (!reputation) return <div>Error loading reputation</div>;

  return (
    <div className="reputation-widget">
      <h3>Reputation Score</h3>
      <div className="score">{reputation.score.toFixed(2)}</div>
      <div className="level">{reputation.level}</div>
    </div>
  );
};

export default ReputationWidget;
```

### Python

#### Flask приложение

```python
# flask-app/app.py
from flask import Flask, request, jsonify
from katya_api import KatyaClient
import os

app = Flask(__name__)
client = KatyaClient(
    base_url='https://api.katya.wtf/v1',
    api_key=os.getenv('KATYA_API_KEY')
)

@app.route('/api/send-message', methods=['POST'])
def send_message():
    try:
        data = request.get_json()
        message = client.messages.send({
            'roomId': data['roomId'],
            'content': data['content'],
            'messageType': 'text'
        })
        return jsonify(message)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/analytics/metrics')
def get_metrics():
    try:
        metrics = client.analytics.get_metrics(
            start_date='2024-01-01T00:00:00Z',
            end_date='2024-01-02T00:00:00Z'
        )
        return jsonify(metrics)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
```

#### Django приложение

```python
# django-app/views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from katya_api import KatyaClient
import os

client = KatyaClient(
    base_url='https://api.katya.wtf/v1',
    api_key=os.getenv('KATYA_API_KEY')
)

@csrf_exempt
@require_http_methods(["POST"])
def create_identity(request):
    try:
        data = json.loads(request.body)
        identity = client.trust.create_identity({
            'username': data['username'],
            'email': data['email'],
            'displayName': data['displayName']
        })
        return JsonResponse(identity)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@require_http_methods(["GET"])
def get_security_alerts(request):
    try:
        alerts = client.security.get_alerts(
            severity=request.GET.get('severity', 'all'),
            limit=int(request.GET.get('limit', 50))
        )
        return JsonResponse(alerts)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
```

### Go

#### HTTP сервер

```go
// go-server/main.go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"

    "github.com/katya/katya-api-go"
)

var client *katya.Client

func main() {
    client = katya.NewClient(&katya.Config{
        BaseURL: "https://api.katya.wtf/v1",
        APIKey:  os.Getenv("KATYA_API_KEY"),
    })

    http.HandleFunc("/api/rooms", handleGetRooms)
    http.HandleFunc("/api/messages", handleSendMessage)

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleGetRooms(w http.ResponseWriter, r *http.Request) {
    rooms, err := client.Rooms.List(context.Background(), &katya.ListRoomsRequest{
        Limit: 50,
        Type:  "all",
    })

    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(rooms)
}

func handleSendMessage(w http.ResponseWriter, r *http.Request) {
    var req struct {
        RoomID  string `json:"roomId"`
        Content string `json:"content"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    message, err := client.Messages.Send(context.Background(), &katya.SendMessageRequest{
        RoomID:      req.RoomID,
        Content:     req.Content,
        MessageType: "text",
    })

    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(message)
}
```

### Java

#### Spring Boot приложение

```java
// spring-boot-app/src/main/java/com/example/katya/KatyaController.java
@RestController
@RequestMapping("/api")
public class KatyaController {

    @Autowired
    private KatyaClient katyaClient;

    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = katyaClient.auth().login(request);
            return ResponseEntity.ok(response);
        } catch (KatyaException e) {
            return ResponseEntity.status(e.getStatusCode()).build();
        }
    }

    @GetMapping("/trust/reputation/{userId}")
    public ResponseEntity<Reputation> getReputation(@PathVariable String userId) {
        try {
            Reputation reputation = katyaClient.trust().getReputation(userId);
            return ResponseEntity.ok(reputation);
        } catch (KatyaException e) {
            return ResponseEntity.status(e.getStatusCode()).build();
        }
    }

    @PostMapping("/messages")
    public ResponseEntity<Message> sendMessage(@RequestBody SendMessageRequest request) {
        try {
            Message message = katyaClient.messages().send(request);
            return ResponseEntity.ok(message);
        } catch (KatyaException e) {
            return ResponseEntity.status(e.getStatusCode()).build();
        }
    }
}
```

### C#

#### ASP.NET Core приложение

```csharp
// aspnet-app/Controllers/KatyaController.cs
[ApiController]
[Route("api/[controller]")]
public class KatyaController : ControllerBase
{
    private readonly KatyaClient _katyaClient;

    public KatyaController(KatyaClient katyaClient)
    {
        _katyaClient = katyaClient;
    }

    [HttpPost("auth/login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        try
        {
            var response = await _katyaClient.Auth.LoginAsync(request);
            return Ok(response);
        }
        catch (KatyaException ex)
        {
            return StatusCode(ex.StatusCode, ex.Message);
        }
    }

    [HttpGet("trust/reputation/{userId}")]
    public async Task<ActionResult<Reputation>> GetReputation(string userId)
    {
        try
        {
            var reputation = await _katyaClient.Trust.GetReputationAsync(userId);
            return Ok(reputation);
        }
        catch (KatyaException ex)
        {
            return StatusCode(ex.StatusCode, ex.Message);
        }
    }

    [HttpPost("messages")]
    public async Task<ActionResult<Message>> SendMessage([FromBody] SendMessageRequest request)
    {
        try
        {
            var message = await _katyaClient.Messages.SendAsync(request);
            return Ok(message);
        }
        catch (KatyaException ex)
        {
            return StatusCode(ex.StatusCode, ex.Message);
        }
    }
}
```

## Примеры по типам приложений

### Веб-приложения

#### Чат-приложение

```javascript
// web-apps/chat-app/chat.js
class ChatApp {
  constructor() {
    this.client = new KatyaClient({
      baseUrl: "https://api.katya.wtf/v1",
      apiKey: process.env.KATYA_API_KEY,
    });
    this.currentRoom = null;
    this.setupEventListeners();
  }

  async joinRoom(roomId) {
    try {
      await this.client.rooms.join({ roomId });
      this.currentRoom = roomId;
      this.startMessagePolling();
    } catch (error) {
      console.error("Failed to join room:", error);
    }
  }

  async sendMessage(content) {
    if (!this.currentRoom) return;

    try {
      const message = await this.client.messages.send({
        roomId: this.currentRoom,
        content,
        messageType: "text",
      });
      this.displayMessage(message);
    } catch (error) {
      console.error("Failed to send message:", error);
    }
  }

  async startMessagePolling() {
    setInterval(async () => {
      try {
        const messages = await this.client.messages.list({
          roomId: this.currentRoom,
          limit: 50,
        });
        this.updateMessageList(messages);
      } catch (error) {
        console.error("Failed to fetch messages:", error);
      }
    }, 1000);
  }

  displayMessage(message) {
    const messageElement = document.createElement("div");
    messageElement.className = "message";
    messageElement.innerHTML = `
      <div class="message-header">
        <span class="sender">${message.sender.name}</span>
        <span class="timestamp">${new Date(message.createdAt).toLocaleTimeString()}</span>
      </div>
      <div class="message-content">${message.content}</div>
    `;
    document.getElementById("messages").appendChild(messageElement);
  }

  setupEventListeners() {
    document.getElementById("sendButton").addEventListener("click", () => {
      const input = document.getElementById("messageInput");
      if (input.value.trim()) {
        this.sendMessage(input.value.trim());
        input.value = "";
      }
    });
  }
}

// Инициализация приложения
const chatApp = new ChatApp();
```

#### Дашборд аналитики

```javascript
// web-apps/analytics-dashboard/dashboard.js
class AnalyticsDashboard {
  constructor() {
    this.client = new KatyaClient({
      baseUrl: "https://api.katya.wtf/v1",
      apiKey: process.env.KATYA_API_KEY,
    });
    this.charts = {};
    this.init();
  }

  async init() {
    await this.loadDashboard();
    this.setupAutoRefresh();
  }

  async loadDashboard() {
    try {
      // Загружаем метрики
      const metrics = await this.client.analytics.getMetrics({
        startDate: this.getStartDate(),
        endDate: this.getEndDate(),
        granularity: "1h",
      });

      // Создаем графики
      this.createCpuChart(metrics.cpu);
      this.createMemoryChart(metrics.memory);
      this.createNetworkChart(metrics.network);

      // Загружаем алерты
      const alerts = await this.client.security.getAlerts({
        severity: "all",
        limit: 10,
      });
      this.updateAlertsList(alerts);
    } catch (error) {
      console.error("Failed to load dashboard:", error);
    }
  }

  createCpuChart(cpuData) {
    const ctx = document.getElementById("cpuChart").getContext("2d");
    this.charts.cpu = new Chart(ctx, {
      type: "line",
      data: {
        labels: cpuData.map((d) => new Date(d.timestamp).toLocaleTimeString()),
        datasets: [
          {
            label: "CPU Usage %",
            data: cpuData.map((d) => d.value),
            borderColor: "rgb(75, 192, 192)",
            tension: 0.1,
          },
        ],
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
          },
        },
      },
    });
  }

  setupAutoRefresh() {
    setInterval(() => {
      this.loadDashboard();
    }, 30000); // Обновляем каждые 30 секунд
  }

  getStartDate() {
    const now = new Date();
    const start = new Date(now.getTime() - 24 * 60 * 60 * 1000); // 24 часа назад
    return start.toISOString();
  }

  getEndDate() {
    return new Date().toISOString();
  }
}

// Инициализация дашборда
const dashboard = new AnalyticsDashboard();
```

### Мобильные приложения

#### React Native приложение

```javascript
// mobile-apps/react-native/MessagingScreen.js
import React, { useState, useEffect } from "react";
import { View, Text, FlatList, TextInput, TouchableOpacity } from "react-native";
import { KatyaClient } from "@katya/api-client";

const MessagingScreen = ({ route }) => {
  const { roomId } = route.params;
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [client] = useState(
    new KatyaClient({
      baseUrl: "https://api.katya.wtf/v1",
      apiKey: "YOUR_API_KEY",
    })
  );

  useEffect(() => {
    loadMessages();
    setupMessagePolling();
  }, []);

  const loadMessages = async () => {
    try {
      const messageList = await client.messages.list({
        roomId,
        limit: 50,
      });
      setMessages(messageList);
    } catch (error) {
      console.error("Failed to load messages:", error);
    }
  };

  const setupMessagePolling = () => {
    setInterval(loadMessages, 2000); // Обновляем каждые 2 секунды
  };

  const sendMessage = async () => {
    if (!newMessage.trim()) return;

    try {
      await client.messages.send({
        roomId,
        content: newMessage.trim(),
        messageType: "text",
      });
      setNewMessage("");
      loadMessages(); // Перезагружаем сообщения
    } catch (error) {
      console.error("Failed to send message:", error);
    }
  };

  const renderMessage = ({ item }) => (
    <View style={styles.messageContainer}>
      <Text style={styles.senderName}>{item.sender.name}</Text>
      <Text style={styles.messageContent}>{item.content}</Text>
      <Text style={styles.timestamp}>{new Date(item.createdAt).toLocaleTimeString()}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={messages}
        renderItem={renderMessage}
        keyExtractor={(item) => item.id}
        style={styles.messageList}
      />
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.textInput}
          value={newMessage}
          onChangeText={setNewMessage}
          placeholder="Type a message..."
        />
        <TouchableOpacity style={styles.sendButton} onPress={sendMessage}>
          <Text style={styles.sendButtonText}>Send</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f5f5f5",
  },
  messageList: {
    flex: 1,
    padding: 16,
  },
  messageContainer: {
    backgroundColor: "white",
    padding: 12,
    marginVertical: 4,
    borderRadius: 8,
  },
  senderName: {
    fontWeight: "bold",
    fontSize: 14,
  },
  messageContent: {
    fontSize: 16,
    marginVertical: 4,
  },
  timestamp: {
    fontSize: 12,
    color: "#666",
  },
  inputContainer: {
    flexDirection: "row",
    padding: 16,
    backgroundColor: "white",
    borderTopWidth: 1,
    borderTopColor: "#ddd",
  },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 8,
  },
  sendButton: {
    backgroundColor: "#007AFF",
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    justifyContent: "center",
  },
  sendButtonText: {
    color: "white",
    fontWeight: "bold",
  },
});

export default MessagingScreen;
```

#### Flutter приложение

```dart
// mobile-apps/flutter/lib/screens/messaging_screen.dart
import 'package:flutter/material.dart';
import 'package:katya_api_client/katya_api_client.dart';

class MessagingScreen extends StatefulWidget {
  final String roomId;

  const MessagingScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final KatyaClient _client = KatyaClient(
    baseUrl: 'https://api.katya.wtf/v1',
    apiKey: 'YOUR_API_KEY',
  );

  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupMessagePolling();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _client.messages.list(
        roomId: widget.roomId,
        limit: 50,
      );
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (error) {
      print('Failed to load messages: $error');
      setState(() => _isLoading = false);
    }
  }

  void _setupMessagePolling() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      _loadMessages();
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      await _client.messages.send(SendMessageRequest(
        roomId: widget.roomId,
        content: content,
        messageType: MessageType.text,
      ));
      _messageController.clear();
      _loadMessages();
    } catch (error) {
      print('Failed to send message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.sender.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            message.content,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Боты и автоматизация

#### Discord бот

```javascript
// bots/discord-bot/bot.js
const { Client, GatewayIntentBits } = require("discord.js");
const { KatyaClient } = require("@katya/api-client");

const discordClient = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages],
});

const katyaClient = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
  apiKey: process.env.KATYA_API_KEY,
});

discordClient.on("messageCreate", async (message) => {
  if (message.author.bot) return;

  // Команда для получения репутации
  if (message.content.startsWith("!reputation")) {
    try {
      const userId = message.content.split(" ")[1];
      if (!userId) {
        message.reply("Usage: !reputation <user_id>");
        return;
      }

      const reputation = await katyaClient.trust.getReputation(userId);
      message.reply(`Reputation for user ${userId}: ${reputation.score.toFixed(2)} (${reputation.level})`);
    } catch (error) {
      message.reply("Failed to get reputation: " + error.message);
    }
  }

  // Команда для отправки сообщения в Katya
  if (message.content.startsWith("!send")) {
    try {
      const parts = message.content.split(" ");
      const roomId = parts[1];
      const content = parts.slice(2).join(" ");

      if (!roomId || !content) {
        message.reply("Usage: !send <room_id> <message>");
        return;
      }

      const katyaMessage = await katyaClient.messages.send({
        roomId,
        content,
        messageType: "text",
        metadata: {
          source: "discord",
          discordUserId: message.author.id,
          discordUsername: message.author.username,
        },
      });

      message.reply(`Message sent to Katya room ${roomId}: ${katyaMessage.id}`);
    } catch (error) {
      message.reply("Failed to send message: " + error.message);
    }
  }

  // Команда для получения алертов безопасности
  if (message.content.startsWith("!alerts")) {
    try {
      const alerts = await katyaClient.security.getAlerts({
        severity: "high",
        limit: 5,
      });

      if (alerts.length === 0) {
        message.reply("No high-severity security alerts found.");
        return;
      }

      let alertText = "Recent high-severity security alerts:\n";
      alerts.forEach((alert) => {
        alertText += `• ${alert.title} (${alert.severity}) - ${alert.description}\n`;
      });

      message.reply(alertText);
    } catch (error) {
      message.reply("Failed to get alerts: " + error.message);
    }
  }
});

discordClient.login(process.env.DISCORD_TOKEN);
```

#### Telegram бот

```python
# bots/telegram-bot/bot.py
import asyncio
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from katya_api import KatyaClient

# Инициализация клиентов
katya_client = KatyaClient(
    base_url='https://api.katya.wtf/v1',
    api_key='YOUR_API_KEY'
)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Отправляет сообщение при получении команды /start."""
    await update.message.reply_text(
        'Привет! Я Katya бот. Доступные команды:\n'
        '/reputation <user_id> - получить репутацию пользователя\n'
        '/send <room_id> <message> - отправить сообщение в Katya\n'
        '/alerts - получить алерты безопасности'
    )

async def get_reputation(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Получает репутацию пользователя."""
    if not context.args:
        await update.message.reply_text('Usage: /reputation <user_id>')
        return

    user_id = context.args[0]
    try:
        reputation = katya_client.trust.get_reputation(user_id)
        await update.message.reply_text(
            f'Reputation for user {user_id}: {reputation.score:.2f} ({reputation.level})'
        )
    except Exception as e:
        await update.message.reply_text(f'Failed to get reputation: {str(e)}')

async def send_message(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Отправляет сообщение в Katya."""
    if len(context.args) < 2:
        await update.message.reply_text('Usage: /send <room_id> <message>')
        return

    room_id = context.args[0]
    content = ' '.join(context.args[1:])

    try:
        message = katya_client.messages.send({
            'roomId': room_id,
            'content': content,
            'messageType': 'text',
            'metadata': {
                'source': 'telegram',
                'telegramUserId': str(update.effective_user.id),
                'telegramUsername': update.effective_user.username
            }
        })
        await update.message.reply_text(f'Message sent to Katya room {room_id}: {message.id}')
    except Exception as e:
        await update.message.reply_text(f'Failed to send message: {str(e)}')

async def get_alerts(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Получает алерты безопасности."""
    try:
        alerts = katya_client.security.get_alerts(severity='high', limit=5)

        if not alerts:
            await update.message.reply_text('No high-severity security alerts found.')
            return

        alert_text = 'Recent high-severity security alerts:\n'
        for alert in alerts:
            alert_text += f'• {alert.title} ({alert.severity}) - {alert.description}\n'

        await update.message.reply_text(alert_text)
    except Exception as e:
        await update.message.reply_text(f'Failed to get alerts: {str(e)}')

def main() -> None:
    """Запускает бота."""
    application = Application.builder().token('YOUR_TELEGRAM_TOKEN').build()

    # Добавляем обработчики команд
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("reputation", get_reputation))
    application.add_handler(CommandHandler("send", send_message))
    application.add_handler(CommandHandler("alerts", get_alerts))

    # Запускаем бота
    application.run_polling()

if __name__ == '__main__':
    main()
```

### Интеграции

#### Slack интеграция

```javascript
// integrations/slack/slack-app.js
const { App } = require("@slack/bolt");
const { KatyaClient } = require("@katya/api-client");

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET,
});

const katyaClient = new KatyaClient({
  baseUrl: "https://api.katya.wtf/v1",
  apiKey: process.env.KATYA_API_KEY,
});

// Команда /katya-reputation
app.command("/katya-reputation", async ({ command, ack, respond }) => {
  await ack();

  const userId = command.text.trim();
  if (!userId) {
    await respond("Usage: /katya-reputation <user_id>");
    return;
  }

  try {
    const reputation = await katyaClient.trust.getReputation(userId);
    await respond({
      text: `Reputation for user ${userId}:`,
      attachments: [
        {
          color: reputation.score > 0.8 ? "good" : reputation.score > 0.5 ? "warning" : "danger",
          fields: [
            {
              title: "Score",
              value: reputation.score.toFixed(2),
              short: true,
            },
            {
              title: "Level",
              value: reputation.level,
              short: true,
            },
            {
              title: "Verifications",
              value: reputation.verificationCount.toString(),
              short: true,
            },
          ],
        },
      ],
    });
  } catch (error) {
    await respond(`Failed to get reputation: ${error.message}`);
  }
});

// Команда /katya-send
app.command("/katya-send", async ({ command, ack, respond }) => {
  await ack();

  const parts = command.text.split(" ");
  const roomId = parts[0];
  const content = parts.slice(1).join(" ");

  if (!roomId || !content) {
    await respond("Usage: /katya-send <room_id> <message>");
    return;
  }

  try {
    const message = await katyaClient.messages.send({
      roomId,
      content,
      messageType: "text",
      metadata: {
        source: "slack",
        slackUserId: command.user_id,
        slackChannelId: command.channel_id,
      },
    });

    await respond(`Message sent to Katya room ${roomId}: ${message.id}`);
  } catch (error) {
    await respond(`Failed to send message: ${error.message}`);
  }
});

// Webhook для получения уведомлений от Katya
app.post("/katya-webhook", async (req, res) => {
  const { event, data } = req.body;

  switch (event) {
    case "security.alert.created":
      // Отправляем алерт в Slack канал
      await app.client.chat.postMessage({
        channel: "#security-alerts",
        text: `🚨 Security Alert: ${data.title}`,
        attachments: [
          {
            color: "danger",
            fields: [
              {
                title: "Severity",
                value: data.severity,
                short: true,
              },
              {
                title: "Description",
                value: data.description,
                short: false,
              },
            ],
          },
        ],
      });
      break;

    case "message.new":
      // Отправляем уведомление о новом сообщении
      await app.client.chat.postMessage({
        channel: "#katya-notifications",
        text: `💬 New message in room ${data.roomId}`,
        attachments: [
          {
            fields: [
              {
                title: "Sender",
                value: data.sender.name,
                short: true,
              },
              {
                title: "Content",
                value: data.content,
                short: false,
              },
            ],
          },
        ],
      });
      break;
  }

  res.status(200).send("OK");
});

(async () => {
  await app.start(process.env.PORT || 3000);
  console.log("⚡️ Slack app is running!");
})();
```

## Запуск примеров

### Требования

1. **Node.js** (для JavaScript примеров)
2. **Python 3.7+** (для Python примеров)
3. **Go 1.19+** (для Go примеров)
4. **Java 11+** (для Java примеров)
5. **.NET 6.0+** (для C# примеров)

### Настройка

1. **Клонируйте репозиторий:**

   ```bash
   git clone https://github.com/katya/katya.git
   cd katya/api/examples
   ```

2. **Установите зависимости:**

   ```bash
   # Для JavaScript
   npm install

   # Для Python
   pip install -r requirements.txt

   # Для Go
   go mod tidy
   ```

3. **Настройте переменные окружения:**

   ```bash
   export KATYA_API_KEY="your_api_key_here"
   export KATYA_API_BASE_URL="https://api.katya.wtf/v1"
   ```

4. **Запустите примеры:**

   ```bash
   # Веб-приложение
   npm run start:web-app

   # Мобильное приложение
   npm run start:mobile-app

   # Бот
   npm run start:bot
   ```

## Поддержка

### Документация

- **API Reference**: https://docs.katya.wtf/api
- **SDK Documentation**: https://docs.katya.wtf/sdks
- **Postman Collection**: [collection.json](../postman/collection.json)

### Сообщество

- **GitHub**: https://github.com/katya/examples
- **Discord**: https://discord.gg/katya
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/katya

### Контакты

- **Email**: examples@katya.wtf
- **Issues**: https://github.com/katya/examples/issues
- **Status**: https://status.katya.wtf
