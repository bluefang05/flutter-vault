part of '../main.dart';

class _AdMobIds {
  static const _androidReleaseBanner = 'ca-app-pub-3322493998376707/3728365700';
  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _useTestAdsInRelease = bool.fromEnvironment('USE_TEST_ADS');

  static bool get usingTestAds => !kReleaseMode || _useTestAdsInRelease;

  static String get bottomBanner =>
      usingTestAds ? _androidTestBanner : _androidReleaseBanner;
}

class _BottomBannerAd extends StatefulWidget {
  const _BottomBannerAd();

  @override
  State<_BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<_BottomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _failedToLoad = false;

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

    return ColoredBox(
      color: const Color(0xFFFFFCF6),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: AdSize.banner.height.toDouble(),
          child: Center(
            child: _isLoaded && bannerAd != null
                ? SizedBox(
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  )
                : _BannerAdPlaceholder(failedToLoad: _failedToLoad),
          ),
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
          setState(() {
            _isLoaded = true;
            _failedToLoad = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Grapa AdMob banner failed to load: $error');
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
              _failedToLoad = true;
            });
          }
        },
      ),
    );
    _bannerAd = bannerAd;
    bannerAd.load();
  }
}

class _BannerAdPlaceholder extends StatelessWidget {
  const _BannerAdPlaceholder({required this.failedToLoad});

  final bool failedToLoad;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE6),
        border: Border(
          top: BorderSide(color: const Color(0xFFE1D8CA).withValues(alpha: .8)),
        ),
      ),
      child: Center(
        child: Text(
          failedToLoad ? 'Publicidad no disponible' : 'Publicidad',
          style: const TextStyle(
            color: Color(0xFF81786C),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
