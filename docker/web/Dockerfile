# Multi-stage build для Web фронтенда Katya
FROM node:18-alpine AS base

# Устанавливаем системные зависимости
RUN apk add --no-cache \
    curl \
    dumb-init \
    && addgroup -g 1001 -S nodejs \
    && adduser -S katya -u 1001

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm ci --only=production && npm cache clean --force

# Stage для сборки
FROM base AS builder

# Устанавливаем все зависимости (включая dev)
RUN npm ci

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# Stage для production
FROM nginx:alpine AS production

# Устанавливаем curl для health check
RUN apk add --no-cache curl

# Копируем собранное приложение
COPY --from=builder /app/dist /usr/share/nginx/html

# Копируем конфигурацию nginx
COPY docker/web/nginx.conf /etc/nginx/nginx.conf

# Создаем пользователя katya
RUN addgroup -g 1001 -S katya && \
    adduser -S katya -u 1001

# Устанавливаем права доступа
RUN chown -R katya:katya /usr/share/nginx/html && \
    chown -R katya:katya /var/cache/nginx && \
    chown -R katya:katya /var/log/nginx && \
    chown -R katya:katya /etc/nginx/conf.d

# Переключаемся на пользователя katya
USER katya

# Открываем порт
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
