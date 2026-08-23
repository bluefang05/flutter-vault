import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voxel_anaconda/main.dart';

void main() {
  testWidgets('main menu opens help screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VoxelAnacondaApp());

    expect(find.text('VOXEL'), findsOneWidget);
    expect(find.text('ANACONDA'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.track_changes_rounded), findsOneWidget);
    expect(find.byIcon(Icons.gamepad_rounded), findsOneWidget);
  });
}
