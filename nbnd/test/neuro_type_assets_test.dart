import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nbnd/models/neuro_type.dart';

void main() {
  test('every neurotype has a unique profile icon path', () {
    final List<String> paths = NeuroType.values
        .map((NeuroType type) => type.iconAsset)
        .toList(growable: false);

    expect(paths, hasLength(NeuroType.values.length));
    expect(paths.toSet(), hasLength(NeuroType.values.length));
    expect(paths, everyElement(startsWith('assets/images/profiles/')));
  });

  test('every neurotype has a unique Flame profile icon path', () {
    final List<String> paths = NeuroType.values
        .map((NeuroType type) => type.flameIconAsset)
        .toList(growable: false);

    expect(paths, hasLength(NeuroType.values.length));
    expect(paths.toSet(), hasLength(NeuroType.values.length));
    expect(paths, everyElement(startsWith('profiles/')));
  });

  test('all declared profile icon files exist in the project', () {
    for (final NeuroType type in NeuroType.values) {
      expect(
        File(type.iconAsset).existsSync(),
        isTrue,
        reason: '${type.code} icon asset is missing: ${type.iconAsset}',
      );
    }
  });
}
