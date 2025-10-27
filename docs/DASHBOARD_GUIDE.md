# Руководство по дашборду мониторинга Katya

## Обзор

Дашборд мониторинга Katya предоставляет комплексный веб-интерфейс для мониторинга производительности, отслеживания метрик, управления алертами и анализа системных данных в реальном времени.

## Компоненты дашборда

### 1. Сервис дашборда

**Файл:** `lib/services/dashboard/dashboard_service.dart`

Центральный сервис для управления дашбордом:

#### Основные возможности:

- **Управление виджетами**: Создание, обновление и конфигурация виджетов
- **Макеты дашборда**: Создание и переключение между различными макетами
- **Темы оформления**: Поддержка светлой и темной тем
- **Пользовательские настройки**: Персонализация для каждого пользователя
- **Экспорт данных**: Экспорт дашборда в различных форматах

#### Использование:

```dart
final dashboardService = DashboardService();
await dashboardService.initialize();

// Создание виджета
dashboardService.createWidget(
  widgetId: 'cpu_usage',
  name: 'CPU Usage',
  type: WidgetType.metricCard,
  configuration: {
    'metric_name': 'system.cpu_usage',
    'unit': '%',
    'refresh_interval': 30,
  },
);

// Получение данных виджета
final data = await dashboardService.getWidgetData('cpu_usage');
```

### 2. Веб-интерфейс

**Файлы:** `web/dashboard/index.html`, `web/dashboard/styles.css`, `web/dashboard/dashboard.js`

Современный веб-интерфейс с адаптивным дизайном:

#### Основные возможности:

- **Адаптивный дизайн**: Работает на всех устройствах
- **Интерактивные виджеты**: Обновление в реальном времени
- **Темы оформления**: Переключение между светлой и темной темами
- **Поиск и фильтрация**: Быстрый поиск по метрикам и алертам
- **Экспорт данных**: Скачивание отчетов в различных форматах

## Типы виджетов

### 1. Карточка метрики (Metric Card)

Отображает ключевые метрики с трендами:

```dart
dashboardService.createWidget(
  widgetId: 'cpu_metric',
  name: 'CPU Usage',
  type: WidgetType.metricCard,
  configuration: {
    'metric_name': 'system.cpu_usage',
    'unit': '%',
    'refresh_interval': 30,
    'show_trend': true,
    'show_chart': true,
  },
);
```

**Особенности:**

- Текущее значение метрики
- Процентное изменение
- Мини-график тренда
- Цветовое кодирование (зеленый/красный)

### 2. График (Chart)

Визуализация данных в виде графиков:

```dart
dashboardService.createWidget(
  widgetId: 'performance_chart',
  name: 'System Performance',
  type: WidgetType.chart,
  configuration: {
    'chart_type': 'line',
    'data_points': 30,
    'metrics': ['cpu', 'memory', 'disk', 'network'],
    'time_range': 'last_hour',
  },
);
```

**Особенности:**

- Линейные и столбчатые графики
- Множественные метрики
- Интерактивные элементы
- Легенда и подписи

### 3. Таблица (Table)

Табличное представление данных:

```dart
dashboardService.createWidget(
  widgetId: 'users_table',
  name: 'Active Users',
  type: WidgetType.table,
  configuration: {
    'columns': ['Name', 'Status', 'Last Activity'],
    'sortable': true,
    'filterable': true,
    'pagination': true,
  },
);
```

**Особенности:**

- Сортировка по колонкам
- Фильтрация данных
- Пагинация
- Экспорт в CSV

### 4. Список алертов (Alert List)

Отображение активных системных алертов:

```dart
dashboardService.createWidget(
  widgetId: 'alerts_list',
  name: 'Active Alerts',
  type: WidgetType.alertList,
  configuration: {
    'severity_filter': ['critical', 'warning'],
    'limit': 10,
    'auto_refresh': true,
  },
);
```

**Особенности:**

- Фильтрация по серьезности
- Подтверждение алертов
- Автоматическое обновление
- Цветовое кодирование

### 5. Статус системы (System Status)

Общий статус системных компонентов:

```dart
dashboardService.createWidget(
  widgetId: 'system_status',
  name: 'System Status',
  type: WidgetType.systemStatus,
  configuration: {
    'services': ['database', 'cache', 'api', 'websocket'],
    'show_uptime': true,
    'show_response_time': true,
  },
);
```

**Особенности:**

- Статус сервисов
- Время работы (uptime)
- Время отклика
- Индикаторы состояния

### 6. Активность пользователей (User Activity)

Лог активности пользователей:

```dart
dashboardService.createWidget(
  widgetId: 'user_activity',
  name: 'User Activity',
  type: WidgetType.userActivity,
  configuration: {
    'activity_types': ['login', 'message', 'upload', 'download'],
    'time_range': 'last_hour',
    'limit': 20,
  },
);
```

**Особенности:**

- Фильтрация по типам активности
- Временные рамки
- Иконки для типов действий
- Временные метки

### 7. График производительности (Performance Graph)

Детальная визуализация производительности:

```dart
dashboardService.createWidget(
  widgetId: 'performance_graph',
  name: 'Performance Metrics',
  type: WidgetType.performanceGraph,
  configuration: {
    'metrics': ['cpu', 'memory', 'disk', 'network'],
    'time_range': 'last_24_hours',
    'chart_type': 'line',
  },
);
```

**Особенности:**

- Множественные метрики
- Различные временные рамки
- Интерактивные элементы
- Масштабирование

### 8. Просмотрщик логов (Log Viewer)

Отображение системных логов:

```dart
dashboardService.createWidget(
  widgetId: 'log_viewer',
  name: 'System Logs',
  type: WidgetType.logViewer,
  configuration: {
    'log_levels': ['error', 'warning', 'info'],
    'log_sources': ['api', 'database', 'cache'],
    'auto_scroll': true,
    'highlight_keywords': ['error', 'exception'],
  },
);
```

**Особенности:**

- Фильтрация по уровням
- Поиск по ключевым словам
- Автоматическая прокрутка
- Подсветка синтаксиса

### 9. Пользовательский HTML (Custom HTML)

Встраивание пользовательского контента:

```dart
dashboardService.createWidget(
  widgetId: 'custom_html',
  name: 'Custom Widget',
  type: WidgetType.customHtml,
  configuration: {
    'html_content': '<div>Custom content</div>',
    'css_styles': 'div { color: blue; }',
    'javascript': 'console.log("Hello");',
  },
);
```

**Особенности:**

- Произвольный HTML
- CSS стили
- JavaScript код
- Безопасное выполнение

## Макеты дашборда

### 1. Сетка (Grid)

Стандартный макет в виде сетки:

```dart
dashboardService.createLayout(
  layoutId: 'grid_layout',
  name: 'Grid Layout',
  widgetIds: ['cpu_metric', 'memory_metric', 'performance_chart'],
  type: LayoutType.grid,
  configuration: {
    'grid_columns': 3,
    'grid_rows': 2,
    'gap': 20,
    'responsive': true,
  },
);
```

### 2. Гибкий (Flex)

Адаптивный макет с гибким позиционированием:

```dart
dashboardService.createLayout(
  layoutId: 'flex_layout',
  name: 'Flex Layout',
  widgetIds: ['cpu_metric', 'memory_metric'],
  type: LayoutType.flex,
  configuration: {
    'direction': 'row',
    'wrap': true,
    'justify_content': 'space-between',
    'align_items': 'center',
  },
);
```

### 3. Пользовательский (Custom)

Полностью настраиваемый макет:

```dart
dashboardService.createLayout(
  layoutId: 'custom_layout',
  name: 'Custom Layout',
  widgetIds: ['cpu_metric', 'memory_metric'],
  type: LayoutType.custom,
  configuration: {
    'positions': {
      'cpu_metric': {'x': 0, 'y': 0, 'width': 400, 'height': 200},
      'memory_metric': {'x': 420, 'y': 0, 'width': 400, 'height': 200},
    },
  },
);
```

## Темы оформления

### 1. Светлая тема

```dart
dashboardService.createTheme(
  themeId: 'light_theme',
  name: 'Light',
  colors: {
    'primary': '#3498db',
    'secondary': '#2ecc71',
    'background': '#ffffff',
    'surface': '#f8f9fa',
    'text': '#2c3e50',
    'text_secondary': '#7f8c8d',
  },
  typography: {
    'font_family': 'Inter, sans-serif',
    'font_size_base': '14px',
    'font_weight_normal': '400',
    'font_weight_bold': '700',
  },
  isDefault: true,
);
```

### 2. Темная тема

```dart
dashboardService.createTheme(
  themeId: 'dark_theme',
  name: 'Dark',
  colors: {
    'primary': '#3498db',
    'secondary': '#2ecc71',
    'background': '#1a1a1a',
    'surface': '#2d2d2d',
    'text': '#ffffff',
    'text_secondary': '#b0b0b0',
  },
  typography: {
    'font_family': 'Inter, sans-serif',
    'font_size_base': '14px',
    'font_weight_normal': '400',
    'font_weight_bold': '700',
  },
);
```

## API дашборда

### Получение данных виджета

```javascript
// Получение данных виджета
const widgetData = await fetch("/api/dashboard/widgets/cpu_metric/data").then((response) => response.json());

console.log("Widget data:", widgetData);
```

### Обновление виджета

```javascript
// Обновление конкретного виджета
await fetch("/api/dashboard/widgets/cpu_metric/refresh", {
  method: "POST",
});
```

### Получение алертов

```javascript
// Получение активных алертов
const alerts = await fetch("/api/dashboard/alerts").then((response) => response.json());

console.log("Active alerts:", alerts);
```

### Экспорт дашборда

```javascript
// Экспорт дашборда в JSON
const exportData = await fetch("/api/dashboard/export?format=json").then((response) => response.blob());

// Скачивание файла
const url = URL.createObjectURL(exportData);
const a = document.createElement("a");
a.href = url;
a.download = "dashboard-export.json";
a.click();
```

## Конфигурация

### Настройки виджетов

```yaml
dashboard:
  widgets:
    default_refresh_interval: 30 # секунды
    max_widgets_per_layout: 20
    auto_refresh_enabled: true

  layouts:
    default_layout: grid
    allow_custom_layouts: true

  themes:
    default_theme: light
    allow_theme_switching: true

  export:
    enabled_formats: [json, csv, xml, pdf]
    max_export_size: 10485760 # 10MB
```

### Настройки производительности

```yaml
dashboard:
  performance:
    cache_widget_data: true
    cache_duration: 300 # секунды
    max_concurrent_refreshes: 5
    refresh_timeout: 30 # секунды
```

## Безопасность

### Аутентификация

```dart
// Регистрация пользователя дашборда
final user = dashboardService.registerUser(
  userId: 'user_123',
  username: 'admin',
  email: 'admin@example.com',
  roles: ['admin', 'viewer'],
  preferences: {
    'theme': 'dark',
    'auto_refresh': true,
  },
);
```

### Авторизация

```dart
// Проверка доступа к виджету
final hasAccess = await dashboardService.checkWidgetAccess(
  userId: 'user_123',
  widgetId: 'cpu_metric',
);

if (!hasAccess) {
  throw UnauthorizedException('Access denied to widget');
}
```

### Аудит

```dart
// Получение событий дашборда
final events = dashboardService.getDashboardEvents(
  userId: 'user_123',
  startDate: DateTime.now().subtract(Duration(days: 7)),
  endDate: DateTime.now(),
);
```

## Мониторинг и алерты

### Системные метрики

```dart
// Получение метрик системы
final metrics = await dashboardService.getSystemMetrics(
  category: 'system',
  startDate: DateTime.now().subtract(Duration(hours: 1)),
  endDate: DateTime.now(),
);
```

### Создание алертов

```dart
// Автоматическое создание алерта
final alert = await dashboardService.createAlert(
  title: 'High CPU Usage',
  message: 'CPU usage is at 85.2%',
  severity: AlertSeverity.critical,
  metricName: 'system.cpu_usage',
  metricValue: 85.2,
  threshold: 80.0,
);
```

### Управление алертами

```dart
// Подтверждение алерта
await dashboardService.acknowledgeAlert(
  alertId: 'alert_123',
  userId: 'user_123',
);

// Получение активных алертов
final activeAlerts = dashboardService.getActiveAlerts(
  severity: AlertSeverity.critical,
);
```

## Интеграция с внешними системами

### WebSocket подключения

```javascript
// Подключение к WebSocket для реального времени
const ws = new WebSocket("ws://localhost:8080/dashboard/ws");

ws.onmessage = function (event) {
  const data = JSON.parse(event.data);

  switch (data.type) {
    case "widget_update":
      updateWidget(data.widgetId, data.data);
      break;
    case "alert_created":
      showAlert(data.alert);
      break;
    case "metric_update":
      updateMetric(data.metricName, data.value);
      break;
  }
};
```

### REST API интеграция

```javascript
// Интеграция с внешними API
async function fetchExternalData(apiEndpoint) {
  try {
    const response = await fetch(`/api/external/${apiEndpoint}`);
    const data = await response.json();

    // Обновление виджетов с внешними данными
    updateExternalWidgets(data);
  } catch (error) {
    console.error("Failed to fetch external data:", error);
    showError("Failed to load external data");
  }
}
```

## Развертывание

### Docker контейнер

```dockerfile
FROM nginx:alpine

COPY web/dashboard/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Nginx конфигурация

```nginx
server {
    listen 80;
    server_name dashboard.katya.wtf;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://katya-backend:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /ws/ {
        proxy_pass http://katya-backend:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Kubernetes манифест

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: katya-dashboard
spec:
  replicas: 2
  selector:
    matchLabels:
      app: katya-dashboard
  template:
    metadata:
      labels:
        app: katya-dashboard
    spec:
      containers:
        - name: dashboard
          image: katya/dashboard:latest
          ports:
            - containerPort: 80
          env:
            - name: API_BASE_URL
              value: "http://katya-backend:8080"
---
apiVersion: v1
kind: Service
metadata:
  name: katya-dashboard-service
spec:
  selector:
    app: katya-dashboard
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
```

## Рекомендации по использованию

### 1. Оптимизация производительности

- Используйте кэширование для часто запрашиваемых данных
- Настройте разумные интервалы обновления виджетов
- Ограничьте количество виджетов на одном макете
- Используйте ленивую загрузку для больших данных

### 2. Пользовательский опыт

- Группируйте связанные виджеты
- Используйте интуитивные названия и описания
- Предоставляйте контекстную помощь
- Обеспечьте быструю обратную связь при действиях

### 3. Безопасность

- Регулярно обновляйте зависимости
- Используйте HTTPS для всех соединений
- Ограничьте доступ к административным функциям
- Ведите аудит всех действий пользователей

### 4. Мониторинг

- Отслеживайте производительность дашборда
- Мониторьте использование ресурсов
- Настройте алерты для критических событий
- Регулярно проверяйте логи ошибок

## Заключение

Дашборд мониторинга Katya обеспечивает:

1. **Комплексный мониторинг**: Полный обзор всех аспектов системы
2. **Интерактивность**: Обновления в реальном времени и интерактивные элементы
3. **Гибкость**: Настраиваемые виджеты, макеты и темы
4. **Производительность**: Оптимизированная работа с большими объемами данных
5. **Безопасность**: Надежная аутентификация и авторизация
6. **Масштабируемость**: Поддержка множественных пользователей и устройств

Правильное использование дашборда поможет эффективно мониторить систему, быстро выявлять проблемы и принимать обоснованные решения для оптимизации производительности.
