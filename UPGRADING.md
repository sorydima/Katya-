# Upgrade Guide

This guide provides instructions for upgrading Katya between different versions, including breaking changes, migration steps, and best practices.

## Table of Contents
- [Version Compatibility](#version-compatibility)
- [Upgrade Process](#upgrade-process)
- [Breaking Changes](#breaking-changes)
- [Migration Guides](#migration-guides)
- [Troubleshooting Upgrades](#troubleshooting-upgrades)
- [Rollback Procedures](#rollback-procedures)

## Version Compatibility

### Supported Upgrade Paths
- **From 1.x → 2.0**: Requires migration steps
- **From 2.x → 3.0**: Requires migration steps
- **Patch versions (x.y.z → x.y.z+1)**: Usually backward compatible

### Flutter Version Requirements
- **Katya 1.x**: Flutter 2.0 - 2.10
- **Katya 2.x**: Flutter 3.0 - 3.3
- **Katya 3.x**: Flutter 3.7+

## Upgrade Process

### Standard Upgrade Procedure

1. **Backup Your Project**
   ```bash
   git commit -am "Backup before upgrade"
   git tag pre-upgrade-backup
   ```

2. **Update Flutter SDK**
   ```bash
   flutter upgrade
   ```

3. **Update Dependencies**
   ```bash
   flutter pub upgrade
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

5. **Check for Breaking Changes**
   ```bash
   flutter analyze
   flutter run --debug
   ```

### Automated Upgrade Script

Create `upgrade.sh`:
```bash
#!/bin/bash
echo "Starting Katya upgrade process..."

# Backup current state
git add .
git commit -m "Pre-upgrade backup $(date)"

# Upgrade Flutter
flutter upgrade

# Upgrade dependencies
flutter pub upgrade

# Run analysis
flutter analyze

# Run tests
flutter test

echo "Upgrade completed successfully!"
```

## Breaking Changes

### Version 3.0.0

**Null Safety Migration:**
- All code now uses null safety
- Required migration from non-nullable to nullable types

**API Changes:**
- Removed deprecated API endpoints
- Changed response format for user data
- Updated authentication flow

**Dependency Updates:**
- Upgraded to Flutter 3.0
- Updated all packages to null-safe versions

### Version 2.0.0

**State Management:**
- Migrated from Provider to Riverpod
- Changed state management patterns

**File Structure:**
- Reorganized feature-based architecture
- Updated import paths

**Configuration:**
- Changed environment variable handling
- Updated build configuration

## Migration Guides

### Migrating from 2.x to 3.0

**Step 1: Update Flutter SDK**
```bash
flutter upgrade
```

**Step 2: Update Dependencies**
```bash
flutter pub upgrade
```

**Step 3: Fix Null Safety Issues**
```dart
// Before
String name;

// After
String? name;
```

**Step 4: Update API Calls**
```dart
// Before
final response = await http.get('/api/users/1');

// After
final response = await http.get(Uri.parse('$baseUrl/api/users/1'));
```

### Migrating from 1.x to 2.0

**Step 1: Update Package References**
```yaml
# Before
dependencies:
  provider: ^5.0.0

# After
dependencies:
  riverpod: ^1.0.0
```

**Step 2: Migrate State Management**
```dart
// Before - Provider
final user = Provider.of<User>(context);

// After - Riverpod
final user = ref.watch(userProvider);
```

**Step 3: Update File Structure**
```bash
# Reorganize files according to new structure
mv lib/screens/ lib/features/
mv lib/models/ lib/core/models/
```

## Version-Specific Upgrade Notes

### Upgrading to 3.1.0
- Added web socket support
- Updated authentication tokens
- Improved error handling

### Upgrading to 2.2.0
- Added desktop support
- Updated platform-specific code
- Enhanced file picker integration

### Upgrading to 1.5.0
- Added internationalization
- Updated localization files
- Changed date formatting

## Dependency Upgrade Matrix

| Package | From Version | To Version | Changes |
|---------|-------------|------------|---------|
| http | ^0.13.0 | ^0.13.4 | Security patches |
| provider | ^6.0.0 | N/A | Replaced with Riverpod |
| riverpod | N/A | ^1.0.0 | New state management |
| flutter_dotenv | ^5.0.0 | ^5.0.2 | Bug fixes |

## Configuration Changes

### Environment Variables
```bash
# Before
API_URL=https://api.katya.com

# After
API_BASE_URL=https://api.katya.app
APP_ENV=production
```

### Build Configuration
```gradle
// Before
compileSdkVersion 30

// After
compileSdkVersion 33
```

## Database Migrations

### Schema Changes
```sql
-- Version 3.0
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;

-- Version 2.0
CREATE TABLE user_sessions (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    token TEXT,
    expires_at TIMESTAMP
);
```

### Migration Scripts
Create database migration scripts for each version:
```bash
# Run migrations
flutter pub run migration_runner
```

## Testing After Upgrade

### Comprehensive Test Suite
```bash
# Run all tests
flutter test

# Test specific platforms
flutter test -d chrome
flutter test -d android

# Performance testing
flutter run --profile
```

### Regression Testing Checklist
- [ ] User authentication
- [ ] Data persistence
- [ ] API communication
- [ ] UI rendering
- [ ] Performance metrics
- [ ] Error handling

## Troubleshooting Upgrades

### Common Upgrade Issues

**Dependency Conflicts:**
```bash
# Resolve conflicts
flutter pub downgrade conflicting_package
flutter pub upgrade --major-versions
```

**Build Failures:**
```bash
# Clean build
flutter clean
flutter pub get

# Check Flutter version
flutter --version
```

**Null Safety Errors:**
```bash
# Analyze null safety
dart migrate --apply-changes

# Or manually fix issues
# Add ? for nullable types
# Add ! for non-null assertion
```

### Platform-Specific Issues

**Android:**
- Update Gradle version
- Check Android SDK compatibility
- Update signing configurations

**iOS:**
- Update CocoaPods
- Check Xcode compatibility
- Update provisioning profiles

**Web:**
- Check CORS configuration
- Update service worker
- Verify asset loading

## Rollback Procedures

### Quick Rollback
```bash
# Revert to previous version
git reset --hard pre-upgrade-backup

# Or use specific commit
git reset --hard <commit-hash>
```

### Database Rollback
```sql
-- Revert schema changes
ALTER TABLE users DROP COLUMN last_login;
```

### Dependency Rollback
```bash
# Revert to specific package versions
flutter pub add package_name@previous_version
```

## Best Practices for Upgrades

### Pre-Upgrade Checklist
- [ ] Backup current version
- [ ] Read release notes
- [ ] Check breaking changes
- [ ] Test in staging environment
- [ ] Inform users about downtime

### Post-Upgrade Validation
- [ ] Verify all functionality
- [ ] Check performance metrics
- [ ] Test error scenarios
- [ ] Monitor for regressions

### Version Control Strategy
```bash
# Use feature branches for upgrades
git checkout -b upgrade/3.0.0

# Test thoroughly before merging
git checkout main
git merge upgrade/3.0.0
```

## Support

If you encounter issues during upgrade:

1. Check the [CHANGELOG.md](CHANGELOG.md) for specific version notes
2. Review [existing issues](https://github.com/sorydima/Katya-/issues) for similar problems
3. Ask in [discussions](https://github.com/sorydima/Katya-/discussions) for help
4. Create a [bug report](.github/ISSUE_TEMPLATE/bug_report.md) if needed

## Changelog

For detailed changes in each version, see [CHANGELOG.md](CHANGELOG.md).

---

*Last updated: September 2023*  
*Always test upgrades in a staging environment before production deployment*