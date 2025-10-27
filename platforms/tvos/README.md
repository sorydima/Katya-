# tvOS Platform Configuration

## Target Platforms
- Apple TV (tvOS 15.0+)
- Apple TV 4K
- Apple TV HD
- Future Apple TV devices

## Development Requirements
- Xcode 13.0+ with tvOS support
- tvOS SDK 15.0+
- Apple Developer Account
- Apple TV device or simulator
- Swift 5.5+

## Build Settings
- **tvOS Version**: 15.0+
- **Target Architecture**: ARM64
- **Build Type**: Release, Debug
- **Deployment Target**: 15.0
- **UI Framework**: TVUIKit + UIKit

## Project Structure
```
tvos/
├── Runner/
│   ├── AppDelegate.swift
│   ├── Runner.entitlements
│   ├── Info.plist
│   └── Main.storyboard
├── Flutter/
│   └── GeneratedPluginRegistrant.swift
├── Podfile
├── Podfile.lock
└── Runner.xcworkspace
```

## tvOS Configuration

### Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Katya</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
        <string>tvOS</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    <key>UIUserInterfaceStyle</key>
    <string>Automatic</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
```

## Platform-Specific Features

### TV Interface
```swift
// tvos/Runner/AppDelegate.swift
import UIKit
import Flutter
import TVUIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure for TV interface
    configureTVInterface()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureTVInterface() {
    // Configure focus-based navigation
    TVApplicationController.shared.enableFocusSystem()

    // Set up TV-specific UI
    let window = UIApplication.shared.windows.first
    window?.tintColor = UIColor.systemBlue

    // Configure remote control
    configureRemoteControl()
  }

  private func configureRemoteControl() {
    // Set up Siri Remote integration
    let remoteCommandCenter = MPRemoteCommandCenter.shared()
    remoteCommandCenter.playCommand.isEnabled = true
    remoteCommandCenter.pauseCommand.isEnabled = true
  }
}
```

### Focus Navigation
```dart
// lib/platforms/tvos/focus_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVFocusNavigation extends StatefulWidget {
  final Widget child;

  const TVFocusNavigation({Key? key, required this.child}) : super(key: key);

  @override
  _TVFocusNavigationState createState() => _TVFocusNavigationState();
}

class _TVFocusNavigationState extends State<TVFocusNavigation> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Configure TV focus system
    _setupTVFocus();
  }

  void _setupTVFocus() {
    // Set up focus traversal for TV remote
    FocusTraversalGroup.of(context)?.policy = ReadingOrderTraversalPolicy();

    // Handle TV remote button presses
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.select:
          _handleSelect();
          return true;
        case LogicalKeyboardKey.arrowUp:
          _handleDirection(TraversalDirection.up);
          return true;
        case LogicalKeyboardKey.arrowDown:
          _handleDirection(TraversalDirection.down);
          return true;
        case LogicalKeyboardKey.arrowLeft:
          _handleDirection(TraversalDirection.left);
          return true;
        case LogicalKeyboardKey.arrowRight:
          _handleDirection(TraversalDirection.right);
          return true;
        case LogicalKeyboardKey.playPause:
          _handlePlayPause();
          return true;
        default:
          break;
      }
    }
    return false;
  }

  void _handleSelect() {
    // Handle select button (equivalent to tap)
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _handleDirection(TraversalDirection direction) {
    // Handle directional navigation
    FocusScope.of(context).nextFocus();
  }

  void _handlePlayPause() {
    // Handle play/pause button
    // Could be used for media playback
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}
```

### Siri Remote Integration
```swift
// tvos/Runner/TVRemoteHandler.swift
import UIKit
import TVUIKit

class TVRemoteHandler: NSObject {
  private var flutterChannel: FlutterMethodChannel?

  init(withBinaryMessenger messenger: FlutterBinaryMessenger) {
    super.init()
    flutterChannel = FlutterMethodChannel(
      name: "com.katya/tvos_remote",
      binaryMessenger: messenger
    )
    flutterChannel?.setMethodCallHandler(handleMethodCall)
  }

  func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getRemoteType":
      result(getRemoteType())
    case "enableGestureRecognition":
      enableGestureRecognition()
      result(nil)
    case "configureHapticFeedback":
      configureHapticFeedback(call.arguments as? Bool ?? false)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getRemoteType() -> String {
    // Detect Siri Remote type (1st gen, 2nd gen, etc.)
    if #available(tvOS 15.0, *) {
      let remote = TVRemoteController.shared
      return remote.remoteType.rawValue
    }
    return "unknown"
  }

  private func enableGestureRecognition() {
    // Enable gesture recognition for Siri Remote
    if #available(tvOS 15.0, *) {
      TVRemoteController.shared.enableGestureRecognition()
    }
  }

  private func configureHapticFeedback(_ enabled: Bool) {
    // Configure haptic feedback for remote interactions
    if #available(tvOS 15.0, *) {
      TVRemoteController.shared.hapticFeedbackEnabled = enabled
    }
  }
}
```

## Build Commands

### tvOS Development Build
```bash
# Build for tvOS simulator
flutter build ios --simulator --flavor tvos

# Build for tvOS device
flutter build ios --device --flavor tvos

# Create tvOS app bundle
flutter build ios --release --flavor tvos --export-method app-store
```

### Apple TV Distribution
```bash
# Build for Apple TV App Store
flutter build ios --release --flavor tvos --export-method app-store

# Validate with Apple
xcrun altool --validate-app -f build/ios/iphoneos/Runner.app -t tvOS -u your-apple-id

# Upload to Apple TV App Store
xcrun altool --upload-app -f build/ios/iphoneos/Runner.app -t tvOS -u your-apple-id
```

## UI Components

### TV-Optimized UI
```dart
// lib/platforms/tvos/tv_ui_components.dart
import 'package:flutter/material.dart';

class TVHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TVScaffold(
      appBar: TVAppBar(
        title: 'Katya',
        leading: TVButton.icon(
          icon: Icons.settings,
          onPressed: () => navigateToSettings(),
        ),
        actions: [
          TVButton.icon(
            icon: Icons.search,
            onPressed: () => openSearch(),
          ),
        ],
      ),
      body: TVFocusNavigation(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
            childAspectRatio: 16/9,
          ),
          itemBuilder: (context, index) => TVChatCard(
            chat: chats[index],
            onSelected: () => openChat(chats[index]),
          ),
        ),
      ),
    );
  }
}

class TVChatCard extends StatelessWidget {
  final Chat chat;
  final VoidCallback onSelected;

  const TVChatCard({
    Key? key,
    required this.chat,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FocusableActionDetector(
        onFocusChange: (focused) {
          if (focused) {
            // Handle focus gained
            setState(() {
              // Highlight card
            });
          }
        },
        child: GestureDetector(
          onTap: onSelected,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chat.avatarUrl),
                  radius: 40,
                ),
                SizedBox(height: 12),
                Text(
                  chat.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  chat.lastMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Media Playback

### TV Video Player
```swift
// tvos/Runner/VideoPlayer.swift
import AVKit
import Flutter

class TVVideoPlayer: NSObject, FlutterPlatformView {
  private var player: AVPlayer?
  private var playerLayer: AVPlayerLayer?
  private var view: UIView!

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) {
    super.init()
    view = UIView(frame: frame)

    // Initialize video player for TV
    setupVideoPlayer()
  }

  private func setupVideoPlayer() {
    // Set up AVPlayer for tvOS
    player = AVPlayer()
    playerLayer = AVPlayerLayer(player: player)
    playerLayer?.frame = view.bounds
    playerLayer?.videoGravity = .resizeAspect

    view.layer.addSublayer(playerLayer!)

    // Configure for TV playback
    configureTVPlayback()
  }

  private func configureTVPlayback() {
    // Enable TV-specific playback features
    player?.allowsExternalPlayback = true
    player?.usesExternalPlaybackWhileExternalScreenIsActive = true

    // Set up remote control
    setupRemoteControl()
  }

  private func setupRemoteControl() {
    let remoteCommandCenter = MPRemoteCommandCenter.shared()

    remoteCommandCenter.playCommand.addTarget { [weak self] event in
      self?.player?.play()
      return .success
    }

    remoteCommandCenter.pauseCommand.addTarget { [weak self] event in
      self?.player?.pause()
      return .success
    }

    remoteCommandCenter.skipForwardCommand.addTarget { [weak self] event in
      let time = self?.player?.currentTime() ?? CMTime.zero
      self?.player?.seek(to: time + CMTime(seconds: 15, preferredTimescale: 1))
      return .success
    }

    remoteCommandCenter.skipBackwardCommand.addTarget { [weak self] event in
      let time = self?.player?.currentTime() ?? CMTime.zero
      self?.player?.seek(to: time - CMTime(seconds: 15, preferredTimescale: 1))
      return .success
    }
  }

  func view() -> UIView {
    return view
  }
}
```

## Testing

### tvOS Testing Framework
```swift
// tvos/Runner/TVOSTests.swift
import XCTest
import TVUIKit

class TVOSTests: XCTestCase {

  func testTVInterfaceConfiguration() {
    // Test TV interface setup
    let appDelegate = AppDelegate()
    let application = UIApplication.shared

    // Verify TV-specific configuration
    XCTAssertTrue(application.keyWindow?.traitCollection.userInterfaceIdiom == .tv)
  }

  func testRemoteControlSetup() {
    // Test remote control configuration
    let remoteCommandCenter = MPRemoteCommandCenter.shared()

    XCTAssertTrue(remoteCommandCenter.playCommand.isEnabled)
    XCTAssertTrue(remoteCommandCenter.pauseCommand.isEnabled)
  }

  func testFocusNavigation() {
    // Test focus-based navigation
    let viewController = TVViewController()
    let focusGuide = TVFocusGuide()

    // Verify focus system is properly configured
    XCTAssertNotNil(focusGuide)
  }
}
```

## Distribution

### Apple TV App Store
```bash
# Build for Apple TV App Store
flutter build ios --release --flavor tvos --export-method app-store

# Validate with Apple
xcrun altool --validate-app -f build/ios/iphoneos/Runner.app -t tvOS -u your-apple-id

# Upload to Apple TV App Store
xcrun altool --upload-app -f build/ios/iphoneos/Runner.app -t tvOS -u your-apple-id
```

### TestFlight for tvOS
```bash
# Upload to TestFlight for tvOS testing
xcrun altool --upload-app -f build/ios/iphoneos/Runner.app -t tvOS -u your-apple-id --type=ios
```

## Performance Optimization

### tvOS Performance
```dart
// lib/platforms/tvos/performance_service.dart
class TVOSPerformanceService {
  static void enableTVOptimizations() {
    // Enable TV-specific optimizations
    // Configure for 4K rendering
    // Optimize memory usage for large screens
    // Enable hardware-accelerated decoding
  }

  static void configureRemoteNavigation() {
    // Optimize for remote control navigation
    // Enable focus prediction
    // Configure directional navigation
  }

  static void setupMediaPlayback() {
    // Optimize for TV media playback
    // Enable HDR support
    // Configure audio output
  }
}
```

## Support

### tvOS Developer Support
- **Apple TV Developer Documentation**: https://developer.apple.com/tvos/
- **tvOS Design Guidelines**: https://developer.apple.com/design/human-interface-guidelines/tvos/
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/

## Resources

- [tvOS Developer Documentation](https://developer.apple.com/tvos/)
- [TVUIKit Framework](https://developer.apple.com/documentation/tvUIKit/)
- [TVMLKit Framework](https://developer.apple.com/documentation/tvmlkit/)
- [Apple TV App Store](https://developer.apple.com/app-store/tv-app-store/)
