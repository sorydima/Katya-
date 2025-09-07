#!/bin/bash
# Build script for Katya Flutter app

echo "Starting build process..."

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

echo "Building APK..."
flutter build apk --release

echo "Building iOS app..."
flutter build ios --release --no-codesign

echo "Build process completed."
