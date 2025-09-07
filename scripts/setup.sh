#!/bin/bash
# Setup script for Katya development environment

echo "Setting up Katya development environment..."

# Install Flutter dependencies
flutter pub get

# Initialize submodules
git submodule update --init --recursive

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Install platform-specific dependencies
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install libolm
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install libolm3 libsqlite3-dev
fi

echo "Setup completed. Run 'flutter run' to start the app."
