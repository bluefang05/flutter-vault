import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TopAdBanner extends StatefulWidget {
  const TopAdBanner({super.key});

  @override
  State<TopAdBanner> createState() => _TopAdBannerState();
}

class _TopAdBannerState extends State<TopAdBanner> {
  static const String _androidBannerUnitId =
      'ca-app-pub-3322493998376707/6293689997';
  static const String _iosBannerUnitId =
      'ca-app-pub-3322493998376707/6293689997';

  BannerAd? _bannerAd;
  AdSize? _bannerSize;
  bool _isLoaded = false;
  int? _requestedWidth;
  int? _loadingWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerForCurrentWidth();
  }

  @override
  void didUpdateWidget(covariant TopAdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_bannerAd == null) {
      _loadBannerForCurrentWidth();
    }
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  String get _adUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) return _iosBannerUnitId;
    return _androidBannerUnitId;
  }

  bool get _supportsAds =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  void _loadBannerForCurrentWidth() {
    if (kIsWeb || !_supportsAds) return;
    final int width = MediaQuery.sizeOf(context).width.floor();
    if (width <= 0 || _loadingWidth == width) return;
    if (_requestedWidth == width && _bannerAd != null) return;

    final BannerAd? previousBanner = _bannerAd;
    final AdSize? previousSize = _bannerSize;
    _loadingWidth = width;
    if (previousBanner != null || previousSize != null || _isLoaded) {
      setState(() {
        _bannerAd = null;
        _bannerSize = previousSize;
        _isLoaded = false;
        _requestedWidth = null;
      });
    }
    unawaited(_reloadBanner(width, previousBanner));
  }

  Future<void> _reloadBanner(int width, BannerAd? previousBanner) async {
    final AdSize? adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || _loadingWidth != width) return;
    if (adSize == null) {
      previousBanner?.dispose();
      setState(() {
        _bannerAd = null;
        _bannerSize = null;
        _isLoaded = false;
        _requestedWidth = null;
        _loadingWidth = null;
      });
      return;
    }

    previousBanner?.dispose();
    final BannerAd bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerSize = adSize;
            _isLoaded = true;
            _requestedWidth = width;
            _loadingWidth = null;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _bannerSize = adSize;
            _isLoaded = false;
            _requestedWidth = width;
            _loadingWidth = null;
          });
        },
      ),
    );

    if (!mounted || _loadingWidth != width) {
      bannerAd.dispose();
      return;
    }
    setState(() {
      _bannerAd = bannerAd;
      _bannerSize = adSize;
      _isLoaded = false;
      _requestedWidth = width;
    });
    bannerAd.load();
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerSize = null;
    _isLoaded = false;
    _requestedWidth = null;
    _loadingWidth = null;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_supportsAds) {
      return const SizedBox.shrink();
    }
    final BannerAd? banner = _bannerAd;
    final AdSize? size = _bannerSize;
    if (banner == null || size == null || !_isLoaded) {
      return const SafeArea(
        bottom: false,
        child: SizedBox(height: 50, width: double.infinity),
      );
    }

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: size.height.toDouble(),
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFF05070D),
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
