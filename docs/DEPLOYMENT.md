# 🚀 Katya Deployment Guide

This document provides comprehensive instructions for deploying Katya across different platforms and environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development Setup](#local-development-setup)
- [Platform-Specific Deployment](#platform-specific-deployment)
- [Container Deployment](#container-deployment)
- [Cloud Deployment](#cloud-deployment)
- [CI/CD Integration](#cicd-integration)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

#### Development Environment
- **Flutter SDK**: 3.10.0 or later
- **Dart SDK**: 3.0.0 or later
- **Android Studio**: Latest stable version
- **Xcode**: 14.0+ (for iOS/macOS development)
- **Visual Studio**: Latest version (for Windows development)

#### Build Tools
- **CMake**: 3.10+ (for OLM compilation)
- **Ninja**: Build system
- **Git LFS**: Large file storage
- **Ruby**: For fastlane (iOS deployment)

#### Platform SDKs
- **Android SDK**: API level 21+
- **iOS SDK**: 14.0+
- **macOS SDK**: 12.0+
- **Windows SDK**: 10.0.19041+

### Network Requirements

#### Matrix Homeserver
- **Synapse**: 1.70+ recommended
- **Dendrite**: 0.11+ supported
- **Conduit**: Latest stable version

#### External Services
- **Push Notification Services**:
  - Firebase Cloud Messaging (Android)
  - Apple Push Notification Service (iOS)
- **CDN**: For asset delivery
- **Monitoring**: Prometheus/Grafana stack

## Local Development Setup

### 1. Repository Setup

```bash
# Clone the repository
git clone https://github.com/your-org/katya.git
cd katya

# Initialize submodules
git submodule update --init --recursive

# Install Flutter dependencies
flutter pub get

# Generate code
flutter pub run build_runner build
```

### 2. Environment Configuration

Create environment files:

```bash
# .env file for local development
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Matrix Configuration
MATRIX_HOMESERVER_URL=https://matrix.org
MATRIX_HOMESERVER_NAME=matrix.org

# App Configuration
APP_NAME=Katya
APP_VERSION=1.0.0
APP_BUILD_NUMBER=1

# API Keys
FIREBASE_API_KEY=your_firebase_key
SENTRY_DSN=your_sentry_dsn

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=true
ENABLE_PUSH_NOTIFICATIONS=true
```

### 3. Platform-Specific Setup

#### Android Setup
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Configure signing
# Place keystore in android/app/
# Update android/key.properties
```

#### iOS Setup
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install iOS dependencies
cd ios
pod install
cd ..
```

#### Desktop Setup
```bash
# Enable desktop platforms
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

### 4. Running the Application

```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d linux
flutter run -d macos
flutter run -d windows

# Run in profile mode
flutter run --profile

# Run tests
flutter test

# Build release
flutter build apk
flutter build ios
flutter build linux
flutter build macos
flutter build windows
```

## Platform-Specific Deployment

### Android Deployment

#### Google Play Store

1. **Build Release APK/AAB**
```bash
# Build APK
flutter build apk --release

# Build AAB (recommended)
flutter build appbundle --release
```

2. **Configure Play Store**
- Create Google Play Console account
- Create new application
- Configure store listing
- Set up internal/external testing tracks

3. **Signing Configuration**
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file('path/to/keystore.jks')
            storePassword 'store_password'
            keyAlias 'key_alias'
            keyPassword 'key_password'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Fastlane Setup**
```ruby
# fastlane/Fastfile
lane :deploy_play_store do
  upload_to_play_store(
    track: 'internal',
    aab: '../build/app/outputs/bundle/release/app-release.aab'
  )
end
```

#### F-Droid

1. **Build for F-Droid**
```bash
# Build unsigned APK
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
```

2. **F-Droid Metadata**
```yaml
# Create F-Droid metadata
mkdir -p metadata/com.katya.wtf
```

### iOS Deployment

#### App Store

1. **Build for iOS**
```bash
# Build for iOS
flutter build ios --release
```

2. **Code Signing**
```bash
# Install certificates
# Configure provisioning profiles
# Update Xcode project settings
```

3. **TestFlight Deployment**
```ruby
# fastlane/Fastfile
lane :beta do
  build_app(
    scheme: "Runner",
    export_method: "app-store"
  )

  upload_to_testflight
end
```

#### App Store Submission
```ruby
lane :release do
  build_app(
    scheme: "Runner",
    export_method: "app-store"
  )

  deliver(
    submit_for_review: true,
    automatic_release: false
  )
end
```

### Desktop Deployment

#### Linux (Snap/Flatpak)

1. **Snap Package**
```yaml
# snap/snapcraft.yaml
name: katya
version: '1.0.0'
summary: Decentralized messaging app
description: |
  Katya is a decentralized messaging application

grade: stable
confinement: strict

apps:
  katya:
    command: katya
    extensions: [flutter-master]

parts:
  flutter-app:
    source: .
    plugin: flutter
    flutter-target: lib/main.dart
```

2. **Flatpak Package**
```xml
<!-- com.katya.wtf/com.katya.wtf.metainfo.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>com.katya.wtf</id>
  <name>Katya</name>
  <summary>Decentralized messaging app</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>GPL-3.0</project_license>
  <developer_name>Katya Systems, LLC</developer_name>
</component>
```

#### Windows

1. **MSIX Package**
```yaml
# build/windows/runner.msix
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:mp="http://schemas.microsoft.com/appx/2014/phone/manifest"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  IgnorableNamespaces="uap mp">

  <Identity Name="com.katya.wtf" Version="1.0.0.0" Publisher="CN=Katya Systems, LLC" />
  <mp:PhoneIdentity PhoneProductId="12345678-1234-1234-1234-123456789012" PhonePublisherId="00000000-0000-0000-0000-000000000000" />

  <Properties>
    <DisplayName>Katya</DisplayName>
    <PublisherDisplayName>Katya Systems, LLC</PublisherDisplayName>
    <Logo>Assets/StoreLogo.png</Logo>
  </Properties>

  <Dependencies>
    <TargetDeviceFamily Name="Windows.Universal" MinVersion="10.0.17763.0" MaxVersionTested="10.0.19041.0" />
  </Dependencies>

  <Resources>
    <Resource Language="x-generate" />
  </Resources>

  <Applications>
    <Application Id="App" Executable="$targetnametoken$.exe" EntryPoint="$targetentrypoint$">
      <uap:VisualElements DisplayName="Katya" Description="Decentralized messaging app"
        BackgroundColor="transparent" Square150x150Logo="Assets/Square150x150Logo.png"
        Square44x44Logo="Assets/Square44x44Logo.png">
        <uap:DefaultTile Wide310x150Logo="Assets/Wide310x150Logo.png" />
        <uap:SplashScreen Image="Assets/SplashScreen.png" />
      </uap:VisualElements>
    </Application>
  </Applications>

  <Capabilities>
    <rescap:Capability Name="runFullTrust" />
    <Capability Name="internetClient" />
    <Capability Name="documentsLibrary" />
  </Capabilities>
</Package>
```

#### macOS

1. **DMG Creation**
```bash
# Create DMG
flutter build macos --release
create-dmg --volname "Katya" --volicon "katya.icns" --window-pos 200 120 --window-size 800 400 --icon-size 100 --icon "katya.app" 200 190 --hide-extension "katya.app" --app-drop-link 600 185 "Katya.dmg" "build/macos/Build/Products/Release/katya.app"
```

### Web Deployment

#### Static Hosting

1. **Build Web App**
```bash
flutter build web --release
```

2. **Deploy to CDN**
```bash
# Firebase Hosting
firebase deploy

# Vercel
vercel --prod

# Netlify
netlify deploy --prod --dir=build/web
```

## Container Deployment

### Docker Setup

1. **Dockerfile**
```dockerfile
# Dockerfile
FROM ubuntu:20.04

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /flutter
ENV PATH="/flutter/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web app
RUN flutter build web --release

# Serve with nginx
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
```

2. **Docker Compose**
```yaml
# docker-compose.yml
version: '3.8'

services:
  katya-web:
    build: .
    ports:
      - "8080:80"
    environment:
      - MATRIX_HOMESERVER_URL=https://matrix.org

  katya-api:
    image: katya/api:latest
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/katya
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=katya
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Kubernetes Deployment

1. **Deployment Manifest**
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: katya
spec:
  replicas: 3
  selector:
    matchLabels:
      app: katya
  template:
    metadata:
      labels:
        app: katya
    spec:
      containers:
      - name: katya
        image: katya:latest
        ports:
        - containerPort: 8080
        env:
        - name: MATRIX_HOMESERVER_URL
          value: "https://matrix.org"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

2. **Service Manifest**
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: katya-service
spec:
  selector:
    app: katya
  ports:
    - port: 80
      targetPort: 8080
  type: LoadBalancer
```

## Cloud Deployment

### AWS

1. **ECS Fargate**
```hcl
# Terraform configuration
resource "aws_ecs_cluster" "katya" {
  name = "katya-cluster"
}

resource "aws_ecs_service" "katya" {
  name            = "katya-service"
  cluster         = aws_ecs_cluster.katya.id
  task_definition = aws_ecs_task_definition.katya.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.katya.arn
    container_name   = "katya"
    container_port   = 8080
  }
}
```

2. **Lambda@Edge**
```javascript
// Lambda@Edge function for global distribution
exports.handler = async (event) => {
  const request = event.Records[0].cf.request;

  // Add security headers
  request.headers['strict-transport-security'] = [{
    key: 'Strict-Transport-Security',
    value: 'max-age=31536000; includeSubDomains'
  }];

  return request;
};
```

### Google Cloud

1. **Cloud Run**
```yaml
# cloud-run.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: katya
spec:
  template:
    spec:
      containers:
      - image: gcr.io/project-id/katya:latest
        ports:
        - containerPort: 8080
        env:
        - name: MATRIX_HOMESERVER_URL
          value: "https://matrix.org"
```

2. **Firebase Hosting + Functions**
```javascript
// functions/index.js
const functions = require('firebase-functions');
const express = require('express');

const app = express();

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

exports.api = functions.https.onRequest(app);
```

### Azure

1. **App Service**
```json
{
  "name": "katya-app",
  "type": "Microsoft.Web/sites",
  "properties": {
    "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('appServicePlanName'))]",
    "siteConfig": {
      "linuxFxVersion": "DOCKER|katya:latest"
    }
  }
}
```

## CI/CD Integration

### GitHub Actions

1. **Release Workflow**
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'

      - name: Build Android
        run: flutter build apk --release

      - name: Build iOS
        run: flutter build ios --release

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            ## Changes
            - Android APK: [Download](https://github.com/${{ github.repository }}/releases/download/${{ github.ref }}/app-release.apk)
            - iOS IPA: [Download](https://github.com/${{ github.repository }}/releases/download/${{ github.ref }}/app-release.ipa)
          draft: false
          prerelease: false
```

### Fastlane Integration

1. **Fastfile**
```ruby
# fastlane/Fastfile
platform :android do
  desc "Deploy to Google Play"
  lane :deploy do
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end

platform :ios do
  desc "Deploy to App Store"
  lane :deploy do
    deliver(
      submit_for_review: true,
      automatic_release: true
    )
  end
end
```

## Monitoring and Maintenance

### Health Checks

1. **Application Health**
```dart
// Health check endpoint
app.get('/health', (req, res) => {
  // Check database connection
  // Check Matrix homeserver connectivity
  // Check encryption keys
  res.json({ status: 'healthy' });
});
```

2. **Performance Monitoring**
```dart
// Performance monitoring
class PerformanceMonitor {
  static void trackEvent(String event, Map<String, dynamic> data) {
    // Send to monitoring service
  }

  static void trackError(dynamic error, StackTrace stackTrace) {
    // Send to error tracking service
  }
}
```

### Log Management

1. **Structured Logging**
```dart
// Logger configuration
final logger = Logger()
  ..onRecord.listen((record) {
    // Send to log aggregation service
  });
```

### Backup and Recovery

1. **Database Backup**
```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U katya_user katya_db > "backup_$DATE.sql"
```

## Troubleshooting

### Common Issues

#### Build Failures

1. **Flutter Version Mismatch**
```bash
# Update Flutter
flutter upgrade

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

2. **Platform-Specific Issues**

**Android:**
```bash
# Clear Gradle cache
cd android
./gradlew clean
cd ..
```

**iOS:**
```bash
# Clean CocoaPods
cd ios
rm -rf Pods
pod install
cd ..
```

#### Runtime Issues

1. **Matrix Connection Problems**
```dart
// Check homeserver configuration
final client = Client(homeserver: Uri.parse('https://matrix.org'));
await client.checkHomeserver();
```

2. **Encryption Issues**
```dart
// Reset encryption state
await client.encryption?.resetDeviceKeys();
```

### Performance Optimization

1. **Bundle Size Reduction**
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/  # Only include necessary assets
```

2. **Code Splitting**
```dart
// Lazy load features
import 'features/chat/chat_page.dart' deferred as chat;

Future<void> loadChatPage() async {
  await chat.loadLibrary();
  // Navigate to chat page
}
```

### Security Hardening

1. **Certificate Pinning**
```dart
// HTTP client with certificate pinning
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    // Validate certificate
    return true; // or false based on validation
  };
```

2. **Input Validation**
```dart
// Sanitize user input
String sanitizeInput(String input) {
  return input.replaceAll(RegExp(r'[<>]'), '');
}
```

## Conclusion

This deployment guide covers the comprehensive setup and deployment strategies for Katya across multiple platforms. For specific platform requirements or advanced configurations, refer to the platform-specific documentation or create an issue in the repository.

Remember to:
- Test deployments in staging environments first
- Monitor application performance post-deployment
- Keep dependencies updated and secure
- Regularly backup data and configurations
- Follow security best practices

For additional support, join our community channels or check the troubleshooting section in the main README.
