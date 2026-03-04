import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ChangeNotifier] provider that manages the app's dark/light theme mode.
///
/// Persists the user's theme preference to [SharedPreferences] so it survives
/// app restarts.
///
/// Usage in the widget tree:
/// ```dart
/// // Toggle the theme:
/// context.read<ThemeProvider>().toggleTheme();
///
/// // Observe the current mode:
/// bool dark = context.watch<ThemeProvider>().isDarkMode;
/// ```
///
/// Initialise with the value loaded from [SharedPreferences] on app start.
class ThemeProvider extends ChangeNotifier {
  /// Whether the app is currently in dark mode.
  bool _isDarkMode;

  /// Creates the provider with the given initial [_isDarkMode] value.
  ///
  /// Pass the persisted value from [SharedPreferences], or a default
  /// (e.g., matching the system brightness) on first launch.
  ThemeProvider(this._isDarkMode);

  /// True if the app is currently using dark mode. Observed by widgets using [watch].
  bool get isDarkMode => _isDarkMode;

  /// Toggles between dark and light mode and persists the new preference.
  ///
  /// Notifies all listeners synchronously so the theme switches immediately,
  /// then asynchronously saves the new value to [SharedPreferences].
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Rebuild the MaterialApp immediately with the new theme

    // Persist the preference for the next app launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}
