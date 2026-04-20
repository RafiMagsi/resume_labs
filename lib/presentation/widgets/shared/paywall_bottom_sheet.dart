import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../injection/injection_container.dart';

class PaywallBottomSheet extends StatelessWidget {
  const PaywallBottomSheet({super.key});

  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PaywallBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildFeatureList(),
                const SizedBox(height: 24),
                _buildPriceSection(context),
                const SizedBox(height: 16),
                _buildUpgradeButton(context, ref),
                const SizedBox(height: 12),
                _buildRestoreButton(context, ref),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.premiumGradientStart,
                AppColors.premiumGradientEnd,
              ],
            ),
          ),
          child: const Icon(
            Icons.star_rounded,
            size: 32,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.unlockPremium,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureItem(Icons.dashboard_rounded, AppStrings.allTemplates),
        const SizedBox(height: 12),
        _buildFeatureItem(Icons.auto_awesome_rounded, AppStrings.aiContentGeneration),
        const SizedBox(height: 12),
        _buildFeatureItem(Icons.description_rounded, AppStrings.unlimitedResumes),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.premiumGold,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '₹99.00',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.oneTimePurchase,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _handlePurchase(context, ref),
        child: const Text(
          AppStrings.upgradeToPremium,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => _handleRestore(context, ref),
      child: const Text(
        AppStrings.restorePurchase,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    final useCase = ref.read(purchasePremiumUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.purchaseSuccess)),
        );
      },
    );
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final useCase = ref.read(restorePurchasesUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase restored successfully')),
        );
      },
    );
  }
}
