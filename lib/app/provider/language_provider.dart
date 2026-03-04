import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ChangeNotifier] provider that manages the app's active language/locale.
///
/// Persists the selected language code to [SharedPreferences] so the user's
/// preference survives app restarts.
///
/// Usage in the widget tree:
/// ```dart
/// context.read<LanguageProvider>().setLanguage('ar');
/// String current = context.watch<LanguageProvider>().languageCode; // e.g. 'ar' or 'en'
/// ```
///
/// Initialise with the language code loaded from [SharedPreferences] on app start.
class LanguageProvider extends ChangeNotifier {
  /// The currently active language code (e.g., 'en' for English, 'ar' for Arabic).
  String _languageCode;

  /// Creates the provider with the given initial [_languageCode].
  ///
  /// Pass the code previously saved in [SharedPreferences], or a sensible
  /// default (e.g., the device locale) on first launch.
  LanguageProvider(this._languageCode);

  /// The currently selected language code. Observed by widgets using [watch].
  String get languageCode => _languageCode;

  /// Changes the active language to [code] and persists the change.
  ///
  /// Notifies all listeners synchronously so the UI rebuilds immediately,
  /// then asynchronously saves the new code to [SharedPreferences].
  void setLanguage(String code) async {
    _languageCode = code;
    notifyListeners(); // Rebuild dependent widgets immediately

    // Persist the preference for the next app launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _languageCode);
  }
}
