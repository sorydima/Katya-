# Release Process Guide

This guide covers the release process for Katya, including versioning, building release artifacts, publishing to various platforms, and managing the release lifecycle.

## Table of Contents
- [Release Strategy](#release-strategy)
- [Versioning](#versioning)
- [Pre-Release Checklist](#pre-release-checklist)
- [Building Release Artifacts](#building-release-artifacts)
- [Publishing to Platforms](#publishing-to-platforms)
- [Release Notes](#release-notes)
- [Post-Release Activities](#post-release-activities)
- [Automated Releases](#automated-releases)
- [Troubleshooting](#troubleshooting)

## Release Strategy

### Release Types
- **Major releases (X.0.0)**: Breaking changes, new features
- **Minor releases (0.X.0)**: New features, backward compatible
- **Patch releases (0.0.X)**: Bug fixes, security patches
- **Pre-releases**: Alpha, beta, release candidates

### Release Cadence
- Major releases: Every 6-12 months
- Minor releases: Every 1-3 months
- Patch releases: As needed (weekly/bi-weekly)
- Pre-releases: Before major/minor releases

## Versioning

### Semantic Versioning
Katya follows [Semantic Versioning 2.0.0](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: Backward compatible functionality
- **PATCH**: Backward compatible bug fixes

### Version Management
Update version in `pubspec.yaml`:
```yaml
version: 1.2.3+2023090701
```
- Format: `major.minor.patch+build`
- Build number: YYYYMMDDNN (date + sequence)

### Git Tagging
```bash
# Create annotated tag
git tag -a v1.2.3 -m "Release version 1.2.3"

# Push tags to remote
git push --tags
```

## Pre-Release Checklist

### Code Quality
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] No TODOs in release code
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

### Functionality
- [ ] Core features tested
- [ ] Edge cases handled
- [ ] Performance benchmarks met
- [ ] Security review completed

### Platform Specific
- [ ] Android: API compatibility verified
- [ ] iOS: App Store guidelines met
- [ ] Web: Cross-browser testing done
- [ ] Desktop: Platform testing completed

## Building Release Artifacts

### Android Releases
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release

# Build with specific flavor
flutter build apk --release --flavor production
```

### iOS Releases
```bash
# Build IPA
flutter build ipa --release

# Build for distribution
flutter build ipa --release --export-options-plist=ExportOptions.plist
```

### Web Releases
```bash
# Build web version
flutter build web --release

# Build with base href
flutter build web --release --base-href="/katya/"
```

### Desktop Releases
```bash
# Build for Windows
flutter build windows --release

# Build for macOS
flutter build macos --release

# Build for Linux
flutter build linux --release
```

## Publishing to Platforms

### Google Play Store
1. Build App Bundle: `flutter build appbundle --release`
2. Login to [Google Play Console](https://play.google.com/console)
3. Create new release
4. Upload `app-release.aab`
5. Fill release notes
6. Review and publish

### Apple App Store
1. Build IPA: `flutter build ipa --release`
2. Use Xcode Organizer or Transporter
3. Upload to App Store Connect
4. Submit for review
5. Release when approved

### Web Deployment
```bash
# Build and deploy to Netlify
npm install -g netlify-cli
netlify deploy --prod --dir=build/web

# Or deploy to Firebase
npm install -g firebase-tools
firebase deploy
```

### Desktop Distribution
- **Windows**: Create installer with Inno Setup or NSIS
- **macOS**: Create DMG package
- **Linux**: Create Snap, AppImage, or DEB package

## Release Notes

### CHANGELOG.md Format
```markdown
## [1.2.3] - 2023-09-07

### Added
- New feature description

### Changed
- Updated functionality

### Fixed
- Bug fixes

### Removed
- Deprecated features
```

### Generating Release Notes
```bash
# Generate from git commits
git log --oneline --since="2023-08-01" --until="2023-09-07"

# Or use conventional commits format
# feat: new feature
# fix: bug fix
# docs: documentation
# chore: maintenance
```

### Platform-Specific Notes
- **Google Play**: 500 characters max, markdown supported
- **App Store**: Localized release notes
- **Web**: Update README and documentation

## Post-Release Activities

### Monitoring
- [ ] Monitor crash reports
- [ ] Track performance metrics
- [ ] Watch user feedback
- [ ] Check store reviews

### Hotfix Process
1. Create hotfix branch from release tag
2. Apply fix
3. Test thoroughly
4. Release patch version
5. Merge back to main

### Version Bumping
After release, update to next development version:
```yaml
# pubspec.yaml
version: 1.2.4-dev.1+2023090801
```

## Automated Releases

### GitHub Actions Workflow
Create `.github/workflows/release.yml`:
```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Release Automation Tools
- **fastlane**: Automate Android and iOS deployments
- **github-release**: Create GitHub releases automatically
- **release-it**: Automated version management

### Continuous Deployment
```yaml
# Example for web deployment
- name: Deploy to Netlify
  run: |
    npm install -g netlify-cli
    netlify deploy --prod --dir=build/web
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## Troubleshooting

### Common Release Issues

**Build Failures:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

**Code Signing Issues:**
- Check certificates and provisioning profiles
- Verify signing configurations in Xcode/Android Studio

**App Store Rejection:**
- Review App Store guidelines
- Check privacy permissions
- Ensure proper metadata

**Performance Regressions:**
- Use `--profile` build for performance testing
- Monitor with DevTools and analytics

### Rollback Procedures

**Android:**
- Use Google Play Console rollback feature
- Deploy previous version

**iOS:**
- Submit update through App Store Connect
- Communicate with users if needed

**Web:**
- Redeploy previous build version
- Use CDN versioning if available

## Security Considerations

- [ ] Validate all dependencies
- [ ] Check for known vulnerabilities
- [ ] Review access controls
- [ ] Audit third-party services

## Legal Compliance

- [ ] Privacy policy updated
- [ ] Terms of service current
- [ ] Data processing agreements
- [ ] Regional compliance (GDPR, CCPA, etc.)

## Support Resources

- [Release Documentation](docs/DEPLOYMENT.md)
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment)
- [Google Play Help](https://support.google.com/googleplay/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Changelog

For release history and changes, see [CHANGELOG.md](CHANGELOG.md).

---

*Last updated: September 2023*  
*For the latest release information, check the [GitHub Releases](https://github.com/sorydima/Katya-/releases)*