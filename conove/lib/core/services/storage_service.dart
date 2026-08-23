import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/user_progress.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService must be initialized before use.');
    }
    return _prefs!;
  }

  // Theme & Accessibility
  static String getThemeMode() {
    return prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  static Future<bool> setThemeMode(String mode) {
    return prefs.setString(AppConstants.keyThemeMode, mode);
  }

  static bool getHighContrast() {
    return prefs.getBool(AppConstants.keyHighContrast) ?? false;
  }

  static Future<bool> setHighContrast(bool value) {
    return prefs.setBool(AppConstants.keyHighContrast, value);
  }

  static double getTextScale() {
    return prefs.getDouble(AppConstants.keyTextScale) ?? 1.0;
  }

  static Future<bool> setTextScale(double scale) {
    return prefs.setDouble(AppConstants.keyTextScale, scale);
  }

  static bool getHapticsEnabled() {
    return prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
  }

  static Future<bool> setHapticsEnabled(bool enabled) {
    return prefs.setBool(AppConstants.keyHapticsEnabled, enabled);
  }

  static bool getReduceMotion() {
    return prefs.getBool('conove_reduce_motion') ?? false;
  }

  static Future<bool> setReduceMotion(bool value) {
    return prefs.setBool('conove_reduce_motion', value);
  }

  static bool getWarmFilter() {
    return prefs.getBool('conove_warm_filter') ?? false;
  }

  static Future<bool> setWarmFilter(bool value) {
    return prefs.setBool('conove_warm_filter', value);
  }

  // Bookmarks (Gestures saved by user)
  static List<String> getBookmarks() {
    return prefs.getStringList(AppConstants.keyBookmarks) ?? [];
  }

  static Future<bool> toggleBookmark(String gestureId) async {
    final list = getBookmarks().toList();
    if (list.contains(gestureId)) {
      list.remove(gestureId);
    } else {
      list.add(gestureId);
    }
    return prefs.setStringList(AppConstants.keyBookmarks, list);
  }

  static bool isBookmarked(String gestureId) {
    return getBookmarks().contains(gestureId);
  }

  // Progress & Stats
  static UserProgress loadProgress() {
    final raw = prefs.getString(AppConstants.keyUserProgress);
    if (raw == null || raw.isEmpty) {
      return UserProgress.initial();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (_) {
      return UserProgress.initial();
    }
  }

  static Future<bool> saveProgress(UserProgress progress) {
    final raw = jsonEncode(progress.toJson());
    return prefs.setString(AppConstants.keyUserProgress, raw);
  }

  static Future<bool> clearAll() {
    return prefs.clear();
  }
}

