# Getting Started with Katya

Welcome to Katya! This guide will help you set up the project on your local machine for development and testing.

## Prerequisites

Before you begin, ensure you have the following installed:

### Core Tools
- **[Flutter SDK](https://flutter.dev/docs/get-started/install)** (version 3.0 or higher recommended)
- **[Dart SDK](https://dart.dev/get-dart)** (comes with Flutter)
- **Git** for version control

### Platform-Specific Tools
- **For Android Development**:
  - [Android Studio](https://developer.android.com/studio) with Android SDK
  - Android emulator or physical device

- **For iOS Development**:
  - [Xcode](https://developer.apple.com/xcode/) (macOS only)
  - iOS simulator or physical device

- **For Web Development**:
  - Modern web browser (Chrome, Firefox, Safari, Edge)
  - Web server capabilities (Flutter web runs on localhost)

- **For Desktop Development**:
  - Additional Flutter desktop support enabled

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/sorydima/Katya-.git
cd Katya-
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Platform Support

Enable the platforms you want to develop for:

```bash
# Enable Android (enabled by default)
flutter config --enable-android

# Enable iOS (macOS only)
flutter config --enable-ios

# Enable Web
flutter config --enable-web

# Enable Linux
flutter config --enable-linux

# Enable Windows
flutter config --enable-windows

# Enable macOS
flutter config --enable-macos
```

### 4. Run the Application

Choose your target platform:

```bash
# Run on connected Android device/emulator
flutter run -d android

# Run on connected iOS device/simulator
flutter run -d ios

# Run on web
flutter run -d web

# Run on desktop
flutter run -d linux
flutter run -d windows
flutter run -d macos
```

### 5. Build for Production

```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS IPA
flutter build ipa

# Build Web
flutter build web

# Build Desktop
flutter build linux
flutter build windows
flutter build macos
```

## Development Workflow

### Hot Reload
During development, use hot reload to see changes instantly:

```bash
flutter run --hot-reload
```

### Hot Restart
For a complete restart without losing state:

```bash
flutter run --hot-restart
```

### Debugging
- Use `flutter run --debug` for debugging mode
- Open DevTools with `flutter pub global run devtools`
- Use `print()` statements for simple debugging

## Common Issues

### Flutter Doctor
If you encounter issues, run:

```bash
flutter doctor
```

This will diagnose your setup and suggest fixes.

### Permission Issues
On Linux/macOS, you might need to make the Flutter tools executable:

```bash
chmod +x flutter/bin/flutter
```

### Network Issues
If you're behind a proxy, configure Flutter:

```bash
export HTTP_PROXY=http://proxy.example.com:port
export HTTPS_PROXY=http://proxy.example.com:port
```

## Next Steps

- Read the [Contributing Guidelines](CONTRIBUTING.md) to learn how to contribute
- Check out the [API Documentation](docs/API.md) for detailed API information
- Explore [Development Guidelines](docs/DEVELOPMENT.md) for best practices
- Review [Deployment Instructions](docs/DEPLOYMENT.md) for production deployment

## Getting Help

If you get stuck:
- Check the [Flutter Documentation](https://flutter.dev/docs)
- Search existing [issues](https://github.com/sorydima/Katya-/issues)
- Ask for help in [Discussions](https://github.com/sorydima/Katya-/discussions)
- Read the [Support Guide](SUPPORT.md)

Happy coding! 🚀
