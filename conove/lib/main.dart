import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'state/settings_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize offline persistent local storage
  await StorageService.init();

  runApp(const ConoVeApp());
}

class ConoVeApp extends StatefulWidget {
  const ConoVeApp({super.key});

  @override
  State<ConoVeApp> createState() => _ConoVeAppState();
}

class _ConoVeAppState extends State<ConoVeApp> {
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

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_settingsProvider.fontScale),
            disableAnimations: _settingsProvider.isReduceMotion,
          ),
          child: MaterialApp(
            title: 'ConoVe',
            debugShowCheckedModeBanner: false,
            themeMode: _settingsProvider.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
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
              return content;
            },
            home: const MainNavigationScreen(),
          ),
        );
      },
    );
  }
}

