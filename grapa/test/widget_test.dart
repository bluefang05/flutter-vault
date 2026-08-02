import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grapa/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra y completa las misiones del día', (tester) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));

    expect(find.text('Tu aventura de hoy'), findsOneWidget);
    expect(find.text('Preparar presentación'), findsOneWidget);
    expect(find.text('0/3 listas'), findsOneWidget);

    await tester.tap(find.text('Preparar presentación'));
    await tester.pumpAndSettle();

    expect(find.text('1/3 listas'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('permite navegar al rincón de Pin', (tester) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();

    expect(find.text('El rincón de Pin'), findsOneWidget);
    expect(find.text('Dar merienda - 10 monedas'), findsOneWidget);
  });

  testWidgets('no cobra dos veces si Pin ya está comiendo', (tester) async {
    SharedPreferences.setMockInitialValues({'coins': 50, 'pin_hearts': 3});

    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dar merienda - 10 monedas'));
    await tester.pumpAndSettle();

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 40);
    expect(preferences.getInt('pin_hearts'), 4);
    expect(find.text('Pin ya está satisfecho'), findsOneWidget);

    await tester.tap(find.text('Pin ya está satisfecho'));
    await tester.pumpAndSettle();

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 40);
    expect(preferences.getInt('pin_hearts'), 4);
  });

  testWidgets('no permite alimentar a Pin si ya tiene corazones completos', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'coins': 50, 'pin_hearts': 5});

    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();

    expect(find.text('Pin ya está satisfecho'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      false,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 50);
    expect(preferences.getInt('pin_hearts'), 5);
  });

  testWidgets('el nivel usa monedas ganadas, no el saldo gastable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'coins': 260,
      'total_coins_earned': 260,
      'pin_hearts': 3,
    });

    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Nivel 2'), findsOneWidget);
    expect(find.text('260 / 500 monedas ganadas'), findsOneWidget);

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dar merienda - 10 monedas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('250'), findsOneWidget);
    expect(find.text('Nivel 2'), findsOneWidget);
    expect(find.text('260 / 500 monedas ganadas'), findsOneWidget);
  });

  testWidgets('permite equipar ropa de Grapa desde el perfil', (tester) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Lazo'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -140));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lazo'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('equipped_grapa_asset'),
      GrapaEquippedAssets.bowPremium,
    );
    expect(find.text('Equipado'), findsOneWidget);
  });

  testWidgets('muestra el progreso de aventura y vuelve a las misiones', (
    tester,
  ) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aventura'));
    await tester.pumpAndSettle();

    expect(find.text('La expedición comienza aquí'), findsOneWidget);
    expect(find.text('0 de 3 misiones'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Continuar misiones'), findsOneWidget);

    await tester.tap(find.text('Continuar misiones'));
    await tester.pumpAndSettle();

    expect(find.text('Misiones de hoy'), findsOneWidget);
  });

  testWidgets('edita el nombre y el detalle de una misión', (tester) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Tomar agua');
    await tester.enterText(fields.at(1), 'Salud · 8 vasos');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Tomar agua'), findsOneWidget);
    expect(find.text('Salud · 8 vasos'), findsOneWidget);
  });

  testWidgets('muestra un estado útil al eliminar todas las misiones', (
    tester,
  ) async {
    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();
    }

    expect(find.text('0/0 listas'), findsOneWidget);
    expect(
      find.text(
        'Aún no tienes misiones diarias. Añade la primera para comenzar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('restaura economía y reinicia tareas de un día anterior', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'coins': 777,
      'streak': 2,
      'pin_hearts': 4,
      'daily_missions_date': '2000-1-1',
      'daily_missions':
          '[{"title":"Estirar","subtitle":"Salud · 5 min","categoryAsset":"assets/images/mision_categoria/mision_categoria_02_ejercicio.png","color":4289976240,"done":true}]',
    });

    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    expect(find.text('777'), findsOneWidget);
    expect(find.text('0/1 listas'), findsOneWidget);
    expect(find.text('Estirar'), findsOneWidget);
  });

  testWidgets('limita a cinco las recompensas diarias aunque se borren tareas', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final missions = List.generate(
      6,
      (index) =>
          '{"title":"Tarea ${index + 1}","subtitle":"Personal",'
          '"categoryAsset":"assets/images/mision_categoria/mision_categoria_02_ejercicio.png",'
          '"color":4293233573,"done":false}',
    ).join(',');
    SharedPreferences.setMockInitialValues({
      'coins': 120,
      'daily_missions_date': today,
      'daily_rewards_earned': 0,
      'daily_missions': '[$missions]',
    });

    await tester.pumpWidget(const GrapaApp(showAds: false));
    await tester.pumpAndSettle();

    for (var index = 1; index <= 5; index++) {
      await tester.ensureVisible(find.text('Tarea $index'));
      await tester.tap(find.text('Tarea $index'));
      await tester.pumpAndSettle();
    }

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 170);
    expect(preferences.getInt('daily_rewards_earned'), 50);

    final fifthTile = find
        .ancestor(of: find.text('Tarea 5'), matching: find.byType(Material))
        .first;
    await tester.tap(
      find.descendant(
        of: fifthTile,
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Tarea 6'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Tarea 6'));
    await tester.pumpAndSettle();

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 170);
    expect(preferences.getInt('daily_rewards_earned'), 50);
    expect(find.byIcon(Icons.check_rounded), findsWidgets);
  });
}
