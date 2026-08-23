import 'dart:typed_data';

import 'package:flutter/services.dart';

class PickedNativeFile {
  final String name;
  final String mimeType;
  final Uint8List bytes;

  const PickedNativeFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
}

class NativeFileService {
  NativeFileService._();

  static const MethodChannel _channel =
      MethodChannel('com.enmanuelapp.pymerd/files');

  static Future<bool> saveBytes({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final result = await _channel.invokeMethod<bool>('saveBytes', {
      'fileName': fileName,
      'mimeType': mimeType,
      'bytes': Uint8List.fromList(bytes),
    });
    return result ?? false;
  }

  static Future<Uint8List?> pickBytes({
    String mimeType = 'application/zip',
  }) async {
    return _channel.invokeMethod<Uint8List>(
      'pickBytes',
      {'mimeType': mimeType},
    );
  }

  static Future<PickedNativeFile?> pickFile({
    String mimeType = '*/*',
  }) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'pickFile',
      {'mimeType': mimeType},
    );
    if (result == null) return null;
    final bytes = result['bytes'];
    if (bytes is! Uint8List) return null;
    return PickedNativeFile(
      name: (result['name'] as String?) ?? 'archivo',
      mimeType: (result['mimeType'] as String?) ?? 'application/octet-stream',
      bytes: bytes,
    );
  }
}
