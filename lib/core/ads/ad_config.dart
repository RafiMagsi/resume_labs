import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Central AdMob configuration.
///
/// Test IDs are used by default so debug builds never request live ads.
/// Release builds are ad-free until every production ID below is filled in,
/// so Google's test units can never ship to the stores.
///
/// Production checklist (all four IDs — see `store_assets/README.md`):
/// 1. Android app ID — `android/app/build.gradle.kts` `admobAppId`
///    placeholder (or `-PadmobAppId=...` / `gradle.properties`), surfaced to
///    the manifest via the `admobAppId` placeholder.
/// 2. iOS app ID — `ios/Flutter/Release.xcconfig` `ADMOB_APP_ID`, read by
///    `Info.plist` (`GADApplicationIdentifier`).
/// 3. Android banner unit — `--dart-define=ADMOB_ANDROID_BANNER_ID=...`.
/// 4. iOS banner unit — `--dart-define=ADMOB_IOS_BANNER_ID=...`.
///
/// ```
/// flutter build ipa --dart-define=ADMOB_USE_TEST_ADS=false \
///   --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-.../... \
///   --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-.../...
/// ```
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
