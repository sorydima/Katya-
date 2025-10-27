# Tizen Platform Documentation

This directory contains platform-specific documentation for Tizen OS builds and deployments.

## Overview
Tizen is a Samsung-led open-source operating system based on Linux, primarily used for Samsung smart devices including smart TVs, wearables, and mobile devices.

## Build Instructions

### Requirements
- Tizen Studio 4.0 or higher
- Flutter SDK with Tizen support enabled (`flutter config --enable-tizen`)
- Tizen device or emulator

### Development Setup
1. Enable Tizen support: `flutter config --enable-tizen`
2. Install Tizen Studio and set up device emulators
3. Run `flutter pub get` in project directory

### Build Commands
- Debug build: `flutter run -d tizen`
- Release build: `flutter build tizen --release`
- Profile build: `flutter build tizen --profile`

### Build Outputs
- Tizen wearable: `.tpk` package
- Tizen mobile: `.tpk` package
- Tizen TV: `.tpk` package

## Platform-Specific Features

### Permissions
Add Tizen-specific permissions in `tizen/tizen-manifest.xml`:
```xml
<permissions>
  <permission name="http://tizen.org/privilege/internet"/>
  <permission name="http://tizen.org/privilege/network.get"/>
</permissions>
```

### Native Extensions
- Use Tizen Native API for platform-specific features
- Implement custom plugins for Tizen-exclusive functionality

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Device Testing
- Use Tizen Emulator for testing
- Physical device testing via USB debugging

## Deployment

### Samsung Galaxy Store
1. Create Samsung account
2. Package app using `flutter build tizen --release`
3. Upload `.tpk` file to Galaxy Store Developer Console
4. Submit for review

### Distribution
- Direct APK/TPK distribution
- Enterprise distribution for business apps

## Known Issues and Limitations

### Performance
- Graphics performance may vary on older Tizen devices
- Memory management differs from standard Flutter targets

### API Compatibility
- Some Flutter plugins may not support Tizen
- Custom platform channels required for Tizen-specific features

### Device Fragmentation
- Various Tizen versions across different device types
- Ensure compatibility testing across target devices

## Resources

- [Tizen Developer Documentation](https://docs.tizen.org/)
- [Flutter Tizen Plugin](https://github.com/flutter-tizen/plugins)
- [Samsung Developers](https://developer.samsung.com/)

## Troubleshooting

### Common Issues
1. **Build fails with missing Tizen SDK**: Ensure Tizen Studio is properly installed and configured
2. **Device not detected**: Check USB debugging is enabled on Tizen device
3. **Permission denied errors**: Add required permissions in manifest

### Debug Tips
- Use Tizen Studio's Device Manager for debugging
- Enable developer options on target devices
- Check device logs via `sdb dlog` command
