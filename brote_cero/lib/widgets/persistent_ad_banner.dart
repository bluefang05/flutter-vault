import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_config.dart';

/// Banner adaptativo anclado. Vive por encima del Navigator, por lo que no se
/// superpone al comic y permanece en el mismo lugar al cambiar de pantalla.
class PersistentAdBanner extends StatefulWidget {
  const PersistentAdBanner({super.key});

  @override
  State<PersistentAdBanner> createState() => _PersistentAdBannerState();
}

class _PersistentAdBannerState extends State<PersistentAdBanner> {
  BannerAd? _bannerAd;
  AdSize? _bannerSize;
  int? _lastRequestedWidth;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdConfig.supportedPlatform) return;

    final width = MediaQuery.sizeOf(context).width.floor();
    if (width <= 0 || width == _lastRequestedWidth || _loading) return;

    _lastRequestedWidth = width;
    _loadForWidth(width);
  }

  Future<void> _loadForWidth(int width) async {
    _loading = true;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (!mounted) return;

    final effectiveSize = size ?? AdSize.banner;
    final oldAd = _bannerAd;

    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: effectiveSize,
      listener: BannerAdListener(
        onAdLoaded: (Ad loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _bannerAd = loadedAd as BannerAd;
            _bannerSize = effectiveSize;
            _loading = false;
          });
          oldAd?.dispose();
        },
        onAdFailedToLoad: (Ad failedAd, LoadAdError error) {
          failedAd.dispose();
          if (!mounted) return;
          setState(() {
            _loading = false;
            _bannerAd = null;
            _bannerSize = null;
          });
        },
      ),
    );

    unawaited(ad.load());
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.supportedPlatform) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAd;
    final size = _bannerSize;

    // Reserva una franja pequena mientras carga para que la interfaz no salte.
    if (ad == null || size == null) {
      return Container(
        height: 50,
        width: double.infinity,
        color: const Color(0xFF050606),
        alignment: Alignment.center,
        child: Text(
          'ANUNCIO',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.20),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF050606),
      alignment: Alignment.center,
      child: SizedBox(
        width: size.width.toDouble(),
        height: size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
