#!/bin/bash
# Deploy script for Katya

echo "Starting deployment..."

# Build release versions
flutter build apk --release
flutter build ios --release --no-codesign

# Upload to stores (placeholder)
echo "Upload APK to Google Play..."
# Add upload commands here

echo "Upload IPA to App Store..."
# Add upload commands here

echo "Deployment completed."
