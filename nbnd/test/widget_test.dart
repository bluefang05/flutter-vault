import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nbnd/app/nbnd_app.dart';
import 'package:nbnd/app/nbnd_theme.dart';
import 'package:nbnd/l10n/app_localizations.dart';
import 'package:nbnd/models/game_settings.dart';
import 'package:nbnd/models/neuro_type.dart';
import 'package:nbnd/screens/game_screen.dart';
import 'package:nbnd/screens/profile_info_screen.dart';
import 'package:nbnd/widgets/neuro_profile_icon.dart';

void main() {
  testWidgets('App boots and shows the home screen title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('NBND'), findsWidgets);
  });

  testWidgets('home shows the selected profile icon beside the character', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(_profileImage(NeuroType.tdah, minWidth: 50), findsOneWidget);
  });

  testWidgets('home profile icon changes when the profile page changes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.bySubtype<PageView>(), const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 500));

    expect(_profileImage(NeuroType.tea, minWidth: 45), findsWidgets);
  });

  testWidgets('home opens the profile information screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('learn-profiles-home')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const ValueKey<String>('learn-profiles-home')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Learn the profiles'), findsOneWidget);
  });

  testWidgets('profile information screen shows educational sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_profileInfoTestApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Conocer los perfiles'), findsOneWidget);
    expect(find.text('Qué es'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Voces de la comunidad'), findsOneWidget);
    expect(find.textContaining('metáfora jugable'), findsWidgets);
  });

  testWidgets('profile card info button opens the selected profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NbndApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const ValueKey<String>('profile-info-TDAH')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Learn the profiles'), findsOneWidget);
    expect(find.text('Attention deficit hyperactivity disorder'), findsWidgets);
  });

  testWidgets(
    'profile icon falls back to the neurotype code on asset failure',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _FailingAssetBundle(),
          child: MaterialApp(
            locale: const Locale('es'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: NbndTheme.dark,
            home: const Scaffold(
              body: NeuroProfileIcon(
                neuroType: NeuroType.tag,
                size: 64,
                selected: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TAG'), findsOneWidget);
    },
  );

  testWidgets(
    'control tutorial shows both directions and hides on lateral tap',
    (WidgetTester tester) async {
      await tester.pumpWidget(_gameTestApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ANTIHORARIO'), findsOneWidget);
      expect(find.text('HORARIO'), findsOneWidget);
      expect(find.text('TOCA Y MANTÉN'), findsNWidgets(2));

      final TestGesture gesture = await tester.startGesture(
        const Offset(60, 420),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ANTIHORARIO'), findsNothing);
      expect(find.text('HORARIO'), findsNothing);
      await gesture.up();
    },
  );

  testWidgets('center touch does not dismiss the movement tutorial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_gameTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(GameScreen)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ANTIHORARIO'), findsOneWidget);
    expect(find.text('HORARIO'), findsOneWidget);
    await gesture.up();
  });
}

Widget _profileInfoTestApp() {
  return MaterialApp(
    locale: const Locale('es'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: NbndTheme.dark,
    home: const ProfileInfoScreen(initialType: NeuroType.toc),
  );
}

Finder _profileImage(NeuroType type, {double minWidth = 0}) {
  return find.byWidgetPredicate((Widget widget) {
    if (widget is! Image) return false;
    final ImageProvider image = widget.image;
    return image is AssetImage &&
        image.assetName == type.iconAsset &&
        (widget.width ?? 0) >= minWidth;
  });
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    return Future<ByteData>.error(FlutterError('missing test asset: $key'));
  }
}

Widget _gameTestApp() {
  return MaterialApp(
    locale: const Locale('es'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: NbndTheme.dark,
    home: const GameScreen(
      neuroType: NeuroType.tdah,
      settings: GameSettings(haptics: false, reducedFlashes: true),
      initialBestScore: 0,
    ),
  );
}
