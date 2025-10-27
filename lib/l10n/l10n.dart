import 'package:flutter/material.dart';

/// App localizations class that provides access to localized strings
class AppLocalizations {
  const AppLocalizations();

  static AppLocalizations? of(BuildContext context) {
    return const AppLocalizations();
  }

  // Add any specific methods that are used in the codebase
  // For now, this is a minimal implementation
}

/// Temporary l10n wrapper for easy_localization
AppLocalizations l10nOf(BuildContext context) {
  return AppLocalizations.of(context) ?? const AppLocalizations();
}
