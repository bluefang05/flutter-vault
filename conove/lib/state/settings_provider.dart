import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;

  SettingsProvider._internal() {
    loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;
  double _textScale = 1.0;
  bool _hapticsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _reduceMotion = false;
  bool _warmFilter = false;
  String? _languageCode; // null = follow system

  bool _autoNarration = false;
  double _speechRate = 0.48;

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  bool get isHighContrast => _highContrast;
  double get textScale => _textScale;
  double get fontScale => _textScale;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isHapticsEnabled => _hapticsEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get isSoundEffectsEnabled => _soundEffectsEnabled;
  bool get reduceMotion => _reduceMotion;
  bool get isReduceMotion => _reduceMotion;
  bool get warmFilter => _warmFilter;
  bool get isWarmFilter => _warmFilter;
  bool get autoNarration => _autoNarration;
  bool get isAutoNarration => _autoNarration;
  double get speechRate => _speechRate;
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode != null ? Locale(_languageCode!) : null;

  void loadSettings() {
    final modeStr = StorageService.getThemeMode();
    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    _highContrast = StorageService.getHighContrast();
    _textScale = StorageService.getTextScale();
    _hapticsEnabled = StorageService.getHapticsEnabled();
    _soundEffectsEnabled = StorageService.getSoundEffectsEnabled();
    _reduceMotion = StorageService.getReduceMotion();
    _warmFilter = StorageService.getWarmFilter();
    _autoNarration = StorageService.getAutoNarration();
    _speechRate = StorageService.getSpeechRate();
    _languageCode = StorageService.getLanguage();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String str = 'system';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    await StorageService.setThemeMode(str);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    await StorageService.setHighContrast(value);
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale;
    await StorageService.setTextScale(scale);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) => setTextScale(scale);

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    await StorageService.setHapticsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    await StorageService.setSoundEffectsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    await StorageService.setReduceMotion(value);
    notifyListeners();
  }

  Future<void> setWarmFilter(bool value) async {
    _warmFilter = value;
    await StorageService.setWarmFilter(value);
    notifyListeners();
  }

  Future<void> setAutoNarration(bool value) async {
    _autoNarration = value;
    await StorageService.setAutoNarration(value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await StorageService.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setLanguageCode(String? code) async {
    _languageCode = code;
    await StorageService.setLanguage(code);
    notifyListeners();
  }
}

