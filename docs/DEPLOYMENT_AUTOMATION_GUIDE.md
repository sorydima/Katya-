# Руководство по автоматизации развертывания Katya

## Обзор

Система Katya включает в себя комплексную автоматизацию развертывания с поддержкой CI/CD, контейнеризации, оркестрации и мониторинга. Это руководство описывает все аспекты автоматизации развертывания.

## Архитектура развертывания

### Компоненты системы

1. **GitHub Actions** - CI/CD пайплайны
2. **Docker** - Контейнеризация приложений
3. **Kubernetes** - Оркестрация контейнеров
4. **Helm** - Управление пакетами
5. **Prometheus + Grafana** - Мониторинг
6. **Nginx** - Reverse proxy и load balancer

### Схема развертывания

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │   Local   │  │    │  │ Kubernetes│  │    │  │ Kubernetes│  │
│  │  Docker   │  │    │  │  Cluster  │  │    │  │  Cluster  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  GitHub Actions │
                    │   CI/CD Pipeline│
                    └─────────────────┘
```

## GitHub Actions CI/CD

### Continuous Integration (CI)

Файл: `.github/workflows/ci.yml`

#### Этапы CI:

1. **Code Quality**

   - Анализ кода (Dart, JavaScript, Python, Go)
   - Проверка форматирования
   - Запуск unit тестов
   - Проверка покрытия кода

2. **Build**

   - Сборка Flutter приложения для разных платформ
   - Сборка Docker образов для всех сервисов
   - Создание артефактов

3. **Security**

   - Сканирование уязвимостей (Trivy)
   - Анализ кода (CodeQL)
   - Проверка зависимостей

4. **Testing**
   - Интеграционные тесты
   - E2E тесты
   - Нагрузочное тестирование

#### Использование:

```bash
# Автоматический запуск при push в main/develop
git push origin main

# Ручной запуск
gh workflow run ci.yml
```

### Continuous Deployment (CD)

Файл: `.github/workflows/cd.yml`

#### Этапы CD:

1. **Определение стратегии**

   - Автоматическое определение окружения
   - Выбор типа развертывания
   - Генерация версии

2. **Подготовка**

   - Генерация конфигураций
   - Валидация манифестов
   - Создание артефактов

3. **Развертывание**

   - Staging: Rolling update
   - Production: Blue-Green deployment
   - Автоматический rollback при ошибках

4. **Post-deployment**
   - Проверка здоровья сервисов
   - Запуск тестов
   - Обновление мониторинга

#### Использование:

```bash
# Автоматический запуск при push в main/staging
git push origin main

# Ручной запуск с выбором окружения
gh workflow run cd.yml -f environment=production
```

## Docker контейнеризация

### Multi-stage сборка

#### API сервис (`docker/api/Dockerfile`):

```dockerfile
# Base stage
FROM node:18-alpine AS base
RUN apk add --no-cache curl dumb-init
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Development stage
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js"]

# Production stage
FROM base AS production
COPY --chown=katya:nodejs . .
USER katya
HEALTHCHECK --interval=30s CMD curl -f http://localhost:3000/health
CMD ["dumb-init", "node", "src/index.js"]
```

#### Web фронтенд (`docker/web/Dockerfile`):

```dockerfile
# Builder stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY docker/web/nginx.conf /etc/nginx/nginx.conf
EXPOSE 3001
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

#### Development (`docker-compose.yml`):

```yaml
version: "3.8"
services:
  api:
    build:
      context: .
      dockerfile: docker/api/Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://katya:katya@postgres:5432/katya
    depends_on:
      - postgres
      - redis
```

#### Production (`docker-compose.production.yml`):

```yaml
version: "3.8"
services:
  api:
    image: katya/api:latest
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "2.0"
          memory: 2G
        reservations:
          cpus: "1.0"
          memory: 1G
    restart: always
```

### Использование Docker Compose:

```bash
# Development
docker-compose up -d

# Production
docker-compose -f docker-compose.production.yml up -d

# Остановка
docker-compose down

# Логи
docker-compose logs -f api
```

## Kubernetes оркестрация

### Структура манифестов

```
k8s/
├── base/                    # Базовые манифесты
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment-api.yaml
│   ├── service-api.yaml
│   └── ...
├── overlays/
│   ├── staging/            # Staging конфигурация
│   │   ├── kustomization.yaml
│   │   ├── configmap-staging.yaml
│   │   └── ...
│   └── production/         # Production конфигурация
│       ├── kustomization.yaml
│       ├── configmap-production.yaml
│       └── ...
```

### Базовые манифесты

#### Namespace (`k8s/base/namespace.yaml`):

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: katya
  labels:
    name: katya
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: katya-quota
  namespace: katya
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
```

#### Deployment (`k8s/base/deployment-api.yaml`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: katya
spec:
  replicas: 3
  selector:
    matchLabels:
      app: katya-api
  template:
    metadata:
      labels:
        app: katya-api
    spec:
      containers:
        - name: api
          image: katya/api:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: katya-secrets
                  key: database-url
          resources:
            requests:
              cpu: "500m"
              memory: "1Gi"
            limits:
              cpu: "2"
              memory: "2Gi"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
```

### Overlay конфигурации

#### Production (`k8s/overlays/production/kustomization.yaml`):

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: katya-production

resources:
  - ../../base

patchesJson6902:
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: api
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
      - op: replace
        path: /spec/template/spec/containers/0/resources/limits/cpu
        value: "4"

images:
  - name: katya/api
    newTag: production-latest
```

### Применение манифестов:

```bash
# Staging
kubectl apply -k k8s/overlays/staging

# Production
kubectl apply -k k8s/overlays/production

# Проверка статуса
kubectl get pods -n katya-production
kubectl rollout status deployment/api -n katya-production
```

## Скрипт автоматизации

### Deployment Script (`scripts/deploy.sh`)

#### Основные команды:

```bash
# Развертывание
./scripts/deploy.sh deploy staging v1.2.3
./scripts/deploy.sh deploy production v1.2.3 ghcr.io/katya

# Откат
./scripts/deploy.sh rollback staging

# Проверка здоровья
./scripts/deploy.sh health production

# Тестирование
./scripts/deploy.sh test staging
```

#### Функциональность:

1. **Проверка зависимостей** - Docker, kubectl, helm
2. **Создание namespace** - Автоматическое создание
3. **Применение секретов** - Безопасное управление
4. **Сборка образов** - Multi-service build
5. **Развертывание** - Kustomize application
6. **Проверка здоровья** - Health checks
7. **Тестирование** - Smoke и интеграционные тесты
8. **Откат** - Автоматический rollback
9. **Уведомления** - Slack интеграция

#### Использование:

```bash
# Установка прав
chmod +x scripts/deploy.sh

# Настройка переменных окружения
export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."
export POSTGRES_PASSWORD="secure_password"
export JWT_SECRET="your_jwt_secret"

# Развертывание
./scripts/deploy.sh deploy staging v1.2.3
```

## Мониторинг и наблюдаемость

### Prometheus конфигурация

#### Основной файл (`monitoring/prometheus.yml`):

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "katya-api"
    static_configs:
      - targets: ["api:9090"]
    metrics_path: "/metrics"
    scrape_interval: 10s
```

### Grafana дашборды

#### System Overview (`monitoring/grafana/dashboards/katya-overview.json`):

- API Requests per Second
- API Response Time
- System CPU/Memory Usage
- Database Connections
- Redis Memory Usage
- WebSocket Connections
- Trust Network Verifications
- Message Throughput
- Security Alerts

### Настройка мониторинга:

```bash
# Запуск Prometheus
docker-compose up -d prometheus

# Запуск Grafana
docker-compose up -d grafana

# Доступ к Grafana
open http://localhost:3002
# Login: admin / admin
```

## Стратегии развертывания

### Rolling Update (Staging)

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

**Преимущества:**

- Постепенное обновление
- Минимальный downtime
- Простота реализации

**Недостатки:**

- Временная несовместимость версий
- Медленное обновление

### Blue-Green (Production)

```bash
# Создание green environment
kubectl apply -k k8s/overlays/production --dry-run=client -o yaml | \
  sed 's/katya-production/katya-production-green/g' | \
  kubectl apply -f -

# Переключение трафика
kubectl patch ingress api-ingress -n katya-production -p '...'

# Удаление blue environment
kubectl delete namespace katya-production-blue
```

**Преимущества:**

- Мгновенное переключение
- Полная изоляция версий
- Быстрый rollback

**Недостатки:**

- Требует больше ресурсов
- Сложность реализации

### Canary Deployment

```yaml
# Canary deployment с 10% трафика
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: katya-api
spec:
  strategy:
    canary:
      steps:
        - setWeight: 10
        - pause: { duration: 10m }
        - setWeight: 50
        - pause: { duration: 10m }
        - setWeight: 100
```

## Безопасность

### Секреты

#### Создание секретов:

```bash
# Создание namespace для секретов
kubectl create namespace katya-secrets

# Создание секретов
kubectl create secret generic katya-secrets \
  --from-literal=database-url="postgresql://..." \
  --from-literal=jwt-secret="..." \
  --namespace=katya-production
```

#### Использование в манифестах:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: katya-secrets
        key: database-url
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: katya-network-policy
  namespace: katya
spec:
  podSelector:
    matchLabels:
      app: katya
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: katya
      ports:
        - protocol: TCP
          port: 3000
```

### RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: katya-api
rules:
  - apiGroups: [""]
    resources: ["secrets", "configmaps"]
    verbs: ["get", "list", "watch"]
```

## Backup и восстановление

### Автоматические бэкапы

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: katya-backup
spec:
  schedule: "0 2 * * *" # Каждый день в 2:00
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: katya/backup:latest
              env:
                - name: BACKUP_SCHEDULE
                  value: "0 2 * * *"
```

### Восстановление

```bash
# Восстановление базы данных
kubectl exec -it postgres-pod -- pg_restore -U katya -d katya /backups/latest.sql

# Восстановление конфигураций
kubectl apply -f backup/configs/

# Восстановление секретов
kubectl apply -f backup/secrets/
```

## Troubleshooting

### Частые проблемы

1. **Pod не запускается**

   ```bash
   kubectl describe pod <pod-name> -n katya
   kubectl logs <pod-name> -n katya
   ```

2. **Сервис недоступен**

   ```bash
   kubectl get svc -n katya
   kubectl get endpoints -n katya
   ```

3. **Проблемы с ресурсами**

   ```bash
   kubectl top pods -n katya
   kubectl describe node <node-name>
   ```

4. **Проблемы с сетью**
   ```bash
   kubectl get networkpolicies -n katya
   kubectl exec -it <pod-name> -- nslookup <service-name>
   ```

### Логирование

```bash
# Логи всех подов
kubectl logs -l app=katya-api -n katya

# Логи с follow
kubectl logs -f deployment/api -n katya

# Логи предыдущего контейнера
kubectl logs deployment/api --previous -n katya
```

### Мониторинг

```bash
# Проверка метрик
curl http://localhost:9090/api/v1/query?query=up

# Проверка алертов
kubectl get prometheusrules -n monitoring

# Проверка Grafana
open http://localhost:3002
```

## Best Practices

### Развертывание

1. **Версионирование** - Используйте семантическое версионирование
2. **Тестирование** - Всегда тестируйте в staging перед production
3. **Мониторинг** - Настройте алерты и дашборды
4. **Rollback** - Подготовьте план отката
5. **Документация** - Документируйте все изменения

### Безопасность

1. **Секреты** - Никогда не храните секреты в коде
2. **Обновления** - Регулярно обновляйте зависимости
3. **Сканирование** - Используйте инструменты сканирования уязвимостей
4. **Доступ** - Ограничьте доступ к production
5. **Аудит** - Ведите логи всех операций

### Производительность

1. **Ресурсы** - Настройте лимиты и requests
2. **Масштабирование** - Используйте HPA для автоматического масштабирования
3. **Кэширование** - Настройте кэширование на всех уровнях
4. **Мониторинг** - Отслеживайте метрики производительности
5. **Оптимизация** - Регулярно оптимизируйте образы и конфигурации

## Поддержка

### Контакты

- **Email**: devops@katya.wtf
- **Slack**: #devops
- **GitHub Issues**: https://github.com/katya/katya/issues

### Документация

- **Kubernetes**: https://kubernetes.io/docs/
- **Docker**: https://docs.docker.com/
- **Prometheus**: https://prometheus.io/docs/
- **Grafana**: https://grafana.com/docs/

### Обучение

- **Kubernetes Tutorial**: https://kubernetes.io/docs/tutorials/
- **Docker Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **CI/CD Patterns**: https://martinfowler.com/articles/continuousIntegration.html
