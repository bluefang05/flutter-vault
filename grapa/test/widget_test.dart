import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grapa/main.dart';

Future<void> pumpGrapa(WidgetTester tester, {bool showAds = false}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(GrapaApp(showAds: showAds));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra y completa las misiones del día', (tester) async {
    await pumpGrapa(tester);

    expect(find.text('Tu aventura de hoy'), findsOneWidget);
    expect(find.text('Preparar presentación'), findsOneWidget);
    expect(find.text('0/3 listas'), findsOneWidget);

    await tester.tap(find.text('Preparar presentación'));
    await tester.pumpAndSettle();

    expect(find.text('1/3 listas'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('permite navegar al rincón de Pin', (tester) async {
    await pumpGrapa(tester);

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();

    expect(find.text('El rincón de Pin'), findsOneWidget);
    expect(find.text('Dar merienda - 10 monedas'), findsOneWidget);
  });

  testWidgets('no cobra dos veces si Pin ya está comiendo', (tester) async {
    SharedPreferences.setMockInitialValues({'coins': 50, 'pin_hearts': 3});

    await pumpGrapa(tester);
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

    await pumpGrapa(tester);
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

    await pumpGrapa(tester);
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

  testWidgets('permite comprar y equipar ropa de Grapa desde el perfil', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'coins': 100});

    await pumpGrapa(tester);
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

    expect(find.text('Comprar'), findsWidgets);
    await tester.tap(find.text('Lazo'));
    await tester.pumpAndSettle();

    expect(find.text('¡Artículo adquirido!'), findsOneWidget);
    await tester.tap(find.text('¡Genial!'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 20);
    expect(
      preferences.getString('equipped_grapa_asset'),
      GrapaEquippedAssets.bowPremium,
    );
    expect(
      preferences.getStringList('purchased_items'),
      contains('bow_premium_01'),
    );
    expect(find.text('Equipado'), findsOneWidget);
  });

  testWidgets('permite interactuar y acariciar a Pin', (tester) async {
    await pumpGrapa(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AnimatedScale).first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('permite crear una misión seleccionando una categoría manual', (
    tester,
  ) async {
    await pumpGrapa(tester);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Añadir una misión diaria'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Añadir una misión diaria'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Estudiar 30 minutos');
    await tester.enterText(fields.at(1), 'Estudio · Por la mañana');

    await tester.tap(find.text('Estudio'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear misión'));
    await tester.pumpAndSettle();

    expect(find.text('Estudiar 30 minutos'), findsOneWidget);
    expect(find.text('Estudio · Por la mañana'), findsOneWidget);
  });

  testWidgets(
    'muestra la celebración de día conquistado al completar todas las tareas',
    (tester) async {
      await pumpGrapa(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Preparar presentación'));
      await tester.tap(find.text('Preparar presentación'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Caminar 20 minutos'));
      await tester.tap(find.text('Caminar 20 minutos'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Leer 10 páginas'));
      await tester.tap(find.text('Leer 10 páginas'));
      await tester.pumpAndSettle();

      expect(find.text('¡Día conquistado!'), findsOneWidget);
      await tester.tap(find.text('¡Continuar la aventura!'));
      await tester.pumpAndSettle();

      expect(find.text('3/3 listas'), findsOneWidget);
    },
  );

  testWidgets('muestra el progreso de aventura y vuelve a las misiones', (
    tester,
  ) async {
    await pumpGrapa(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aventura'));
    await tester.pumpAndSettle();

    expect(find.text('MUNDO 1: BOSQUE DEL ENFOQUE'), findsOneWidget);
    expect(find.text('Día 1 de 7 en Bosque del Enfoque'), findsOneWidget);
    expect(find.text('0 de 3 misiones completadas hoy.'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Continuar misiones de hoy'), findsOneWidget);

    await tester.tap(find.text('Continuar misiones de hoy'));
    await tester.pumpAndSettle();

    expect(find.text('Misiones de hoy'), findsOneWidget);
  });

  testWidgets(
    'permite abrir el taller de mejoras y comprar un escudo de racha',
    (tester) async {
      SharedPreferences.setMockInitialValues({'coins': 200});

      await pumpGrapa(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Taller de mejoras'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Taller de mejoras'));
      await tester.pumpAndSettle();

      expect(find.text('Escudo de Racha'), findsOneWidget);
      await tester.tap(find.text('120 🪙').first);
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getInt('coins'), 80);
      expect(preferences.getInt('streak_shields'), 1);
    },
  );

  testWidgets('permite iniciar y completar un duelo de enfoque', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'coins': 50});

    await pumpGrapa(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('⏱️ Duelo de Enfoque'));
    await tester.tap(find.text('⏱️ Duelo de Enfoque'));
    await tester.pumpAndSettle();

    expect(find.text('Duelo de Enfoque Pomodoro'), findsOneWidget);
    await tester.tap(find.text('¡Comenzar Duelo!'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mantén tu mente enfocada. ¡No cedas a la distracción!'),
      findsOneWidget,
    );

    // Fast-forward 15 minutes of countdown
    await tester.pump(const Duration(minutes: 16));
    await tester.pumpAndSettle();

    expect(find.text('¡Saca Grapas ha sido derrotado!'), findsOneWidget);
    await tester.tap(find.text('¡Reclamar victoria (+15 🪙)!'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('coins'), 75);
  });

  testWidgets('edita el nombre y el detalle de una misión', (tester) async {
    await pumpGrapa(tester);
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
    await pumpGrapa(tester);
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

    await pumpGrapa(tester);
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

    await pumpGrapa(tester);
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
