import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brote_cero/models/story.dart';
import 'package:brote_cero/screens/reader_screen.dart';
import 'package:brote_cero/services/content_repository.dart';
import 'package:brote_cero/services/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('content repository', () {
    test('parses lightweight catalog without pages', () {
      final catalog = StoryCatalog.fromMap(_catalogMap(storyCount: 3));

      expect(catalog.stories, hasLength(3));
      expect(catalog.stories.first.id, '001');
      expect(catalog.stories.first.cover, 'assets/story/001/page_01.webp');
      expect(catalog.stories.first.pageCount, 8);
    });

    test('loads story by id only when requested', () async {
      final bundle = _MapAssetBundle(<String, String>{
        'assets/data/catalog.json': jsonEncode(_catalogMap(storyCount: 2)),
        'assets/data/story_001.json': jsonEncode(_storyMap('001')),
      });
      final repository = ContentRepository(bundle: bundle);

      final catalog = await repository.loadCatalog();
      expect(catalog.stories, hasLength(2));
      expect(bundle.loadedPaths, isNot(contains('assets/data/story_001.json')));

      final story = await repository.loadStory('001');
      expect(story.pages.first.id, '001-001');
      expect(bundle.loadedPaths, contains('assets/data/story_001.json'));
      expect(bundle.loadedPaths, isNot(contains('assets/data/story_002.json')));
    });

    test('wraps file and JSON errors', () async {
      final missingRepository = ContentRepository(bundle: _MapAssetBundle());
      await expectLater(
        missingRepository.loadCatalog(),
        throwsA(isA<ContentLoadException>()),
      );

      final invalidRepository = ContentRepository(
        bundle: _MapAssetBundle(<String, String>{
          'assets/data/story_001.json': '{bad',
        }),
      );
      await expectLater(
        invalidRepository.loadStory('001'),
        throwsA(isA<ContentLoadException>()),
      );
    });
  });

  group('progress store', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('saves pageId pageIndex and offset', () async {
      const position = ReadingPosition(
        storyId: '001',
        pageId: '001-006',
        pageIndex: 5,
        offsetWithinPage: 0.34,
      );

      await ProgressStore.savePosition(position, pageCount: 8);
      final loaded = await ProgressStore.loadPosition(
        '001',
        pageIds: _pageIds('001', 8),
      );

      expect(loaded.pageId, '001-006');
      expect(loaded.pageIndex, 5);
      expect(loaded.offsetWithinPage, closeTo(0.34, 0.001));
    });

    test('migrates legacy global scroll progress', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'story_001_progress': 0.625,
      });

      final loaded = await ProgressStore.loadPosition(
        '001',
        pageIds: _pageIds('001', 8),
      );

      expect(loaded.pageId, '001-006');
      expect(loaded.pageIndex, 5);
      expect(loaded.offsetWithinPage, closeTo(0, 0.001));
    });

    test('short story completion is based on final page position', () {
      const complete = ReadingPosition(
        storyId: 'x',
        pageId: 'x-001',
        pageIndex: 0,
        offsetWithinPage: 0.95,
      );
      const incomplete = ReadingPosition(
        storyId: 'x',
        pageId: 'x-001',
        pageIndex: 0,
        offsetWithinPage: 0.5,
      );

      expect(complete.isCompleted(1), isTrue);
      expect(incomplete.isCompleted(1), isFalse);
    });
  });

  test('reader calculates visible logical page', () {
    final story = StoryData.fromMap(_storyMap('001'));
    final position = calculateReadingPosition(
      story: story,
      pageStarts: const <double>[0, 1000, 2000],
      pageHeights: const <double>[1000, 1000, 1000],
      scrollOffset: 1340,
    );

    expect(position.pageId, '001-002');
    expect(position.pageIndex, 1);
    expect(position.offsetWithinPage, closeTo(0.34, 0.001));
  });
}

Map<String, dynamic> _catalogMap({required int storyCount}) {
  return <String, dynamic>{
    'stories': <Map<String, dynamic>>[
      for (var i = 1; i <= storyCount; i += 1)
        <String, dynamic>{
          'id': i.toString().padLeft(3, '0'),
          'archiveLabel': 'Archivo ${i.toString().padLeft(3, '0')}',
          'title': 'Historia $i',
          'subtitle': 'Una historia',
          'cover': 'assets/story/${i.toString().padLeft(3, '0')}/page_01.webp',
          'estimatedMinutes': 5,
          'pageCount': 8,
          'tags': <String>['Horror'],
          'contentVersion': '1.0',
        },
    ],
  };
}

Map<String, dynamic> _storyMap(String id) {
  return <String, dynamic>{
    'id': id,
    'archiveLabel': 'Archivo $id',
    'title': 'Historia $id',
    'subtitle': 'Una historia',
    'contentVersion': '1.0',
    'estimatedMinutes': 5,
    'pages': <Map<String, dynamic>>[
      for (var i = 1; i <= 3; i += 1)
        <String, dynamic>{
          'id': '$id-${i.toString().padLeft(3, '0')}',
          'asset': 'assets/story/$id/page_${i.toString().padLeft(2, '0')}.webp',
          'width': 1000,
          'height': 2000,
        },
    ],
  };
}

List<String> _pageIds(String storyId, int count) {
  return <String>[
    for (var i = 1; i <= count; i += 1)
      '$storyId-${i.toString().padLeft(3, '0')}',
  ];
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle([Map<String, String>? assets])
      : _assets = assets ?? const <String, String>{};

  final Map<String, String> _assets;
  final List<String> loadedPaths = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loadedPaths.add(key);
    final value = _assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.sublistView(bytes);
  }
}
