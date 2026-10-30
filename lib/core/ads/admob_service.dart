import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Owns AdMob SDK initialization and the UMP consent flow.
///
/// Banner widgets call [ensureInitialized] before requesting an ad. The SDK is
/// initialized once even if multiple banners are created.
class AdMobService {
  AdMobService._();

  static final AdMobService instance = AdMobService._();

  Future<void>? _initialization;
  Future<void>? _mobileAdsInitialization;

  Future<void> ensureInitialized() {
    if (!AdConfig.canShowAds) return Future<void>.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      final consentReady = Completer<void>();

      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            if (formError != null) {
              debugPrint(
                'AdMob consent form error: ${formError.errorCode} '
                '${formError.message}',
              );
            }
            await _initializeMobileAds();
            if (!consentReady.isCompleted) consentReady.complete();
          });
        },
        (formError) async {
          debugPrint(
            'AdMob consent update error: ${formError.errorCode} '
            '${formError.message}',
          );
          await _initializeMobileAds();
          if (!consentReady.isCompleted) consentReady.complete();
        },
      );

      await consentReady.future;
    } catch (error, stackTrace) {
      debugPrint('AdMob initialization error: $error');
      debugPrint('$stackTrace');
      await _initializeMobileAds();
    }
  }

  Future<void> _initializeMobileAds() {
    return _mobileAdsInitialization ??=
        MobileAds.instance.initialize().then((_) {});
  }
}
