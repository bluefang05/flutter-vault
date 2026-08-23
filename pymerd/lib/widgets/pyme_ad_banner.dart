import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ads_config.dart';

/// Banner inferior adaptable.
///
/// Falla silenciosamente si no hay Internet o AdMob todavía no llena el
/// bloque. El anuncio se destruye al ocultarse para evitar duplicados.
class PymeAdBanner extends StatefulWidget {
  final bool visible;

  const PymeAdBanner({
    super.key,
    this.visible = true,
  });

  @override
  State<PymeAdBanner> createState() => _PymeAdBannerState();
}

class _PymeAdBannerState extends State<PymeAdBanner> {
  BannerAd? _banner;
  AdSize? _bannerSize;
  int? _requestedWidth;
  bool _loaded = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  @override
  void didUpdateWidget(covariant PymeAdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.visible) {
      _disposeBanner();
    } else if (!oldWidget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
    }
  }

  Future<void> _loadIfNeeded() async {
    if (!mounted ||
        !widget.visible ||
        !AdsConfig.isSupported ||
        _loading) {
      return;
    }

    final width = MediaQuery.sizeOf(context).width.floor();
    if (width <= 0) return;
    if (_banner != null && _requestedWidth == width) return;

    _loading = true;
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (!mounted || !widget.visible) {
      _loading = false;
      return;
    }

    if (size == null) {
      _loading = false;
      return;
    }

    _disposeBanner(resetLoading: false);

    final banner = BannerAd(
      adUnitId: AdsConfig.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || !widget.visible) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _bannerSize = size;
            _requestedWidth = width;
            _loaded = true;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'PYME RD AdMob: banner no disponible '
            '(código ${error.code}: ${error.message}).',
          );
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _banner = null;
            _bannerSize = null;
            _requestedWidth = width;
            _loaded = false;
            _loading = false;
          });
        },
      ),
    );

    _banner = banner;
    _bannerSize = size;
    _requestedWidth = width;
    banner.load();
  }

  void _disposeBanner({bool resetLoading = true}) {
    _banner?.dispose();
    _banner = null;
    _bannerSize = null;
    _requestedWidth = null;
    _loaded = false;
    if (resetLoading) _loading = false;
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    final size = _bannerSize;

    if (!widget.visible ||
        !AdsConfig.isSupported ||
        !_loaded ||
        banner == null ||
        size == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: size.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              child: AdWidget(ad: banner),
            ),
          ),
        ),
      ),
    );
  }
}