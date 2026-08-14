import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_screen.dart';
import 'services/ad_config.dart';
import 'widgets/persistent_ad_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (AdConfig.supportedPlatform) {
    unawaited(MobileAds.instance.initialize());
  }

  runApp(const BroteCeroApp());
}

class BroteCeroApp extends StatelessWidget {
  const BroteCeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF090A0A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brote Cero',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D342D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) {
        return ColoredBox(
          color: background,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                const PersistentAdBanner(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
