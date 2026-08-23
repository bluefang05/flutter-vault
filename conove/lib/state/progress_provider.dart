import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../core/services/storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress.initial();
  List<String> _bookmarks = [];

  UserProgress get progress => _progress;
  List<String> get bookmarks => _bookmarks;

  void loadProgress() {
    _progress = StorageService.loadProgress().registerActiveDay();
    _bookmarks = StorageService.getBookmarks();
    StorageService.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> markGestureExplored(String gestureId) async {
    _progress = _progress.markGestureExplored(gestureId);
    await StorageService.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> recordQuizResult(String quizId, int score) async {
    _progress = _progress.recordQuizResult(quizId, score);
    await StorageService.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> markScenarioCompleted(String scenarioId) async {
    _progress = _progress.markScenarioCompleted(scenarioId);
    await StorageService.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> toggleBookmark(String gestureId) async {
    await StorageService.toggleBookmark(gestureId);
    _bookmarks = StorageService.getBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String gestureId) {
    return _bookmarks.contains(gestureId);
  }
}
