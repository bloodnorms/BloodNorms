// ============================================================================
// BloodNorms | admin_navigation_mixin.dart
// Admin Console Navigation & Sidebar Expansions State Mixin
// ============================================================================

import 'package:flutter/material.dart';

mixin AdminNavigationMixin on ChangeNotifier {
  String _activePage = 'dashboard';
  bool _isSidebarCompact = false;
  final Set<String> _expandedCategories = {
    'broadcast',
    'voice',
    'whatsapp',
    'camps',
    'banks',
    'donors',
    'shield',
    'governance',
    'settings',
  };

  String get activePage => _activePage;
  bool get isSidebarCompact => _isSidebarCompact;
  Set<String> get expandedCategories => _expandedCategories;

  void setActivePage(String page) {
    _activePage = page;
    notifyListeners();
  }

  void toggleSidebarCompact() {
    _isSidebarCompact = !_isSidebarCompact;
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (_expandedCategories.contains(cat)) {
      _expandedCategories.remove(cat);
    } else {
      _expandedCategories.add(cat);
    }
    notifyListeners();
  }
}
