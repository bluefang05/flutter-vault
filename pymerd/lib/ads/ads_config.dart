import 'package:flutter/foundation.dart';

/// Configuración centralizada de anuncios de PYME RD.
///
/// Por seguridad, todos los APK/AAB usan el bloque de prueba a menos que se
/// compile expresamente con:
/// --dart-define=PYMERD_LIVE_ADS=true
abstract final class AdsConfig {
  static const String androidAppId =
      'ca-app-pub-3322493998376707~6779988736';

  static const String androidBannerReal =
      'ca-app-pub-3322493998376707/1982957622';

  static const String androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';

  static const bool liveAds = bool.fromEnvironment(
    'PYMERD_LIVE_ADS',
    defaultValue: false,
  );

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String get bannerId =>
      liveAds ? androidBannerReal : androidBannerTest;
}