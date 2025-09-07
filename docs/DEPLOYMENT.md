# Deployment Guide

This guide covers the deployment process for Katya across various platforms including Android, iOS, Web, and desktop environments.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Android Deployment](#android-deployment)
- [iOS Deployment](#ios-deployment)
- [Web Deployment](#web-deployment)
- [Desktop Deployment](#desktop-deployment)
- [Environment Configuration](#environment-configuration)
- [Continuous Deployment](#continuous-deployment)
- [Troubleshooting](#troubleshooting)

## Overview

Katya supports deployment to multiple platforms. This guide provides step-by-step instructions for each target environment.

## Prerequisites

Before deployment, ensure you have:

- Flutter SDK installed and configured
- Platform-specific tools (Android Studio, Xcode, etc.)
- Necessary certificates and signing keys
- Environment variables configured
- API keys and configuration files ready

## Android Deployment

### 1. Prepare for Release

```bash
# Check build configuration
flutter build apk --debug
flutter build apk --profile

# Analyze app size
flutter build apk --analyze-size
```

### 2. Configure Signing

Create or use existing signing key:
```bash
# Generate keystore (if needed)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Configure `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias 'key'
            keyPassword 'your-key-password'
            storeFile file('~/key.jks')
            storePassword 'your-store-password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build Release APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### 4. Deploy to Google Play Store

1. Create listing in Google Play Console
2. Upload App Bundle (.aab file)
3. Configure store listing, pricing, and distribution
4. Submit for review

## iOS Deployment

### 1. Prepare for Release

```bash
# Check iOS build
flutter build ios --debug
flutter build ios --profile
```

### 2. Configure Code Signing

1. Open iOS project in Xcode: `open ios/Runner.xcworkspace`
2. Select signing team in Xcode
3. Configure provisioning profiles

### 3. Build IPA

```bash
# Build IPA for distribution
flutter build ipa --release
```

### 4. Deploy to App Store

1. Use Xcode Organizer to upload IPA
2. Or use Transporter app
3. Configure App Store Connect listing
4. Submit for review

## Web Deployment

### 1. Build for Production

```bash
# Build web assets
flutter build web --release

# Build with specific base href (if needed)
flutter build web --release --base-href="/katya/"
```

### 2. Deploy to Web Server

#### Option A: Static Hosting (Netlify, Vercel, GitHub Pages)
```bash
# Build and deploy to Netlify
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

#### Option B: Traditional Web Server
Upload `build/web` contents to your web server:
- Nginx/Apache configuration
- Ensure proper MIME types
- Configure HTTPS

#### Option C: Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize and deploy
firebase init hosting
firebase deploy
```

### 3. Web Configuration

Ensure proper `index.html` configuration:
```html
<base href="/">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

## Desktop Deployment

### Linux Deployment

```bash
# Build Linux app
flutter build linux --release

# Create distribution package
# Install required tools: sudo apt install snapcraft
snapcraft
```

### Windows Deployment

```bash
# Build Windows app
flutter build windows --release

# Create installer (using Inno Setup, NSIS, etc.)
# Package build/windows/runner/Release directory
```

### macOS Deployment

```bash
# Build macOS app
flutter build macos --release

# Create DMG package
# Use create-dmg or similar tools
```

## Environment Configuration

### Environment Variables

Create `.env` file for environment-specific configuration:
```
API_BASE_URL=https://api.katya.app
SENTRY_DSN=your-sentry-dsn
APP_ENV=production
```

Load environment variables in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: ".env");
String apiUrl = dotenv.get('API_BASE_URL');
```

### Configuration Files

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="Katya"
        android:icon="@mipmap/ic_launcher">
    </application>
</manifest>
```

**ios/Runner/Info.plist:**
```xml
<key>CFBundleDisplayName</key>
<string>Katya</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

## Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: app-release
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Environment-Specific Workflows

**Android CI/CD:**
```yaml
- name: Build Android APK
  run: flutter build apk --release
  
- name: Upload to Google Play
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJson: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
    packageName: com.example.katya
    releaseFiles: build/app/outputs/flutter-apk/app-release.apk
```

**Web CI/CD:**
```yaml
- name: Build Web
  run: flutter build web --release
  
- name: Deploy to Netlify
  run: |
    npm install -g netlify-cli
    netlify deploy --prod --dir=build/web
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## Troubleshooting

### Common Deployment Issues

**Android:**
- Keystore not found: Verify path in build.gradle
- Signing configuration errors: Check key passwords
- Version code conflicts: Increment version in pubspec.yaml

**iOS:**
- Code signing issues: Check Xcode signing configuration
- Provisioning profile errors: Renew profiles in Apple Developer account
- App Store rejection: Review App Store guidelines

**Web:**
- CORS issues: Configure server CORS headers
- Routing problems: Ensure base href is correct
- Asset loading failures: Check asset paths

**General:**
- Build failures: Run `flutter clean` and `flutter pub get`
- Environment variable issues: Verify .env file loading
- API connectivity: Check network configuration

### Logging and Monitoring

Configure error tracking:
```dart
// Add Sentry for error tracking
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) => options.dsn = 'YOUR_SENTRY_DSN',
    appRunner: () => runApp(MyApp()),
  );
}
```

### Performance Monitoring

Use Firebase Performance Monitoring or similar tools:
```yaml
# pubspec.yaml
dependencies:
  firebase_performance: ^0.8.0
```

## Rollback Procedures

### Android/iOS
- Use platform-specific rollback features
- Deploy previous version through app stores
- Communicate with users if needed

### Web
- Redeploy previous build version
- Use CDN versioning if available
- Implement feature flags for gradual rollouts

### Database Migrations
- Always backup before deployment
- Use database migration tools
- Test migrations in staging environment

## Security Considerations

- Use HTTPS for all communications
- Validate input data thoroughly
- Secure API keys and secrets
- Regular security audits
- Keep dependencies updated

## Support

For deployment issues:
- Check [Flutter deployment documentation](https://flutter.dev/docs/deployment)
- Review platform-specific deployment guides
- Check existing [issues](https://github.com/sorydima/Katya-/issues)
- Ask in [discussions](https://github.com/sorydima/Katya-/discussions)

## Changelog

See [CHANGELOG.md](../CHANGELOG.md) for deployment-related changes and updates.