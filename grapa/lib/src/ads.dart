part of '../main.dart';

class _AdMobIds {
  static const _androidReleaseBanner = 'ca-app-pub-3322493998376707/3728365700';
  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';

  static String get bottomBanner =>
      kReleaseMode ? _androidReleaseBanner : _androidTestBanner;
}

class _BottomBannerAd extends StatefulWidget {
  const _BottomBannerAd();

  @override
  State<_BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<_BottomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (!_isLoaded || bannerAd == null) return const SizedBox.shrink();

    return ColoredBox(
      color: const Color(0xFFFFFCF6),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: Center(child: AdWidget(ad: bannerAd)),
        ),
      ),
    );
  }

  void _loadBanner() {
    final bannerAd = BannerAd(
      adUnitId: _AdMobIds.bottomBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    );
    _bannerAd = bannerAd;
    bannerAd.load();
  }
}
