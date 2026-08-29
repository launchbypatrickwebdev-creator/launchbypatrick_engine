// lib/services/email_popup_service.dart

// import 'package:flutter/foundation.dart';

class EmailPopupService {
  static final EmailPopupService _instance = EmailPopupService._internal();

  factory EmailPopupService() {
    return _instance;
  }

  EmailPopupService._internal();

  // Track which pages have shown their popup in this session
  final Set<String> _shownPopups = {};

  /// Check if popup should be shown for this page type
  bool shouldShowPopup(String pageType) {
    return !_shownPopups.contains(pageType);
  }

  /// Mark popup as shown for this page type
  void markPopupShown(String pageType) {
    _shownPopups.add(pageType);
  }

  /// Reset all popups (useful for testing or logout)
  void resetAllPopups() {
    _shownPopups.clear();
  }
}