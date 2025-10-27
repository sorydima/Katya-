# GitFlic Integration & Development Guide

## 🎯 Overview

**Platform**: GitFlic (gitflic.ru)  
**Type**: Domestic Russian Git Hosting  
**Organization**: [katya-messenger](https://gitflic.ru/katya-messenger)  
**Primary Repository**: [katya](https://gitflic.ru/katya-messenger/katya)  
**License**: Apache 2.0  
**CI/CD**: GitFlic CI/CD  
**Language Support**: Russian, English  

## 📁 Repository Structure

```
.gitflic/
├── ci/
│   ├── .gitflic-ci.yml         # Main CI pipeline
│   ├── release.yml            # Release automation
│   ├── security.yml           # Security scanning
│   └── compliance.yml         # Compliance checks
├── templates/
│   ├── pull_request.md       # PR template
│   └── issue.md              # Issue template
├── docs/
│   ├── setup.md              # Setup guide
│   └── api.md                # API documentation
└── badges/
    ├── build.svg             # Build status
    └── license.svg           # License badge
```

## 🚀 CI/CD Configuration

### Main Pipeline
```yaml
# .gitflic-ci.yml
version: 1.0

stages:
  - validate
  - test
  - build
  - security
  - deploy

environment:
  flutter_version: "3.16.0"
  dart_version: "3.2.0"

jobs:

# Валидация кода
validate_code:
  stage: validate
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter analyze --fatal-infos --fatal-warnings
    - flutter format --dry-run --set-exit-if-changed .
  only:
    - merge_requests
    - main

# Тестирование
test_flutter:
  stage: test
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter test --coverage
    - flutter test integration_test/
  coverage:
    format: cobertura
    path: coverage/cobertura.xml
  artifacts:
    - coverage/
  only:
    - merge_requests
    - main

# Сборка для Android
build_android:
  stage: build
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    - build/app/outputs/apk/release/
    - build/app/outputs/bundle/release/
  only:
    - main
    - tags

# Сборка для iOS
build_ios:
  stage: build
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter build ios --release --no-codesign
  artifacts:
    - build/ios/ipa/
  only:
    - main
    - tags

# Сборка для Web
build_web:
  stage: build
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter build web --release
  artifacts:
    - build/web/
  only:
    - main

# Сборка для Desktop
build_desktop:
  stage: build
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter build linux --release
    - flutter build windows --release
    - flutter build macos --release
  artifacts:
    - build/linux/
    - build/windows/
    - build/macos/
  only:
    - main
    - tags

# Проверка безопасности
security_scan:
  stage: security
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter pub audit
    - flutter analyze --fatal-warnings
  artifacts:
    - security-report.json
  allow_failure: true
  only:
    - merge_requests
    - main
```

### Release Pipeline
```yaml
# .gitflic-ci.yml
release_automation:
  stage: deploy
  image: alpine:latest
  commands:
    - apk add --no-cache curl
    - |
      curl -X POST \
           -H "Authorization: Bearer $GITFLIC_TOKEN" \
           -H "Content-Type: application/json" \
           -d '{
             "tagName": "'"$CI_COMMIT_TAG"'",
             "description": "'$(cat CHANGELOG.md)'",
             "releaseNotes": "Автоматический релиз '"$CI_COMMIT_TAG"'"
           }' \
           "https://gitflic.ru/api/v1/repos/katya-messenger/katya/releases"
  only:
    - tags
  when: manual
```

## 🔧 Development Setup

### Prerequisites
- **GitFlic Account** (gitflic.ru)
- **SSH Key** for authentication
- **API Token** for CI/CD
- **Git LFS** (for large files)

### Repository Configuration
```bash
# Клонирование репозитория
git clone git@gitflic.ru:katya-messenger/katya.git
cd katya

# Настройка Git
git config user.name "Ваше Имя"
git config user.email "your.email@example.com"

# Добавление зеркал
git remote add github https://github.com/katya-messenger/katya.git
git remote add gitlab https://gitlab.com/katya-messenger/katya.git
git remote add sourcecraft https://sourcecraft.org/katya-messenger/katya.git
```

### Branch Strategy
- **main**: Основная ветка разработки
- **develop**: Ветка интеграции
- **feature/***: Ветки разработки функций
- **bugfix/***: Ветки исправления ошибок
- **hotfix/***: Ветки критических исправлений
- **release/***: Ветки подготовки релизов

## 📦 Package Management

### Flutter Packages
```bash
# Публикация в pub.dev
flutter pub publish --dry-run
flutter pub publish

# Публикация в GitFlic Registry
echo 'repository: https://gitflic.ru/katya-messenger/katya' >> pubspec.yaml
```

### Container Registry
```yaml
# .gitflic-ci.yml
build_docker:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  commands:
    - docker login gitflic.ru -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD
    - docker build -t gitflic.ru/katya-messenger/katya:$CI_COMMIT_SHA .
    - docker push gitflic.ru/katya-messenger/katya:$CI_COMMIT_SHA
  only:
    - main
```

## 🔐 Security & Compliance

### Russian Compliance Requirements
- **ФЗ-152**: Protection of personal data
- **ФЗ-187**: Information security requirements
- **ГОСТ Р 57580**: Cryptographic protection standards
- **ФСТЭК**: Security certification compliance

### Security Scanning
```yaml
# .gitflic-ci.yml
security_compliance:
  stage: security
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter analyze --fatal-infos --fatal-warnings
    - # Проверка на соответствие ФЗ-152
    - # Проверка на соответствие ФЗ-187
    - # Проверка на соответствие ГОСТ Р 57580
  artifacts:
    - compliance-report.json
  allow_failure: false
  only:
    - merge_requests
    - main
```

## 🤝 Collaboration

### Pull Request Template
```markdown
<!-- .gitflic/templates/pull_request.md -->
## Описание изменений
Опишите внесенные изменения и причины их необходимости.

## Тип изменения
- [ ] Исправление ошибки (bug fix)
- [ ] Новая функция (new feature)
- [ ] Критическое изменение (breaking change)
- [ ] Обновление документации (documentation update)
- [ ] Улучшение безопасности (security improvement)
- [ ] Улучшение производительности (performance improvement)

## Тестирование
- [ ] Добавлены/обновлены unit тесты
- [ ] Добавлены/обновлены интеграционные тесты
- [ ] Проведено ручное тестирование
- [ ] Проведено тестирование безопасности
- [ ] Проведено тестирование производительности

## Безопасность
- [ ] Нет влияния на безопасность
- [ ] Требуется проверка безопасности
- [ ] Проверка безопасности завершена
- [ ] Соответствует ФЗ-152 (защита персональных данных)
- [ ] Соответствует ФЗ-187 (требования информационной безопасности)

## Соответствие стандартам
- [ ] Соответствует ГОСТ Р 57580 (криптографическая защита)
- [ ] Соответствует ФСТЭК требованиям
- [ ] Пройдена сертификация безопасности

## Контрольный список
- [ ] Код соответствует стилю проекта
- [ ] Обновлена документация
- [ ] Все тесты проходят
- [ ] Проверка безопасности выполнена
- [ ] Соответствие российским стандартам проверено
- [ ] Performance testing completed (if applicable)
```

## 📊 Analytics & Monitoring

### GitFlic Analytics
- **Repository Analytics**: Просмотры, клоны, звезды
- **Code Analytics**: Статистика кода и коммитов
- **CI/CD Analytics**: Производительность пайплайнов
- **Security Analytics**: Отслеживание уязвимостей
- **Compliance Analytics**: Соответствие регуляциям

## 🚀 Deployment Automation

### Multi-Platform Deployment
```yaml
# .gitflic-ci.yml
deploy_rustore:
  stage: deploy
  image: curlimages/curl:latest
  commands:
    - |
      curl -X POST \
           -H "Authorization: Bearer $RUSTORE_TOKEN" \
           -F "file=@build/app/outputs/bundle/release/app-release.aab" \
           -F "version=$CI_COMMIT_TAG" \
           https://public-api.rustore.ru/public/v1/application/upload
  environment:
    name: rustore
    url: https://apps.rustore.ru/app/com.katya.messenger
  only:
    - tags

deploy_vk:
  stage: deploy
  image: curlimages/curl:latest
  commands:
    - |
      curl -X POST \
           -H "Authorization: Bearer $VK_TOKEN" \
           -F "package=@build/app/outputs/bundle/release/app-release.aab" \
           https://api.vk.com/method/apps.uploadPackage
  environment:
    name: vk
    url: https://vk.com/app/katya_messenger
  only:
    - tags
```

## 🌐 Localization & Internationalization

### Russian Language Support
```yaml
# .gitflic-ci.yml
i18n_russian:
  stage: validate
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter pub global activate intl_utils
    - flutter pub global run intl_utils:generate
    - flutter test --tags i18n-russian
  artifacts:
    - lib/l10n/ru/
  only:
    - merge_requests
    - main
```

## 📚 Documentation

### Russian Documentation
```yaml
# .gitflic-ci.yml
docs_russian:
  stage: deploy
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - flutter doc --json
    - mkdir -p docs/ru
    - cp -r doc/api/* docs/ru/
  artifacts:
    - docs/ru/
  only:
    - main
```

## 🔄 Integration with Russian Platforms

### GitFlic to GitHub Mirror
```bash
# Синхронизация с GitHub
git remote add github https://github.com/katya-messenger/katya.git

# Пуш в оба репозитория
git push origin main
git push github main
```

### GitFlic to GitLab Mirror
```bash
# Синхронизация с GitLab
git remote add gitlab https://gitlab.com/katya-messenger/katya.git
git push gitlab main
```

## 📈 Advanced Features

### Russian App Stores Integration
- **RuStore Integration**: Automated publishing
- **VK Apps Integration**: Platform deployment
- **Yandex Market**: App distribution
- **Mail.ru Cloud**: Storage integration

### Local Development Tools
```yaml
# .gitflic-ci.yml
dev_integration:
  stage: validate
  image: cirrusci/flutter:latest
  commands:
    - flutter pub get
    - # Интеграция с 1C:Enterprise
    - # Интеграция с Контур.Диадок
    - # Интеграция с Госуслуги API
    - # Проверка совместимости с ЕГАИС
  only:
    - develop
```

## 🔍 Troubleshooting

### Common Issues
- **Runner Issues**: Проверьте конфигурацию раннера
- **Authentication**: Проверьте API токены
- **Compliance Failures**: Убедитесь в соответствии стандартам
- **Build Issues**: Проверьте версии Flutter/Dart

### Debug Commands
```bash
# Проверка статуса CI/CD
gitflic-ci status

# Просмотр логов задач
gitflic-ci logs <job_id>

# Проверка артефактов
gitflic-ci artifacts <job_id>

# Проверка compliance
gitflic-ci compliance-check
```

## 📞 Support & Community

- **Issues**: [GitFlic Issues](https://gitflic.ru/katya-messenger/katya/issues)
- **Pull Requests**: [GitFlic PRs](https://gitflic.ru/katya-messenger/katya/pulls)
- **Wiki**: [GitFlic Wiki](https://gitflic.ru/katya-messenger/katya/wiki)
- **Community**: [VK Group](https://vk.com/katya_messenger)
- **Support**: support@gitflic.ru

## 📋 Best Practices

### Russian Development Standards
- **ГОСТ 19**: Standards for program documentation
- **ГОСТ 34**: Standards for automated systems
- **ISO 12207**: Software life cycle processes
- **ГОСТ Р ИСО/МЭК 25000**: Software product quality requirements

### Commit Guidelines
```bash
# Russian commit format
feat(область): описание изменения
fix(область): исправление ошибки
docs(документация): обновление документации
style(стиль): изменения стиля кода
refactor(рефакторинг): рефакторинг кода
test(тесты): добавление тестов
chore(техническое): технические изменения
```

### Branch Naming
- **Features**: `feature/название-функции`
- **Bug Fixes**: `fix/описание-ошибки`
- **Documentation**: `docs/обновление-раздела`
- **Hotfixes**: `hotfix/критическая-ошибка`
- **Releases**: `release/v1.0.0`

---

**Last Updated**: December 2024
**GitFlic Version**: 1.5.0
**Compliance Status**: ФЗ-152, ФЗ-187, ГОСТ Р 57580
**Status**: Fully Integrated
