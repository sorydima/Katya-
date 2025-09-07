# Development Environment Setup

This guide provides detailed instructions for setting up a development environment for the Katya project.

## Prerequisites

### System Requirements
- **Operating System**: Windows 10/11, macOS 12+, Ubuntu 20.04+
- **RAM**: Minimum 8GB, Recommended 16GB+
- **Storage**: 20GB free space
- **Internet**: Stable broadband connection

### Required Software
- **Flutter SDK**: Version 3.10.0 or later
- **Dart SDK**: Included with Flutter
- **Git**: Version 2.30.0 or later
- **Visual Studio Code**: Latest version with Flutter extensions
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)

## Quick Setup (Automated)

### Using Dev Container (Recommended)

1. Install Visual Studio Code
2. Install the "Dev Containers" extension
3. Clone the repository
4. Open in VS Code
5. When prompted, click "Reopen in Container"
6. Wait for the container to build and setup

### Using Setup Script

```bash
# Clone repository
git clone https://github.com/your-org/katya.git
cd katya

# Run setup script
./scripts/setup.sh

# Or manually:
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Manual Setup

### 1. Install Flutter

#### Windows
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
# Edit environment variables and add Flutter\bin to PATH

# Verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download manually
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.0-stable.tar.xz
tar xf flutter_linux_3.10.0-stable.tar.xz

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Install Android Studio

1. Download from [developer.android.com](https://developer.android.com/studio)
2. Install Android SDK
3. Install Android SDK Command-line Tools
4. Accept Android licenses: `flutter doctor --android-licenses`

### 3. Install Xcode (macOS only)

1. Install from Mac App Store
2. Install Xcode Command Line Tools: `xcode-select --install`
3. Accept Xcode license: `sudo xcodebuild -license accept`

### 4. Configure IDE

#### Visual Studio Code
1. Install extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets
   - Prettier
   - GitLens

2. Configure settings:
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "dart.lineLength": 120
}
```

### 5. Project Setup

```bash
# Clone repository
git clone https://github.com/your-org/katya.git
cd katya

# Initialize submodules
git submodule update --init --recursive

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test
```

## Platform-Specific Setup

### iOS Development
```bash
# Enable iOS desktop
flutter config --enable-macos-desktop

# Install CocoaPods
sudo gem install cocoapods

# For macOS development
flutter config --enable-macos-desktop
```

### Android Development
```bash
# Enable Android desktop
flutter config --enable-linux-desktop

# Create Android emulator
flutter emulators --create
```

### Web Development
```bash
# Enable web
flutter config --enable-web

# Build for web
flutter build web
```

## Troubleshooting

### Common Issues

#### Flutter doctor shows issues
```bash
# Update Flutter
flutter upgrade

# Clean Flutter cache
flutter clean
flutter pub cache repair

# Reinstall Flutter
flutter doctor --android-licenses
```

#### Build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### iOS build fails
```bash
# Clean iOS build
flutter clean
cd ios
pod install
cd ..
flutter build ios
```

### Getting Help

- Check [Flutter documentation](https://flutter.dev/docs)
- Join [Flutter Discord](https://flutter.dev/community)
- Create an issue in the repository
- Contact the development team

## Next Steps

Once your environment is set up:
1. Read the [CONTRIBUTING.md](../CONTRIBUTING.md) guide
2. Explore the [project architecture](../docs/architecture/)
3. Start with a simple feature or bug fix
4. Run the test suite before submitting changes
