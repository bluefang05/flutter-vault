import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grapa/main.dart';

void main() {
  testWidgets('muestra y completa las misiones del día', (tester) async {
    await tester.pumpWidget(const GrapaApp());

    expect(find.text('Tu aventura de hoy'), findsOneWidget);
    expect(find.text('Preparar presentación'), findsOneWidget);
    expect(find.text('0/3 listas'), findsOneWidget);

    await tester.tap(find.text('Preparar presentación'));
    await tester.pumpAndSettle();

    expect(find.text('1/3 listas'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('permite navegar al rincón de Pin', (tester) async {
    await tester.pumpWidget(const GrapaApp());

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();

    expect(find.text('El rincón de Pin'), findsOneWidget);
    expect(find.text('Dar merienda · 10 monedas'), findsOneWidget);
  });
}
