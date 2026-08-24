import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'state/settings_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (support portrait and landscape for tablets & foldables)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } catch (_) {}

  // Initialize offline persistent local storage safely
  await StorageService.init();

  runApp(const GesturaApp());

  // Initialize Google Mobile Ads asynchronously in the background so it NEVER blocks UI startup
  Future.microtask(() async {
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // Graceful fallback if offline or in testing
    }
  });
}


class GesturaApp extends StatefulWidget {
  const GesturaApp({super.key});

  @override
  State<GesturaApp> createState() => _GesturaAppState();
}

class _GesturaAppState extends State<GesturaApp> {
  final SettingsProvider _settingsProvider = SettingsProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsProvider,
      builder: (context, _) {
        ThemeData lightTheme = AppTheme.lightTheme;
        ThemeData darkTheme = AppTheme.darkTheme;

        if (_settingsProvider.isHighContrast) {
          lightTheme = AppTheme.highContrastTheme;
          darkTheme = AppTheme.highContrastTheme;
        }

        return MaterialApp(
          title: 'Gestura',
          debugShowCheckedModeBanner: false,
          themeMode: _settingsProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: _settingsProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            Widget content = child ?? const SizedBox();
            if (_settingsProvider.isWarmFilter) {
              content = ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0x15D97706),
                  BlendMode.darken,
                ),
                child: content,
              );
            }
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_settingsProvider.fontScale),
                disableAnimations: _settingsProvider.isReduceMotion,
              ),
              child: content,
            );
          },
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

