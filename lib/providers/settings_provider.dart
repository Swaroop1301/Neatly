import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

/// Manages app settings: theme mode, accent color, preferences.
class SettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  int _accentColorIndex = 0;
  bool _autoSortOnUpload = true;
  bool _showAiSummary = true;
  bool _autoDeleteDuplicates = false;
  String _defaultSortOrder = 'date';
  bool _gridView = false;
  bool _isFirstLaunch = true;

  ThemeMode get themeMode => _themeMode;
  int get accentColorIndex => _accentColorIndex;
  Color get accentColor => AppColors.folderPaletteList[_accentColorIndex];
  bool get autoSortOnUpload => _autoSortOnUpload;
  bool get showAiSummary => _showAiSummary;
  bool get autoDeleteDuplicates => _autoDeleteDuplicates;
  String get defaultSortOrder => _defaultSortOrder;
  bool get gridView => _gridView;
  bool get isFirstLaunch => _isFirstLaunch;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _accentColorIndex = prefs.getInt('accentColorIndex') ?? 0;
    _autoSortOnUpload = prefs.getBool('autoSortOnUpload') ?? true;
    _showAiSummary = prefs.getBool('showAiSummary') ?? true;
    _autoDeleteDuplicates = prefs.getBool('autoDeleteDuplicates') ?? false;
    _defaultSortOrder = prefs.getString('defaultSortOrder') ?? 'date';
    _gridView = prefs.getBool('gridView') ?? false;
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColorIndex', index);
  }

  Future<void> setAutoSortOnUpload(bool value) async {
    _autoSortOnUpload = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSortOnUpload', value);
  }

  Future<void> setShowAiSummary(bool value) async {
    _showAiSummary = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAiSummary', value);
  }

  Future<void> setAutoDeleteDuplicates(bool value) async {
    _autoDeleteDuplicates = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoDeleteDuplicates', value);
  }

  Future<void> setDefaultSortOrder(String value) async {
    _defaultSortOrder = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultSortOrder', value);
  }

  Future<void> setGridView(bool value) async {
    _gridView = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gridView', value);
  }

  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }
}

final settingsProvider = ChangeNotifierProvider<SettingsNotifier>((ref) {
  final notifier = SettingsNotifier();
  notifier.init();
  return notifier;
});
