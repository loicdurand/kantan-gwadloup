import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsProvider extends ChangeNotifier {
  bool _termsAccepted = false;

  bool get termsAccepted => _termsAccepted;

  TermsProvider() {
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final prefs = await SharedPreferences.getInstance();
    _termsAccepted = prefs.getBool('termsAccepted') ?? false;
    notifyListeners();
  }

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);
    _termsAccepted = true;
    notifyListeners();
  }

  Future<void> resetTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('termsAccepted');
    _termsAccepted = false;
    notifyListeners();
  }
}