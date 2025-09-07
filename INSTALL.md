# Installation Guide

This guide provides detailed installation instructions for Katya across different environments and use cases.

## Table of Contents
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Standard Installation](#standard-installation)
- [Alternative Installation Methods](#alternative-installation-methods)
- [Production Deployment](#production-deployment)
- [Docker Installation](#docker-installation)
- [Troubleshooting](#troubleshooting)

## Quick Start

For most users, the quickest way to get started is:

```bash
# Clone the repository
git clone https://github.com/sorydima/Katya-.git
cd Katya-

# Install dependencies
flutter pub get

# Run the application
flutter run
```

## System Requirements

### Development Environment
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 2.17.0 or higher
- **Disk Space**: Minimum 2GB free space
- **RAM**: 8GB recommended (4GB minimum)

### Production Environment
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Desktop**: Windows 10+, macOS 10.14+, Linux (various distributions)

## Standard Installation

### 1. Install Flutter SDK

**Windows:**
```bash
# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.0.0-stable.zip
# Extract and add to PATH
```

**macOS:**
```bash
# Using Homebrew
brew install --cask flutter

# Or manual installation
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.0.0-stable.zip
```

**Linux:**
```bash
# Using snap
sudo snap install flutter --classic

# Or manual installation
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.0.0-stable.tar.xz
```

### 2. Verify Installation
```bash
flutter doctor
```

### 3. Clone Repository
```bash
git clone https://github.com/sorydima/Katya-.git
cd Katya-
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the Application
```bash
# Run on default device
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d web
```

## Alternative Installation Methods

### Using Flutter Version Management

**fvm (Flutter Version Management):**
```bash
# Install fvm
dart pub global activate fvm

# Install specific Flutter version
fvm install 3.0.0

# Use installed version
fvm use 3.0.0

# Install dependencies
fvm flutter pub get
```

### Pre-built Binaries

For users who don't want to build from source:

**Android:**
- Download APK from [Releases page](https://github.com/sorydima/Katya-/releases)
- Enable "Install from unknown sources"
- Install the APK file

**Web:**
- Access the deployed web version at [katya.app](https://katya.app) (if available)

## Production Deployment

### Android APK Installation

```bash
# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (AAB)

```bash
# Build App Bundle
flutter build appbundle --release

# Upload to Google Play Store
# File: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA Installation

```bash
# Build IPA
flutter build ipa --release

# Distribute via TestFlight or App Store
```

### Web Deployment

```bash
# Build web version
flutter build web --release

# Deploy to web server
# Copy build/web contents to your web server
```

## Docker Installation

### Dockerfile for Development
```dockerfile
FROM dart:3.0.0

WORKDIR /app
COPY . .
RUN dart pub get

CMD ["dart", "run"]
```

### Docker Compose for Development
```yaml
version: '3.8'
services:
  katya:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - .:/app
    environment:
      - FLUTTER_ROOT=/usr/lib/flutter
```

### Building and Running with Docker
```bash
# Build image
docker build -t katya .

# Run container
docker run -p 8080:8080 katya
```

## Platform-Specific Installation

### Android Setup
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install Android Studio
# Configure Android SDK and emulator
```

### iOS Setup (macOS only)
```bash
# Install Xcode from App Store
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Open iOS simulator
open -a Simulator
```

### Web Setup
```bash
# Enable web support
flutter config --enable-web

# Check web requirements
flutter doctor
```

### Desktop Setup
```bash
# Enable desktop support
flutter config --enable-windows
flutter config --enable-macos
flutter config --enable-linux

# Install platform-specific dependencies
# Windows: Visual Studio with C++ workload
# macOS: Xcode command line tools
# Linux: libgtk-3-dev, libblkid-dev, etc.
```

## Configuration

### Environment Variables
Create `.env` file:
```bash
API_BASE_URL=https://api.katya.app
APP_ENV=production
DEBUG=false
```

### Platform Configuration

**Android (android/app/build.gradle):**
```gradle
android {
    compileSdkVersion 33
    defaultConfig {
        applicationId "com.example.katya"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleDisplayName</key>
<string>Katya</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
```

## Troubleshooting

### Common Installation Issues

**Flutter doctor shows errors:**
```bash
# Fix Android licenses
flutter doctor --android-licenses

# Install missing components
# Follow the suggestions from flutter doctor
```

**Pub get fails:**
```bash
# Clear pub cache
flutter pub cache repair

# Clean and reinstall
flutter clean
flutter pub get
```

**Build failures:**
```bash
# Check Flutter version
flutter --version

# Ensure platform support is enabled
flutter config
```

**Network issues:**
```bash
# Set proxy if behind firewall
export HTTP_PROXY=http://proxy.example.com:port
export HTTPS_PROXY=http://proxy.example.com:port
```

### Platform-Specific Issues

**Android:**
- Ensure Android SDK is properly installed
- Check emulator or device connectivity
- Verify Gradle configuration

**iOS:**
- Check Xcode installation and signing
- Verify provisioning profiles
- Ensure simulator is available

**Web:**
- Check browser compatibility
- Verify CORS configuration
- Ensure proper base href setting

## Verification

After installation, verify everything works:

```bash
# Run tests
flutter test

# Check analysis
flutter analyze

# Verify build
flutter build apk --debug
```

## Support

If you encounter issues during installation:
1. Check the [Troubleshooting section](#troubleshooting)
2. Review [Getting Started Guide](Getting_Started.md)
3. Search [existing issues](https://github.com/sorydima/Katya-/issues)
4. Ask in [discussions](https://github.com/sorydima/Katya-/discussions)

## Next Steps

After successful installation:
- Read the [Development Guide](docs/DEVELOPMENT.md)
- Explore the [API Documentation](docs/API.md)
- Check [Deployment Guide](docs/DEPLOYMENT.md) for production setup
- Review [Contributing Guidelines](CONTRIBUTING.md) to start contributing

---

*For the latest installation instructions, always check the [GitHub repository](https://github.com/sorydima/Katya-)*