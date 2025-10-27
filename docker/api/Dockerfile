# Multi-stage build для API сервиса Katya
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

# Stage для разработки
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 3000
USER katya
CMD ["dumb-init", "node", "src/index.js"]

# Stage для production
FROM base AS production

# Копируем исходный код
COPY --chown=katya:nodejs . .

# Создаем директории для логов и загрузок
RUN mkdir -p /app/logs /app/uploads && \
    chown -R katya:nodejs /app/logs /app/uploads

# Открываем порты
EXPOSE 3000 9090

# Переключаемся на пользователя katya
USER katya

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Запускаем приложение
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/index.js"]
