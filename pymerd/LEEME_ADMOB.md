# PYME RD — corrección completa de AdMob

Este parche completa la integración que había quedado a medias.

Corrige:

- dependencia `google_mobile_ads: 5.3.1`;
- App ID de AdMob en `AndroidManifest.xml`;
- inicialización de `MobileAds` en `main.dart`;
- uso de `PymeAdBanner` en lugar del rectángulo falso;
- banner visible solo en Hoy, Citas y Clientes;
- anuncios de prueba por defecto;
- bloque real únicamente con `--dart-define=PYMERD_LIVE_ADS=true`.

## Prueba normal

```powershell
flutter run --release
```

Usará el banner oficial de prueba de Google.

## AAB oficial

```powershell
flutter build appbundle --release --dart-define=PYMERD_LIVE_ADS=true
```

Usará:

- App ID: `ca-app-pub-3322493998376707~6779988736`
- Banner: `ca-app-pub-3322493998376707/1982957622`
