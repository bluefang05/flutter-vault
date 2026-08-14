import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReadingPosition {
  const ReadingPosition({
    required this.storyId,
    required this.pageId,
    required this.pageIndex,
    required this.offsetWithinPage,
  });

  final String storyId;
  final String pageId;
  final int pageIndex;
  final double offsetWithinPage;

  static ReadingPosition start(String storyId, {String? firstPageId}) {
    return ReadingPosition(
      storyId: storyId,
      pageId: firstPageId ?? '',
      pageIndex: 0,
      offsetWithinPage: 0,
    );
  }

  factory ReadingPosition.fromMap(Map<String, dynamic> map) {
    return ReadingPosition(
      storyId: map['storyId'] as String,
      pageId: map['pageId'] as String? ?? '',
      pageIndex: (map['pageIndex'] as num? ?? 0).toInt().clamp(0, 1 << 30),
      offsetWithinPage: (map['offsetWithinPage'] as num? ?? 0)
          .toDouble()
          .clamp(0.0, 1.0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'storyId': storyId,
      'pageId': pageId,
      'pageIndex': pageIndex,
      'offsetWithinPage': offsetWithinPage.clamp(0.0, 1.0),
    };
  }

  double overallProgress(int pageCount) {
    if (pageCount <= 0) return 0;
    final page = pageIndex.clamp(0, pageCount - 1);
    return ((page + offsetWithinPage.clamp(0.0, 1.0)) / pageCount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool isCompleted(int pageCount) {
    if (pageCount <= 0) return false;
    return pageIndex >= pageCount - 1 && offsetWithinPage >= 0.9;
  }
}

class ProgressStore {
  const ProgressStore._();

  static String _positionKey(String storyId) => 'story_${storyId}_position_v2';
  static String _legacyProgressKey(String storyId) =>
      'story_${storyId}_progress';
  static String _completedKey(String storyId) => 'story_${storyId}_completed';

  static Future<ReadingPosition> loadPosition(
    String storyId, {
    required List<String> pageIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_positionKey(storyId));
    if (raw != null) {
      try {
        return _normalizePosition(
          ReadingPosition.fromMap(jsonDecode(raw) as Map<String, dynamic>),
          storyId: storyId,
          pageIds: pageIds,
        );
      } catch (_) {
        await prefs.remove(_positionKey(storyId));
      }
    }

    final legacy = prefs.getDouble(_legacyProgressKey(storyId));
    if (legacy != null) {
      final migrated = migrateLegacyProgress(
        storyId: storyId,
        pageIds: pageIds,
        legacyProgress: legacy,
      );
      await savePosition(migrated, pageCount: pageIds.length);
      return migrated;
    }

    return ReadingPosition.start(
      storyId,
      firstPageId: pageIds.isEmpty ? null : pageIds.first,
    );
  }

  static ReadingPosition migrateLegacyProgress({
    required String storyId,
    required List<String> pageIds,
    required double legacyProgress,
  }) {
    if (pageIds.isEmpty) return ReadingPosition.start(storyId);
    final scaled = legacyProgress.clamp(0.0, 1.0) * pageIds.length;
    final pageIndex = scaled.floor().clamp(0, pageIds.length - 1);
    final offset = (scaled - pageIndex).clamp(0.0, 1.0).toDouble();
    return ReadingPosition(
      storyId: storyId,
      pageId: pageIds[pageIndex],
      pageIndex: pageIndex,
      offsetWithinPage: offset,
    );
  }

  static Future<bool> isCompleted(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey(storyId)) ?? false;
  }

  static Future<void> savePosition(
    ReadingPosition position, {
    required int pageCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = ReadingPosition(
      storyId: position.storyId,
      pageId: position.pageId,
      pageIndex:
          position.pageIndex.clamp(0, pageCount <= 0 ? 0 : pageCount - 1),
      offsetWithinPage: position.offsetWithinPage.clamp(0.0, 1.0).toDouble(),
    );
    await prefs.setString(
        _positionKey(position.storyId), jsonEncode(normalized.toMap()));
    await prefs.setDouble(
      _legacyProgressKey(position.storyId),
      normalized.overallProgress(pageCount),
    );
    if (normalized.isCompleted(pageCount)) {
      await prefs.setBool(_completedKey(position.storyId), true);
    }
  }

  static Future<void> reset(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_positionKey(storyId));
    await prefs.remove(_legacyProgressKey(storyId));
    await prefs.remove(_completedKey(storyId));
  }

  static ReadingPosition _normalizePosition(
    ReadingPosition position, {
    required String storyId,
    required List<String> pageIds,
  }) {
    if (pageIds.isEmpty) return ReadingPosition.start(storyId);

    final idIndex = pageIds.indexOf(position.pageId);
    final pageIndex = idIndex >= 0
        ? idIndex
        : position.pageIndex.clamp(0, pageIds.length - 1);
    return ReadingPosition(
      storyId: storyId,
      pageId: pageIds[pageIndex],
      pageIndex: pageIndex,
      offsetWithinPage: position.offsetWithinPage.clamp(0.0, 1.0).toDouble(),
    );
  }
}
