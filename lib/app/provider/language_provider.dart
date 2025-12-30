import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode;

  LanguageProvider(this._languageCode);

  String get languageCode => _languageCode;

  void setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _languageCode);
  }
}
