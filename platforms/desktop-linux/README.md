# Desktop Linux Variants Configuration
# Advanced Linux distributions for desktop environments

## Supported Distributions
- Ubuntu 20.04 LTS / 22.04 LTS
- Fedora 35 / 36
- Debian 11 / 12
- Arch Linux
- openSUSE Tumbleweed / Leap
- CentOS 8 / 9
- RHEL 8 / 9
- Linux Mint 20 / 21

## Build Configuration
```yaml
name: Desktop Linux Build
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-linux:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        distro: [ubuntu-20.04, ubuntu-22.04, fedora-36, debian-11]

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
        architecture: x64

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

    - name: Configure for Linux
      run: |
        flutter config --enable-linux-desktop
        flutter doctor

    - name: Build for ${{ matrix.distro }}
      run: |
        flutter build linux --release
        tar -czf katya-linux-${{ matrix.distro }}.tar.gz -C build/linux/x64/release/bundle .

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: katya-linux-${{ matrix.distro }}
        path: katya-linux-${{ matrix.distro }}.tar.gz

  test-linux:
    runs-on: ubuntu-latest
    needs: build-linux

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2

    - name: Run tests
      run: |
        flutter pub get
        flutter test

    - name: Analyze code
      run: flutter analyze
```

## Platform-Specific Features
- **System Integration**: Native file managers, system tray, notifications
- **Desktop Environments**: KDE, GNOME, XFCE, Cinnamon, MATE
- **Package Managers**: APT, DNF, Pacman, Zypper
- **Security**: AppArmor, SELinux, Firejail compatibility

## Distribution-Specific Optimizations
- **Ubuntu/Debian**: APT packaging, Unity/GNOME integration
- **Fedora**: RPM packaging, Wayland support
- **Arch**: AUR packaging, rolling release compatibility
- **RHEL/CentOS**: Enterprise security policies, certified builds
