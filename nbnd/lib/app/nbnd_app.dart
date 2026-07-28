import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import 'nbnd_theme.dart';

class NbndApp extends StatelessWidget {
  const NbndApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale platformLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    final Locale effectiveLocale = AppLocalizations.resolveLocale(platformLocale);
    return MaterialApp(
      locale: effectiveLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'NBND',
      debugShowCheckedModeBanner: false,
      theme: NbndTheme.dark,
      home: const HomeScreen(),
    );
  }
}
