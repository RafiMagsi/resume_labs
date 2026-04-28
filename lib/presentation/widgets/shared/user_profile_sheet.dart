import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../injection/injection_container.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/resume_optimization_provider.dart';
import '../../screens/resume_optimizer/resume_optimizer_screen.dart';
import 'app_loader.dart';
import 'credits_paywall.dart';

class UserProfileSheet extends ConsumerWidget {
  const UserProfileSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const UserProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final creditsAsync = ref.watch(creditsAvailableProvider);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          24,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, userAsync),
            const SizedBox(height: 24),
            _buildCreditsInfo(context, ref, creditsAsync),
            const SizedBox(height: 24),
            _buildMenuItems(context, ref),
            const SizedBox(height: 24),
            _buildSignOutButton(context, ref),
            const SizedBox(height: 12),
            _buildDeleteAccountButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<dynamic> userAsync) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.cardHeaderStart, AppColors.cardHeaderEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: userAsync.maybeWhen(
              data: (user) {
                final email = user?.email ?? '?';
                final initial = email.isNotEmpty
                    ? email.split('@').first[0].toUpperCase()
                    : '?';
                return Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
              orElse: () => const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              userAsync.maybeWhen(
                data: (user) => Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildCreditsInfo(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> creditsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.premiumGold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CV Optimization Credits',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    creditsAsync.when(
                      data: (credits) => Text(
                        '$credits available',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      loading: () => const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      error: (_, __) => const Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                CreditsPaywall.show(context, ref);
              },
              child: creditsAsync.when(
                data: (credits) => Text(
                  credits > 0 ? 'Buy more Credits' : 'Buy Credits',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                loading: () => const Text(
                  'Buy Credits',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                error: (_, __) => const Text(
                  'Buy Credits',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.auto_awesome_rounded,
          label: 'Resume Optimizer',
          subtitle: 'Optimize your resume with AI',
          onTap: () {
            Navigator.of(context).pop();
            ref.read(resumeFormProvider.notifier).reset();
            ref.invalidate(resumeOptimizationNotifierProvider);
            context.push(ResumeOptimizerScreen.routePath);
          },
        ),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.history_rounded,
          label: 'My Resumes',
          subtitle: 'View and manage your resumes',
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () async {
          Navigator.of(context).pop();
          final signOutUseCase = ref.read(signOutUseCaseProvider);
          await signOutUseCase();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.destructiveSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.destructiveBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'This permanently deletes your account and all resumes. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                );
              },
            );

            if (confirm != true || !context.mounted) return;

            // Close the bottom sheet first.
            Navigator.of(context).pop();

            // Show a blocking loader while deleting.
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: AppLoader(size: 36),
              ),
            );

            final deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
            final result = await deleteAccountUseCase();

            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop(); // loader

            result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppColors.error,
                ),
              ),
              (_) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully.'),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          splashColor: AppColors.error.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
