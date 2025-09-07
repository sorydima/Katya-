# Troubleshooting

This document provides solutions to common issues encountered while building, running, or using Katya.

## Build Issues

### Flutter Build Fails
- Ensure you have the latest stable Flutter version installed.
- Run `flutter doctor` to check for any missing dependencies.
- Clear Flutter cache: `flutter clean && flutter pub get`.

### OLM/MegOLM Setup Errors
- For macOS: Ensure libolm is installed via Homebrew and dylib is linked correctly.
- For Linux: Install libolm3 and libsqlite3-dev.
- For Windows: Compile OLM and place olm.dll as libolm.dll in the executable directory.

### Submodule Issues
- Run `git submodule update --init --recursive` to initialize submodules.

## Runtime Issues

### App Crashes on Startup
- Check device logs for errors.
- Ensure all permissions are granted (e.g., notifications, storage).
- Verify E2EE keys are properly generated.

### Matrix Bridge Connection Problems
- Check bridge configuration files in `bridges/` folder.
- Ensure homeserver is reachable and credentials are correct.
- Refer to Matrix documentation for bridge setup.

## Common Errors

### "No such file or directory" for assets
- Run `flutter pub get` to fetch dependencies.
- Check if assets are properly declared in `pubspec.yaml`.

### Notification Issues
- For iOS: Ensure APNS is configured.
- For Android: Check if background services are allowed.

## Getting Help
- Check existing issues on GitHub.
- Join our community chat for support.
- Email: support@rechain.network

For more detailed logs, run the app with `--verbose` flag if available.
