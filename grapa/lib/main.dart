import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'src/models.dart';
part 'src/assets.dart';
part 'src/ads.dart';
part 'src/home.dart';
part 'src/home_mission_editor.dart';
part 'src/today_view.dart';
part 'src/today_widgets.dart';
part 'src/adventure_view.dart';
part 'src/pin_view.dart';
part 'src/profile_view.dart';
part 'src/profile_shop_widgets.dart';
part 'src/common_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  runApp(const GrapaApp());
}

class GrapaApp extends StatelessWidget {
  const GrapaApp({super.key, this.showAds = true});

  final bool showAds;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF25231F);
    const cream = Color(0xFFF8F4EA);
    const purple = Color(0xFF7656D6);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grapa',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          surface: cream,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
          fontFamily: 'sans',
        ),
      ),
      home: GrapaHome(showAds: showAds),
    );
  }
}
