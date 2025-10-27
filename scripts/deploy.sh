#!/bin/bash

# Katya Deployment Script
# Автоматизация развертывания системы Katya в различных окружениях

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Функция для проверки зависимостей
check_dependencies() {
    log "Проверка зависимостей..."
    
    local deps=("docker" "kubectl" "helm" "jq" "yq")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Отсутствуют следующие зависимости: ${missing_deps[*]}"
        error "Установите их перед продолжением"
        exit 1
    fi
    
    success "Все зависимости установлены"
}

# Функция для проверки подключения к кластеру
check_kubectl_connection() {
    log "Проверка подключения к Kubernetes кластеру..."
    
    if ! kubectl cluster-info &> /dev/null; then
        error "Не удается подключиться к Kubernetes кластеру"
        error "Проверьте настройки kubectl и доступность кластера"
        exit 1
    fi
    
    local context=$(kubectl config current-context)
    log "Подключен к кластеру: $context"
    success "Подключение к кластеру установлено"
}

# Функция для создания namespace
create_namespace() {
    local namespace=$1
    log "Создание namespace: $namespace"
    
    if kubectl get namespace "$namespace" &> /dev/null; then
        warning "Namespace $namespace уже существует"
    else
        kubectl create namespace "$namespace"
        success "Namespace $namespace создан"
    fi
}

# Функция для применения секретов
apply_secrets() {
    local environment=$1
    local namespace=$2
    
    log "Применение секретов для окружения: $environment"
    
    if [ ! -f "secrets/$environment/secrets.yaml" ]; then
        error "Файл секретов не найден: secrets/$environment/secrets.yaml"
        exit 1
    fi
    
    kubectl apply -f "secrets/$environment/secrets.yaml" -n "$namespace"
    success "Секреты применены"
}

# Функция для применения конфигураций
apply_configs() {
    local environment=$1
    local namespace=$2
    
    log "Применение конфигураций для окружения: $environment"
    
    if [ ! -f "configs/$environment/config.yaml" ]; then
        error "Файл конфигурации не найден: configs/$environment/config.yaml"
        exit 1
    fi
    
    kubectl apply -f "configs/$environment/config.yaml" -n "$namespace"
    success "Конфигурации применены"
}

# Функция для сборки Docker образов
build_images() {
    local environment=$1
    local version=$2
    
    log "Сборка Docker образов для окружения: $environment"
    
    local services=("api" "web" "analytics" "websocket" "celery" "backup")
    
    for service in "${services[@]}"; do
        log "Сборка образа: $service"
        
        if [ ! -f "docker/$service/Dockerfile" ]; then
            warning "Dockerfile не найден для сервиса: $service"
            continue
        fi
        
        docker build -t "katya/$service:$version" -f "docker/$service/Dockerfile" .
        docker tag "katya/$service:$version" "katya/$service:$environment-latest"
        
        success "Образ $service собран"
    done
    
    success "Все образы собраны"
}

# Функция для отправки образов в registry
push_images() {
    local environment=$1
    local version=$2
    local registry=${3:-"ghcr.io/katya"}
    
    log "Отправка образов в registry: $registry"
    
    local services=("api" "web" "analytics" "websocket" "celery" "backup")
    
    for service in "${services[@]}"; do
        log "Отправка образа: $service"
        
        docker tag "katya/$service:$version" "$registry/$service:$version"
        docker tag "katya/$service:$environment-latest" "$registry/$service:$environment-latest"
        
        docker push "$registry/$service:$version"
        docker push "$registry/$service:$environment-latest"
        
        success "Образ $service отправлен"
    done
    
    success "Все образы отправлены"
}

# Функция для применения Kubernetes манифестов
apply_k8s_manifests() {
    local environment=$1
    local namespace=$2
    
    log "Применение Kubernetes манифестов для окружения: $environment"
    
    if [ ! -d "k8s/overlays/$environment" ]; then
        error "Директория манифестов не найдена: k8s/overlays/$environment"
        exit 1
    fi
    
    # Применяем с помощью kustomize
    kubectl apply -k "k8s/overlays/$environment"
    
    success "Kubernetes манифесты применены"
}

# Функция для ожидания готовности deployment
wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    local timeout=${3:-300}
    
    log "Ожидание готовности deployment: $deployment"
    
    if kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout="${timeout}s"; then
        success "Deployment $deployment готов"
    else
        error "Deployment $deployment не готов в течение $timeout секунд"
        return 1
    fi
}

# Функция для проверки здоровья сервисов
check_health() {
    local environment=$1
    local namespace=$2
    
    log "Проверка здоровья сервисов..."
    
    local services=("api" "web" "analytics" "websocket")
    
    for service in "${services[@]}"; do
        log "Проверка здоровья: $service"
        
        # Получаем URL сервиса
        local url=""
        if [ "$environment" = "production" ]; then
            url="https://$service.katya.wtf/health"
        elif [ "$environment" = "staging" ]; then
            url="https://staging-$service.katya.wtf/health"
        else
            url="http://localhost:3000/health"  # Для локального окружения
        fi
        
        # Проверяем здоровье
        local max_attempts=30
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if curl -f -s "$url" > /dev/null 2>&1; then
                success "Сервис $service здоров"
                break
            fi
            
            if [ $attempt -eq $max_attempts ]; then
                error "Сервис $service не отвечает после $max_attempts попыток"
                return 1
            fi
            
            log "Попытка $attempt/$max_attempts: ожидание готовности $service..."
            sleep 10
            ((attempt++))
        done
    done
    
    success "Все сервисы здоровы"
}

# Функция для запуска тестов
run_tests() {
    local environment=$1
    
    log "Запуск тестов для окружения: $environment"
    
    local base_url=""
    if [ "$environment" = "production" ]; then
        base_url="https://api.katya.wtf"
    elif [ "$environment" = "staging" ]; then
        base_url="https://staging-api.katya.wtf"
    else
        base_url="http://localhost:3000"
    fi
    
    # Запускаем smoke тесты
    log "Запуск smoke тестов..."
    if npm run test:smoke -- --base-url="$base_url"; then
        success "Smoke тесты пройдены"
    else
        error "Smoke тесты не пройдены"
        return 1
    fi
    
    # Запускаем интеграционные тесты (только для staging)
    if [ "$environment" = "staging" ]; then
        log "Запуск интеграционных тестов..."
        if npm run test:integration -- --base-url="$base_url"; then
            success "Интеграционные тесты пройдены"
        else
            error "Интеграционные тесты не пройдены"
            return 1
        fi
    fi
    
    success "Все тесты пройдены"
}

# Функция для отката deployment
rollback() {
    local namespace=$1
    local deployment=$2
    
    log "Откат deployment: $deployment"
    
    if kubectl rollout undo "deployment/$deployment" -n "$namespace"; then
        success "Deployment $deployment откачен"
        
        # Ждем готовности откаченного deployment
        wait_for_deployment "$namespace" "$deployment"
    else
        error "Не удалось откатить deployment $deployment"
        return 1
    fi
}

# Функция для очистки ресурсов
cleanup() {
    local environment=$1
    local namespace=$2
    
    log "Очистка ресурсов для окружения: $environment"
    
    # Удаляем старые replicasets
    kubectl delete replicaset --field-selector=status.replicas=0 -n "$namespace" --ignore-not-found=true
    
    # Удаляем старые образы
    docker image prune -f
    
    success "Очистка завершена"
}

# Функция для отправки уведомлений
send_notification() {
    local environment=$1
    local status=$2
    local message=$3
    
    log "Отправка уведомления..."
    
    local color=""
    case $status in
        "success") color="good" ;;
        "warning") color="warning" ;;
        "error") color="danger" ;;
        *) color="good" ;;
    esac
    
    # Отправляем в Slack
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        curl -X POST "$SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"title\": \"Katya Deployment - $environment\",
                    \"text\": \"$message\",
                    \"fields\": [
                        {\"title\": \"Environment\", \"value\": \"$environment\", \"short\": true},
                        {\"title\": \"Status\", \"value\": \"$status\", \"short\": true},
                        {\"title\": \"Timestamp\", \"value\": \"$(date)\", \"short\": false}
                    ],
                    \"footer\": \"Katya CI/CD\"
                }]
            }" || warning "Не удалось отправить уведомление в Slack"
    fi
    
    success "Уведомление отправлено"
}

# Основная функция развертывания
deploy() {
    local environment=$1
    local version=$2
    local registry=${3:-"ghcr.io/katya"}
    local namespace="katya-$environment"
    
    log "Начало развертывания Katya в окружении: $environment"
    log "Версия: $version"
    log "Registry: $registry"
    log "Namespace: $namespace"
    
    # Проверяем зависимости
    check_dependencies
    check_kubectl_connection
    
    # Создаем namespace
    create_namespace "$namespace"
    
    # Применяем секреты и конфигурации
    apply_secrets "$environment" "$namespace"
    apply_configs "$environment" "$namespace"
    
    # Собираем и отправляем образы
    build_images "$environment" "$version"
    push_images "$environment" "$version" "$registry"
    
    # Применяем Kubernetes манифесты
    apply_k8s_manifests "$environment" "$namespace"
    
    # Ждем готовности основных сервисов
    local deployments=("api" "web" "analytics" "websocket")
    for deployment in "${deployments[@]}"; do
        wait_for_deployment "$namespace" "$deployment"
    done
    
    # Проверяем здоровье сервисов
    if ! check_health "$environment" "$namespace"; then
        error "Проверка здоровья не пройдена"
        send_notification "$environment" "error" "Deployment завершился с ошибкой: проверка здоровья не пройдена"
        exit 1
    fi
    
    # Запускаем тесты
    if ! run_tests "$environment"; then
        error "Тесты не пройдены"
        send_notification "$environment" "error" "Deployment завершился с ошибкой: тесты не пройдены"
        exit 1
    fi
    
    # Очищаем ресурсы
    cleanup "$environment" "$namespace"
    
    success "Развертывание Katya в окружении $environment завершено успешно"
    send_notification "$environment" "success" "Deployment завершен успешно. Версия: $version"
}

# Функция для отката
rollback_deployment() {
    local environment=$1
    local namespace="katya-$environment"
    
    log "Начало отката развертывания в окружении: $environment"
    
    check_kubectl_connection
    
    local deployments=("api" "web" "analytics" "websocket")
    for deployment in "${deployments[@]}"; do
        rollback "$namespace" "$deployment"
    done
    
    # Проверяем здоровье после отката
    if check_health "$environment" "$namespace"; then
        success "Откат завершен успешно"
        send_notification "$environment" "success" "Откат развертывания завершен успешно"
    else
        error "Откат завершился с ошибкой"
        send_notification "$environment" "error" "Откат развертывания завершился с ошибкой"
        exit 1
    fi
}

# Функция для отображения справки
show_help() {
    cat << EOF
Katya Deployment Script

Использование:
    $0 <command> [options]

Команды:
    deploy <environment> <version> [registry]    Развертывание в указанном окружении
    rollback <environment>                       Откат развертывания
    health <environment>                         Проверка здоровья сервисов
    test <environment>                           Запуск тестов
    help                                         Показать эту справку

Окружения:
    development                                  Локальное окружение разработки
    staging                                      Тестовое окружение
    production                                   Продуктивное окружение

Примеры:
    $0 deploy staging v1.2.3                    Развертывание версии v1.2.3 в staging
    $0 deploy production v1.2.3 ghcr.io/katya   Развертывание в production с custom registry
    $0 rollback staging                          Откат staging окружения
    $0 health production                         Проверка здоровья production
    $0 test staging                              Запуск тестов в staging

Переменные окружения:
    SLACK_WEBHOOK_URL                           URL для отправки уведомлений в Slack
    POSTGRES_PASSWORD                           Пароль для PostgreSQL
    REDIS_PASSWORD                              Пароль для Redis
    JWT_SECRET                                  Секрет для JWT токенов
    API_KEY_SECRET                              Секрет для API ключей

EOF
}

# Главная функция
main() {
    local command=${1:-help}
    
    case $command in
        "deploy")
            if [ $# -lt 3 ]; then
                error "Недостаточно аргументов для команды deploy"
                show_help
                exit 1
            fi
            deploy "$2" "$3" "${4:-}"
            ;;
        "rollback")
            if [ $# -lt 2 ]; then
                error "Недостаточно аргументов для команды rollback"
                show_help
                exit 1
            fi
            rollback_deployment "$2"
            ;;
        "health")
            if [ $# -lt 2 ]; then
                error "Недостаточно аргументов для команды health"
                show_help
                exit 1
            fi
            check_health "$2" "katya-$2"
            ;;
        "test")
            if [ $# -lt 2 ]; then
                error "Недостаточно аргументов для команды test"
                show_help
                exit 1
            fi
            run_tests "$2"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            error "Неизвестная команда: $command"
            show_help
            exit 1
            ;;
    esac
}

# Запуск скрипта
main "$@"