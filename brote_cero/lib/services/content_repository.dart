import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/story.dart';

class ContentLoadException implements Exception {
  const ContentLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'ContentLoadException: $message';
    return 'ContentLoadException: $message ($cause)';
  }
}

class ContentRepository {
  const ContentRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const ContentRepository instance = ContentRepository();

  final AssetBundle? _bundle;

  AssetBundle get bundle => _bundle ?? rootBundle;

  Future<StoryCatalog> loadCatalog() async {
    final json = await _loadJsonMap('assets/data/catalog.json');
    return StoryCatalog.fromMap(json);
  }

  Future<StoryData> loadStory(String storyId) async {
    final json = await _loadJsonMap('assets/data/story_$storyId.json');
    return StoryData.fromMap(json);
  }

  Future<UpdateManifest> loadUpdateManifest() async {
    final json = await _loadJsonMap('assets/data/update_manifest.json');
    return UpdateManifest.fromMap(json);
  }

  Future<Map<String, dynamic>> _loadJsonMap(String asset) async {
    try {
      final raw = await bundle.loadString(asset);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Root JSON value is not an object');
      }
      return decoded;
    } catch (error) {
      throw ContentLoadException('No se pudo cargar $asset', error);
    }
  }
}
