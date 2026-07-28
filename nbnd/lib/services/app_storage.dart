import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  Map<String, Object?>? _cache;
  Future<void> _writeQueue = Future<void>.value();

  Future<File> _file() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}nbnd_state.json');
  }

  Future<Map<String, Object?>> _load() async {
    if (_cache != null) return _cache!;
    final File file = await _file();
    if (!await file.exists()) {
      _cache = <String, Object?>{};
      return _cache!;
    }
    final Object? decoded = jsonDecode(await file.readAsString());
    _cache = decoded is Map
        ? decoded.map<String, Object?>(
            (Object? key, Object? value) => MapEntry(key.toString(), value),
          )
        : <String, Object?>{};
    return _cache!;
  }

  Future<void> _save(Map<String, Object?> data) async {
    final File file = await _file();
    await file.writeAsString(jsonEncode(data), flush: true);
    _cache = Map<String, Object?>.from(data);
  }

  Future<void> _mutate(
    Future<void> Function(Map<String, Object?> data) mutate,
  ) {
    final Completer<void> completer = Completer<void>();
    _writeQueue = _writeQueue
        .then((_) async {
          final Map<String, Object?> data = Map<String, Object?>.from(
            await _load(),
          );
          await mutate(data);
          await _save(data);
        })
        .then(
          (_) => completer.complete(),
          onError: (Object error, StackTrace stackTrace) {
            completer.completeError(error, stackTrace);
          },
        );
    return completer.future;
  }

  Future<String?> getString(String key) async =>
      (await _load())[key] as String?;

  Future<int?> getInt(String key) async {
    final Object? value = (await _load())[key];
    return value is int ? value : null;
  }

  Future<bool?> getBool(String key) async {
    final Object? value = (await _load())[key];
    return value is bool ? value : null;
  }

  Future<void> setString(String key, String value) async {
    await _mutate((Map<String, Object?> data) async {
      data[key] = value;
    });
  }

  Future<void> setInt(String key, int value) async {
    await _mutate((Map<String, Object?> data) async {
      data[key] = value;
    });
  }

  Future<void> setBool(String key, bool value) async {
    await _mutate((Map<String, Object?> data) async {
      data[key] = value;
    });
  }

  Future<void> setMany(Map<String, Object?> values) async {
    await _mutate((Map<String, Object?> data) async {
      data.addAll(values);
    });
  }
}
