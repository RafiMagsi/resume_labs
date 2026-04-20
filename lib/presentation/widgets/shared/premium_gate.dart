import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/purchase/premium_status_provider.dart';
import './paywall_bottom_sheet.dart';

class PremiumGate {
  static bool checkPremiumOrShowPaywall(
    BuildContext context,
    WidgetRef ref,
  ) {
    final premiumStatus = ref.watch(premiumStatusProvider);

    return premiumStatus.when(
      data: (isPremium) {
        if (!isPremium) {
          PaywallBottomSheet.show(context, ref);
          return false;
        }
        return true;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  static Future<bool> checkPremiumAsync(WidgetRef ref) async {
    final premiumStatus = ref.watch(premiumStatusProvider);

    return premiumStatus.when(
      data: (isPremium) => isPremium,
      loading: () => false,
      error: (_, __) => false,
    );
  }
}
