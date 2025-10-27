# macOS Platform Configuration & Implementation Guide

## 🎯 Platform Overview

**Platform**: macOS (Desktop, Laptop, Apple Silicon, Intel)  
**Minimum macOS Version**: 12.0 (Monterey)  
**Target macOS Versions**: 12.0 - 15.0+ (Sequoia)  
**Swift Version**: 5.9  
**Xcode Version**: 15.0+  
**Flutter SDK**: 3.16.0+  

## 📁 Complete Project Structure

```
macos/
├── Runner/
│   ├── AppDelegate.swift
│   ├── MainFlutterWindow.swift
│   ├── Info.plist
│   ├── Assets.xcassets/
│   ├── Base.lproj/
│   ├── Config/
│   ├── Utils/
│   └── Scripts/
├── Flutter/
│   ├── GeneratedPluginRegistrant.swift
│   ├── GeneratedPluginRegistrant.h
│   └── AppFrameworkInfo.plist
├── Podfile
├── Podfile.lock
├── Runner.xcworkspace/
├── Runner.xcodeproj/
│   ├── project.pbxproj
│   ├── project.xcconfig
│   └── xcshareddata/
├── fastlane/
│   ├── Appfile
│   ├── Deliverfile
│   ├── Fastfile
│   └── Matchfile
├── scripts/
│   ├── build.sh
│   ├── test.sh
│   ├── notarize.sh
│   └── deploy.sh
├── Config/
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   └── Profile.xcconfig
├── entitlements/
│   ├── debug.plist
│   ├── release.plist
│   └── profile.plist
└── docs/
    ├── API.md
    ├── Capabilities.md
    ├── Notarization.md
    └── Distribution.md
```

## 🛠 Development Requirements

### Required Software
- **Xcode 15.0+** (App Store or Developer Portal)
- **CocoaPods 1.12.0+** (`sudo gem install cocoapods`)
- **Flutter SDK 3.16.0+**
- **macOS 12.0+** (for development)
- **Apple Developer Account** (for code signing)

### Development Tools
- **VS Code** with Flutter and macOS extensions
- **Xcode IDE** (primary development environment)
- **fastlane** for automated deployment
- **match** for code signing management
- **notarytool** for app notarization

## ⚙️ Build Configuration

### Environment Variables
```bash
export MACOSX_DEPLOYMENT_TARGET=12.0
export SWIFT_VERSION=5.9
export FLUTTER_FRAMEWORK_DIR="$FLUTTER_ROOT/bin/cache/artifacts/macos/"
export ARCHS_STANDARD="x86_64 arm64"
```

### Debug Build
```bash
flutter build macos --debug
# or
flutter run --debug
```

### Release Build
```bash
flutter build macos --release
# or
flutter build macos --release --obfuscate --split-debug-info=debug-info/
```

### Profile Build
```bash
flutter build macos --profile
```

### Universal Binary Build
```bash
flutter build macos --release --target-archs="x86_64,arm64"
```

### Fastlane Lanes
```ruby
# Fastfile
lane :development do
  build_mac_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    configuration: "Debug",
    export_method: "development",
    output_directory: "build/macos/development"
  )
end

lane :release do
  build_mac_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    configuration: "Release",
    export_method: "app-store",
    output_directory: "build/macos/appstore"
  )
  notarize_app
end
```

## 🔐 Capabilities & Entitlements

### Required Capabilities
- **App Sandbox** (required for App Store)
- **Hardened Runtime** (required for notarization)
- **Keychain Access Groups**
- **App Groups** (for sharing data with extensions)
- **Background Processing**
- **Network Extensions**

### Enhanced Capabilities
- **Camera Access**
- **Microphone Access**
- **Photo Library**
- **Location Services**
- **Calendar Integration**
- **Contacts Integration**
- **Reminders Integration**
- **Notes Integration**
- **Full Disk Access** (for advanced features)
- **Screen Recording** (for screen sharing)

### Entitlements Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.device.camera</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    <key>com.apple.security.personal-information.calendars</key>
    <true/>
    <key>com.apple.security.personal-information.contacts</key>
    <true/>
    <key>com.apple.security.personal-information.photos-library</key>
    <true/>
    <key>com.apple.security.personal-information.location</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.katya.app</string>
    </array>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <false/>
    <key>com.apple.security.cs.debugger</key>
    <false/>
    <key>com.apple.security.temporary-exception.apple-events</key>
    <array>
        <string>com.apple.systempreferences</string>
        <string>com.apple.finder</string>
    </array>
</dict>
</plist>
```

## 💻 Platform-Specific Features

### Native macOS Features
- **Menu Bar Integration** (custom menu items)
- **Dock Integration** (dock icon, badges, progress)
- **Notification Center** (rich notifications)
- **System Preferences** (native preferences)
- **Keychain Services** (secure credential storage)
- **Spotlight Integration** (search indexing)
- **Handoff Support** (continuity between devices)
- **Universal Clipboard** (cross-device copy/paste)
- **Sidecar Support** (iPad as external display)
- **Apple Silicon Native Support**

### Advanced macOS Features
- **Multiple Windows** (MDI support)
- **Window Management** (minimize, maximize, resize)
- **Drag and Drop** (file operations)
- **Services Integration** (system services)
- **Quick Look Integration** (preview support)
- **Share Menu Integration**
- **Touch Bar Support** (MacBook Pro)
- **External Display Management**
- **AppleScript Support**
- **Automator Actions**

### Desktop Integration
- **File Associations** (custom file types)
- **URL Schemes** (katya:// protocol)
- **Launch Services** (login items, startup)
- **System Extensions** (network, content filters)
- **Background Tasks** (scheduled operations)
- **Update Mechanisms** (Sparkle integration)

## 🏪 Mac App Store & Distribution

### App Store Connect Setup
- **Bundle ID**: `com.katya.app`
- **App Name**: "Katya Messenger"
- **Primary Category**: Social Networking
- **Secondary Category**: Productivity

### Distribution Methods
- **Development** (internal testing)
- **Direct Distribution** (outside App Store)
- **Mac App Store** (public release)
- **Enterprise** (internal distribution)

### App Store Assets
- **App Icon**: 512x512 PNG (multiple sizes)
- **Screenshots**: 13" and 16" MacBook sizes
- **App Preview**: 15-30 second videos
- **Metadata**: Description, keywords, support info

## 🔧 Advanced Configuration

### Build Settings
```xml
<!-- Debug Configuration -->
CONFIGURATION_BUILD_DIR = ${BUILD_DIR}/${CONFIGURATION}-macos
ONLY_ACTIVE_ARCH = YES
DEBUG_INFORMATION_FORMAT = dwarf
ENABLE_TESTABILITY = YES

<!-- Release Configuration -->
CONFIGURATION_BUILD_DIR = ${BUILD_DIR}/${CONFIGURATION}-macos
VALIDATE_PRODUCT = YES
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
BITCODE_GENERATION_MODE = bitcode
```

### Universal Binary Settings
```xml
ARCHS = $(ARCHS_STANDARD)
SUPPORTED_PLATFORMS = macosx
MACOSX_DEPLOYMENT_TARGET = 12.0
SDKROOT = macosx
```

### Optimization Settings
- **Link-Time Optimization** (Release only)
- **Dead Code Stripping**
- **Symbol Generation** (dSYMs)
- **App Sandbox** (required for App Store)
- **Hardened Runtime** (required for notarization)

### Notarization Requirements
```bash
# Notarize app for distribution outside App Store
xcrun notarytool submit Katya.app.zip --apple-id developer@katya.im --team-id TEAM_ID --password APP_PASSWORD

# Check notarization status
xcrun notarytool info REQUEST_UUID --apple-id developer@katya.im --team-id TEAM_ID --password APP_PASSWORD
```

## 🧪 Testing & Quality Assurance

### Testing Framework
- **XCTest** for unit tests
- **XCUITest** for UI tests
- **Flutter Integration Tests**
- **Performance Tests**

### Testing Commands
```bash
# Run macOS tests
flutter test integration_test/macos_test.dart

# Run native macOS tests
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=macOS'

# Performance testing
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=macOS' -testplan PerformanceTests
```

### Quality Gates
- **Code Coverage**: >80%
- **Performance**: <200ms launch time
- **Memory Usage**: <100MB baseline
- **App Sandbox**: Must pass sandboxing
- **Notarization**: Must pass Apple notarization

## 🚀 Deployment & CI/CD

### GitHub Actions
```yaml
name: macOS Build
on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
    - run: flutter pub get
    - run: flutter build macos --release
    - uses: actions/upload-artifact@v3
      with:
        name: macos-build
        path: build/macos/Build/Products/Release/
```

### Fastlane Configuration
```ruby
# macOS Fastfile
default_platform(:macos)

platform :macos do
  desc "Build and notarize for direct distribution"
  lane :distribute do
    setup_ci if is_ci
    match(type: "developer_id")

    build_mac_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release",
      export_method: "developer-id",
      output_directory: "build/macos/distribution"
    )

    notarize_app
    create_dmg
  end

  desc "Build and deploy to Mac App Store"
  lane :appstore do
    setup_ci if is_ci
    match(type: "appstore")

    build_mac_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release",
      export_method: "app-store",
      output_directory: "build/macos/appstore"
    )

    upload_to_app_store
  end

  desc "Create DMG for distribution"
  private_lane :create_dmg do
    sh("create-dmg --window-size 800 600 --app-drop-link 600 300 --icon Runner.app 200 300 build/macos/distribution/Katya.dmg build/macos/distribution/")
  end

  desc "Notarize app with Apple"
  private_lane :notarize_app do
    sh("xcrun notarytool submit build/macos/distribution/Katya.app.zip --apple-id #{ENV['APPLE_ID']} --team-id #{ENV['TEAM_ID']} --password #{ENV['APP_PASSWORD']}")
  end
end
```

## 📚 Documentation & Resources

### Official Documentation
- [macOS Development Guide](https://developer.apple.com/macos/)
- [Flutter macOS Setup](https://docs.flutter.dev/development/platform-integration/macos)
- [App Sandbox Guide](https://developer.apple.com/documentation/security/app_sandbox)
- [Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

### Best Practices
- [macOS Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/)
- [Security Best Practices](https://developer.apple.com/security/)
- [Performance Best Practices](https://developer.apple.com/documentation/)

## 🔍 Troubleshooting

### Common Issues
- **Build Failures**: Clear Flutter cache (`flutter clean`)
- **Code Signing Issues**: Check certificates and Developer ID
- **Sandbox Violations**: Review sandbox requirements
- **Notarization Failures**: Check entitlements and hardened runtime
- **Universal Binary Issues**: Verify both architectures build

### Debug Commands
```bash
# Clear all caches
flutter clean
flutter pub cache repair

# Reset macOS build
rm -rf macos/build
rm macos/Podfile.lock
cd macos && pod install

# Check code signing
codesign --verify --verbose Runner.app

# Check sandbox violations
Console.app (search for sandbox violations)

# Test notarization
xcrun spctl --assess --verbose Runner.app
```

## 📞 Support & Contact

- **Developer Portal**: [developer.apple.com](https://developer.apple.com)
- **Flutter Community**: [flutter.dev/community](https://flutter.dev/community)
- **Mac App Store Contact**: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

---

**Last Updated**: December 2024
**macOS Version Support**: macOS 12.0 - 15.0+
**Maintenance Status**: Actively Maintained
