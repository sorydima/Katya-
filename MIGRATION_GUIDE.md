# Migration Guide

This guide helps you migrate between versions of Katya.

## From Version 1.x to 2.x

### Breaking Changes
- Redux store structure has been updated. Run `flutter pub run build_runner build` to regenerate models.
- OLM library updated; recompile if necessary.

### Steps
1. Backup your data.
2. Update Flutter to the latest version.
3. Run `flutter pub get`.
4. Run `flutter pub run build_runner build --delete-conflicting-outputs`.
5. Rebuild the app.

## Data Migration
- User data is stored locally; no manual migration needed for most cases.
- For homeserver transfers, use the export/import features (planned for future release).

## Troubleshooting
If issues arise, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

For support, contact support@rechain.network.
