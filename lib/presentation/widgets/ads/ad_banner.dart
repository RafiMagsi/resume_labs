import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/ads/ad_config.dart';
import '../../../core/ads/admob_service.dart';
import '../../../core/constants/app_colors.dart';

/// A single anchored adaptive banner.
///
/// The widget reserves 50 logical pixels while loading so the host screen does
/// not jump, then collapses if the request fails.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _loadStarted = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
  }

  Future<void> _loadBanner() async {
    if (_loadStarted || !AdConfig.canShowAds) return;
    _loadStarted = true;

    await AdMobService.instance.ensureInitialized();
    if (!mounted) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final adaptiveSize =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (!mounted) return;

    final banner = BannerAd(
      size: adaptiveSize ?? AdSize.banner,
      adUnitId: AdConfig.bannerUnitId,
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'Banner ad failed to load: ${error.code} ${error.message}',
          );
          ad.dispose();
          if (!mounted) return;
          setState(() => _loadFailed = true);
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.canShowAds || _loadFailed) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAd;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.screenSurface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ad == null
              ? const SizedBox(height: 50)
              : SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                ),
        ),
      ),
    );
  }
}
