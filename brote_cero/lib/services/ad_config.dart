import 'package:flutter/foundation.dart';

/// Configuracion central de AdMob para Brote Cero.
///
/// IMPORTANTE:
/// - Por defecto SIEMPRE se usa el banner de prueba de Google, incluso con
///   `flutter run --release`.
/// - El banner real solo se activa al compilar para publicar con:
///   --dart-define=USE_REAL_ADS=true
class AdConfig {
  AdConfig._();

  static const String appIdAndroid = 'ca-app-pub-3322493998376707~5656915651';

  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _realBannerAndroid =
      'ca-app-pub-3322493998376707/6475173308';

  static const bool useRealAds = bool.fromEnvironment(
    'USE_REAL_ADS',
    defaultValue: false,
  );

  static bool get supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return useRealAds ? _realBannerAndroid : _testBannerAndroid;
    }

    // Brote Cero se esta preparando primero para Android. Si en el futuro se
    // agrega iOS, sustituir este ID por el bloque real correspondiente.
    return 'ca-app-pub-3940256099942544/2934735716';
  }
}
