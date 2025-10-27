# Linux Platform Configuration

## Target Platforms
- Ubuntu 20.04+ (Focal Fossa)
- Ubuntu 22.04+ (Jammy Jellyfish)
- Debian 11+ (Bullseye)
- Fedora 36+
- CentOS 8+
- Arch Linux
- openSUSE

## Development Requirements
- Flutter SDK 3.0+
- Linux Kernel 5.4+
- GCC 9+ / Clang 10+
- CMake 3.16+
- Ninja Build
- pkg-config
- libgtk-3-dev
- libx11-dev
- libxrandr-dev
- libasound2-dev
- libpangocairo-1.0-0
- libcairo-gobject2
- libgtk-3-0
- libgdk-pixbuf2.0-0

## Build Settings
- **Target Architecture**: x86_64, ARM64
- **Minimum GLIBC**: 2.17
- **Build Type**: Release, Debug, Profile
- **GTK Version**: 3.24+

## Desktop Integration
- **Desktop File**: /usr/share/applications/katya.desktop
- **AppData File**: /usr/share/metainfo/com.katya.app.metainfo.xml
- **Icon**: /usr/share/pixmaps/katya.png
- **Mime Types**: x-scheme-handler/katya

## System Integration
- **D-Bus Service**: com.katya.app.service
- **Portal Support**: XDG Desktop Portal
- **Keyring**: libsecret
- **Notifications**: libnotify
- **Media Keys**: MPRIS2
- **Clipboard**: Primary and Clipboard selection
- **Drag & Drop**: X11, Wayland

## Package Management
### Snap Package
```yaml
name: katya
version: 1.0.0
summary: Secure messaging platform
description: |
  Katya is a secure, decentralized messaging platform with blockchain integration.

grade: stable
confinement: strict
base: core20

apps:
  katya:
    command: katya
    desktop: share/applications/katya.desktop
    extensions: [gnome-3-38]

parts:
  katya:
    source: .
    plugin: flutter
    flutter-target: lib/main.dart
```

### Flatpak Package
```yaml
id: com.katya.app
runtime: org.freedesktop.Platform
runtime-version: '21.08'
sdk: org.freedesktop.Sdk
command: katya

finish-args:
  - --share=ipc
  - --socket=x11
  - --socket=wayland
  - --device=dri
  - --filesystem=xdg-run/pipewire:ro
  - --talk-name=org.freedesktop.Notifications
  - --talk-name=org.freedesktop.secrets

modules:
  - name: katya
    buildsystem: simple
    build-commands:
      - flutter build linux --release
      - install -Dm755 build/linux/x64/release/bundle/katya $FLATPAK_DEST/bin/katya
    sources:
      - type: git
        url: https://github.com/yourusername/katya.git
```

### DEB Package
```bash
# Build DEB package
flutter build linux --release
dpkg-deb --build katya
```

## Platform-Specific Features
- **Window Management**: Custom window decorations
- **System Tray**: Status icon and menu
- **Global Hotkeys**: Keyboard shortcuts
- **Auto-start**: Desktop session integration
- **Theme Integration**: Follow system theme
- **Font Configuration**: System font preferences
- **Input Methods**: IBus, Fcitx support
- **Accessibility**: Screen reader support
- **High DPI**: Automatic scaling
- **Multi-monitor**: Workspace awareness

## Build Commands
```bash
# Debug build
flutter build linux --debug

# Release build
flutter build linux --release

# Profile build
flutter build linux --profile

# Bundle for distribution
flutter build linux --release --bundle
```

## Dependencies
- **GTK+ 3.0**: Windowing and UI
- **X11/XCB**: Low-level window system
- **ALSA/PulseAudio**: Audio playback
- **libsecret**: Secure storage
- **libnotify**: Desktop notifications
- **libkeybinder**: Global hotkeys
- **libappindicator**: System tray

## Security
- **AppArmor Profile**: Confinement rules
- **SELinux Policy**: Access controls
- **Sandboxed Runtime**: Flatpak/Snap security
- **Secure Storage**: Encrypted keyring
- **Network Security**: TLS 1.3+ required

## Distribution
- **Flathub**: Universal Linux package
- **Snapcraft Store**: Canonical's package manager
- **Ubuntu Software**: Native DEB packages
- **Fedora Copr**: RPM packages
- **AUR**: Arch Linux packages
