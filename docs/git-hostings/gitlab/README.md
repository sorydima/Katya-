# GitLab Integration & Development Guide

## 🎯 Overview

**Platform**: GitLab (gitlab.com)  
**Organization**: [katya-messenger](https://gitlab.com/katya-messenger)  
**Primary Repository**: [katya](https://gitlab.com/katya-messenger/katya)  
**License**: Apache 2.0  
**CI/CD**: GitLab CI/CD  
**Container Registry**: GitLab Container Registry  

## 📁 Repository Structure

```
.gitlab/
├── ci/
│   ├── .gitlab-ci.yml          # Main CI pipeline
│   ├── release.yml             # Release automation
│   ├── security.yml            # Security scanning
│   ├── code-quality.yml        # Code quality
│   ├── performance.yml         # Performance testing
│   └── compliance.yml          # Compliance checks
├── merge_request_templates/
│   ├── default.md              # MR template
│   └── security.md             # Security MR template
├── issue_templates/
│   ├── bug.md                  # Bug report template
│   ├── feature.md              # Feature request template
│   └── security.md             # Security issue template
└── .gitlab-ci.yml              # Legacy CI configuration
```

## 🚀 GitLab CI/CD Pipelines

### Main CI Pipeline
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - test
  - build
  - deploy
  - release

variables:
  FLUTTER_VERSION: "3.16.0"
  DART_VERSION: "3.2.0"
  ANDROID_API_LEVEL: "33"
  IOS_DEPLOYMENT_TARGET: "14.0"

# Code validation
validate:code:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter analyze
    - flutter format --dry-run --set-exit-if-changed .
  only:
    - merge_requests
    - main

# Unit and integration tests
test:flutter:
  stage: test
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter test
    - flutter test --coverage
    - flutter test integration_test/
  coverage: '/^Lines\s+:\s+(\d+\.\d+%)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura.xml
    paths:
      - coverage/
    expire_in: 1 week
  only:
    - merge_requests
    - main

# Multi-platform builds
build:android:
  stage: build
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    paths:
      - build/app/outputs/apk/release/
      - build/app/outputs/bundle/release/
    expire_in: 1 week
  only:
    - main
    - tags

build:ios:
  stage: build
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/ios/ipa/
    expire_in: 1 week
  only:
    - main
    - tags
  tags:
    - macos

# Security scanning
security:sast:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter analyze --fatal-infos
  only:
    - merge_requests
    - main

security:dependency:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub outdated
    - flutter pub audit
  allow_failure: true
  only:
    - merge_requests
    - main
```

### Automated Release Pipeline
```yaml
# .gitlab/release.yml
stages:
  - build
  - test
  - release

release:android:
  stage: release
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    paths:
      - build/app/outputs/apk/release/
      - build/app/outputs/bundle/release/
  only:
    - tags
  when: manual

release:ios:
  stage: release
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/ios/ipa/
  only:
    - tags
  when: manual
  tags:
    - macos

# Create GitLab release
create-release:
  stage: release
  image: alpine:latest
  script:
    - apk add --no-cache curl
    - |
      curl --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
           --data "tag_name=$CI_COMMIT_TAG&description=$(cat CHANGELOG.md)" \
           "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/releases"
  only:
    - tags
```

## 🔧 Development Setup

### Prerequisites
- **GitLab Account** (personal, group, or self-hosted)
- **SSH Key** or **Personal Access Token**
- **GitLab Runner** (for self-hosted CI/CD)
- **Container Registry Access** (for Docker builds)

### Repository Configuration
```bash
# Clone repository
git clone git@gitlab.com:katya-messenger/katya.git
cd katya

# Configure git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add GitHub as upstream (for mirroring)
git remote add github https://github.com/katya-messenger/katya.git
```

### GitLab Runner Setup
```bash
# Register GitLab Runner
sudo gitlab-runner register \
  --non-interactive \
  --url https://gitlab.com \
  --registration-token $GITLAB_RUNNER_TOKEN \
  --executor docker \
  --docker-image cirrusci/flutter:latest \
  --description "Flutter Runner" \
  --tag-list flutter,android,ios \
  --docker-privileged \
  --docker-volumes /certs/client \
  --docker-volumes /cache

# Runner configuration
sudo gitlab-runner register \
  --non-interactive \
  --url https://gitlab.com \
  --registration-token $GITLAB_RUNNER_TOKEN \
  --executor docker \
  --docker-image cirrusci/flutter:latest \
  --description "macOS Flutter Runner" \
  --tag-list flutter,macos \
  --docker-privileged \
  --docker-volumes /Users/Shared/certificates:/certs/client:ro
```

## 📦 Package Management

### Flutter Packages
```bash
# Publish to pub.dev
flutter pub publish --dry-run
flutter pub publish

# Or publish to GitLab Package Registry
echo 'repository: https://gitlab.com/katya-messenger/katya' >> pubspec.yaml
```

### Container Registry
```yaml
# .gitlab-ci.yml
build:docker:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
```

## 🔐 Security & Compliance

### Security Scanning
```yaml
# .gitlab-ci.yml
security:sast:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter analyze --fatal-infos --fatal-warnings
  artifacts:
    reports:
      codequality: gl-code-quality-report.json
    paths:
      - gl-code-quality-report.json
  only:
    - merge_requests
    - main

security:dependency:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub outdated
    - flutter pub audit
  allow_failure: true
  artifacts:
    reports:
      dependency_scanning: gl-dependency-scanning-report.json
    paths:
      - gl-dependency-scanning-report.json
  only:
    - merge_requests
    - main

security:license:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter packages license
  artifacts:
    reports:
      license_scanning: gl-license-scanning-report.json
    paths:
      - gl-license-scanning-report.json
  only:
    - merge_requests
    - main
```

### Code Quality
```yaml
# .gitlab-ci.yml
quality:code:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter format --dry-run --set-exit-if-changed .
    - flutter analyze --fatal-infos
  artifacts:
    reports:
      codequality: gl-code-quality-report.json
    paths:
      - gl-code-quality-report.json
  only:
    - merge_requests
    - main
```

## 🤝 Collaboration

### Merge Request Templates
```markdown
<!-- .gitlab/merge_request_templates/default.md -->
## Description
Describe the changes made and why they were necessary.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Security improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] Security testing completed

## Security Considerations
- [ ] No security implications
- [ ] Security review required
- [ ] Security testing completed

## Performance Impact
- [ ] No performance impact
- [ ] Performance improvement
- [ ] Performance regression possible

## Checklist
- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] Tests pass
- [ ] Security review completed (if required)
- [ ] Performance tested (if applicable)
```

### Issue Templates
```markdown
<!-- .gitlab/issue_templates/bug.md -->
## Bug Description
Describe the bug and expected behavior.

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Environment
- **Platform**: [iOS/Android/Web/Desktop]
- **Version**: [App version]
- **Device**: [Device model]
- **OS Version**: [OS version]

## Additional Context
- Screenshots
- Error logs
- Network conditions
```

## 📊 Analytics & Monitoring

### GitLab Analytics
- **Value Stream Analytics**: Track development cycle
- **Code Review Analytics**: Review efficiency metrics
- **CI/CD Analytics**: Pipeline performance
- **Security Dashboard**: Vulnerability tracking
- **Compliance Dashboard**: Regulatory compliance

### Performance Monitoring
```yaml
# .gitlab-ci.yml
performance:test:
  stage: test
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter test --tags performance
  artifacts:
    reports:
      junit: test-results/junit.xml
    paths:
      - test-results/
    expire_in: 1 week
  only:
    - main
    - merge_requests
```

## 🚀 Deployment Automation

### Multi-Platform Deployment
```yaml
# .gitlab-ci.yml
deploy:web:
  stage: deploy
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build web --release
    - |
      curl -T build/web \
           -u "$WEB_DEPLOY_USER:$WEB_DEPLOY_PASSWORD" \
           ftp://ftp.katya.im/public_html/
  environment:
    name: production
    url: https://katya.im
  only:
    - main

deploy:android:
  stage: deploy
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build apk --release
    - flutter build appbundle --release
    - |
      curl -X POST \
           -H "Authorization: Bearer $GOOGLE_PLAY_API_TOKEN" \
           -F "package=@build/app/outputs/bundle/release/app-release.aab" \
           https://www.googleapis.com/upload/android/publisher/v3/applications/com.katya.app/edits
  environment:
    name: production
    url: https://play.google.com/store/apps/details?id=com.katya.app
  only:
    - tags
```

## 🌐 Internationalization

### Translation Management
```yaml
# .gitlab-ci.yml
i18n:extract:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub global activate intl_utils
    - flutter pub global run intl_utils:generate
    - flutter pub global run intl_utils:extract
  artifacts:
    paths:
      - lib/l10n/
    expire_in: 1 week
  only:
    - merge_requests
    - main

i18n:validate:
  stage: validate
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter test --tags i18n
  only:
    - merge_requests
    - main
```

## 📚 Documentation

### Automated Documentation
```yaml
# .gitlab-ci.yml
docs:generate:
  stage: deploy
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter doc
    - |
      curl -T doc/api \
           -u "$DOCS_DEPLOY_USER:$DOCS_DEPLOY_PASSWORD" \
           ftp://ftp.katya.im/docs/
  artifacts:
    paths:
      - doc/
    expire_in: 1 month
  only:
    - main
  when: manual
```

## 🔄 Integration with Other Platforms

### GitLab to GitHub Mirror
```bash
# Mirror to GitHub
git remote add github https://github.com/katya-messenger/katya.git

# Push to both platforms
git push origin main
git push github main
```

### GitLab to SourceForge Mirror
```bash
# Mirror to SourceForge
git remote add sourceforge ssh://USERNAME@git.code.sf.net/p/katya-messenger/code
git push sourceforge main
```

## 📈 Advanced Features

### GitLab Pages
```yaml
# .gitlab-ci.yml
pages:
  stage: deploy
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter build web --release
    - mv build/web public
  artifacts:
    paths:
      - public
    expire_in: 1 hour
  only:
    - main
```

### Auto DevOps
```yaml
# .gitlab-ci.yml
include:
  - template: Auto-DevOps.gitlab-ci.yml

variables:
  AUTO_DEVOPS_PLATFORM_TARGET: FLUTTER
  FLUTTER_VERSION: "3.16.0"
```

## 🔍 Troubleshooting

### Common Issues
- **Runner Issues**: Check runner registration and tags
- **Authentication**: Verify access tokens and SSH keys
- **Build Failures**: Check Docker image compatibility
- **Security Policies**: Review compliance requirements

### Debug Commands
```bash
# Check pipeline status
gitlab-runner verify

# Check runner registration
gitlab-runner list

# Check job logs
gitlab job log --job-id <job_id>

# Check artifacts
gitlab job artifacts --job-id <job_id>
```

## 📞 Support & Community

- **Issues**: [GitLab Issues](https://gitlab.com/katya-messenger/katya/-/issues)
- **Merge Requests**: [GitLab MRs](https://gitlab.com/katya-messenger/katya/-/merge_requests)
- **Wiki**: [GitLab Wiki](https://gitlab.com/katya-messenger/katya/-/wikis/home)
- **Community**: [Discord](https://discord.gg/katya)

## 📋 Best Practices

### Commit Guidelines
- **Format**: `type(scope): description`
- **Types**: feat, fix, docs, style, refactor, test, chore, ci, build
- **Scope**: component or area affected
- **Description**: Clear, concise explanation

### Branch Naming
- **Features**: `feature/feature-name`
- **Bug Fixes**: `fix/issue-description`
- **Documentation**: `docs/section-update`
- **Hotfixes**: `hotfix/critical-issue`
- **Releases**: `release/v1.0.0`

### Pipeline Optimization
- **Parallel Jobs**: Use dependencies efficiently
- **Artifact Strategy**: Minimize storage usage
- **Caching**: Cache dependencies and build artifacts
- **Environment Variables**: Use protected variables for secrets

---

**Last Updated**: December 2024
**GitLab Version**: 16.7.0
**Status**: Fully Integrated
