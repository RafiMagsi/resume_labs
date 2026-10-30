import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Central AdMob configuration.
///
/// Test IDs are used by default so debug builds never request live ads.
/// For a production build, pass:
///
/// ```
/// --dart-define=ADMOB_USE_TEST_ADS=false
/// --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-.../...
/// --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-.../...
/// ```
///
/// The AdMob app IDs live in `AndroidManifest.xml` / `Info.plist` and must be
/// replaced separately before release.
abstract final class AdConfig {
  static const bool adsEnabled = !bool.fromEnvironment('DISABLE_ADS');

  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');

  /// Debug/profile builds use Google's test units. Release builds stay
  /// ad-free until real unit IDs are supplied, so test ads are never shipped.
  static const bool useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: !_isRelease,
  );

  static const String _androidTestBannerUnitId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _iosTestBannerUnitId =
      'ca-app-pub-3940256099942544/6978663496';

  static const String _androidBannerUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const String _iosBannerUnitId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
  );

  static String get bannerUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _iosTestBannerUnitId : _androidTestBannerUnitId;
    }
    return Platform.isIOS ? _iosBannerUnitId : _androidBannerUnitId;
  }

  static bool get canShowAds =>
      adsEnabled && !kIsWeb && bannerUnitId.isNotEmpty;
}
