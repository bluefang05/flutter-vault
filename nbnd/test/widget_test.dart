import 'package:flutter_test/flutter_test.dart';

import 'package:nbnd/app/nbnd_app.dart';

void main() {
  testWidgets('App boots and shows the home screen title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pumpAndSettle();

    expect(find.text('NBND'), findsWidgets);
  });
}
