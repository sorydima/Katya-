# Windows UWP Platform Support

This directory contains the build configuration and code for Windows Universal Windows Platform (UWP) support for Katya.

## Build Instructions

1. Ensure Flutter is configured for Windows UWP:
   ```
   flutter config --enable-windows-uwp-desktop
   ```

2. Build the application:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter build winuwp --release
   ```

## Code Structure

- `CMakeLists.txt`: CMake build configuration for UWP.
- `main.cpp`: Main entry point for the UWP application.
- `runner/`: Contains runner-specific code (to be added if needed).

## Setup

- Install Visual Studio with UWP development tools.
- Ensure Windows SDK is installed.
- Run `flutter precache --winuwp` to cache necessary binaries.

## Documentation

For more details on Flutter UWP support, refer to the official Flutter documentation.
