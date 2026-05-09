import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_labs/injection/injection_container.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/entities/resume.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/resume_list_provider.dart';
import '../../providers/resume/resume_optimization_provider.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_loader.dart';
import '../resume_builder/builder_screen.dart';
import '../resume_builder/preview_screen.dart';
import '../resume_detail/resume_detail_screen.dart';
import '../resume_optimizer/resume_optimizer_screen.dart';
import '../../widgets/shared/dialog_manager.dart';
import '../../widgets/shared/animated_ai_button.dart';
import '../../widgets/shared/user_profile_sheet.dart' as uprofile;
import 'widgets/history_hero_header.dart';
import 'widgets/history_list.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const String routeName = 'history';
  static const String routePath = '/history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animation immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumeListState = ref.watch(resumeListProvider);

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(resumeListProvider);
              await ref.read(resumeListProvider.future);
            },
            child: resumeListState.when(
              data: (resumes) {
                if (resumes.isEmpty) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      HistoryHeroHeader(
                        resumeCount: resumes.length,
                        onProfilePressed: () =>
                            uprofile.UserProfileSheet.show(context),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppSizes.screenPadding),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.cardHeaderStart,
                                          AppColors.cardHeaderEnd,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(36),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.cardHeaderStart
                                              .withValues(alpha: 0.22),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      size: 34,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No resumes yet',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Create your first resume and it will appear here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      text: 'Create New Resume',
                                      icon: Icons.add_rounded,
                                      onPressed: () {
                                        ref
                                            .read(resumeFormProvider.notifier)
                                            .reset();
                                        context.push(BuilderScreen.routePath);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    HistoryHeroHeader(
                      resumeCount: resumes.length,
                      onProfilePressed: () =>
                          uprofile.UserProfileSheet.show(context),
                    ),
                    SliverToBoxAdapter(
                      child: HistoryList(
                        resumes: resumes,
                        onTapResume: (resume) {
                          ref.read(resumeFormProvider.notifier).loadResume(
                                resume,
                              );
                          context.push(ResumeDetailScreen.routePath);
                        },
                        onEditResume: (resume) {
                          ref.read(resumeFormProvider.notifier).loadResume(
                                resume,
                              );
                          context.push(BuilderScreen.routePath);
                        },
                        onExportResume: (resume) {
                          ref.read(resumeFormProvider.notifier).loadResume(
                                resume,
                              );
                          context.push(PreviewScreen.routePath);
                        },
                        onDeleteResume: (resume) async {
                          final confirmed = await _showDeleteConfirmationDialog(
                            context,
                            resume: resume,
                            ref: ref,
                          );
                          if (confirmed == true) {
                            ref.invalidate(resumeListProvider);
                          }
                        },
                        confirmDismiss: (resume) =>
                            _showDeleteConfirmationDialog(
                          context,
                          resume: resume,
                          ref: ref,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  HistoryHeroHeader(
                    resumeCount: 0,
                    onProfilePressed: () =>
                        uprofile.UserProfileSheet.show(context),
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            AppLoader(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              error: (error, _) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  HistoryHeroHeader(
                    resumeCount: 0,
                    onProfilePressed: () =>
                        uprofile.UserProfileSheet.show(context),
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.screenPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 72,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Failed to load resumes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error is Failure
                                  ? error.message
                                  : 'Something went wrong. Please try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              text: 'Retry',
                              icon: Icons.refresh_rounded,
                              onPressed: () {
                                ref.invalidate(resumeListProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animated AI Resume button (bottom left)
          Positioned(
            left: 16,
            bottom: 48,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimatedAIButton(
                onPressed: () {
                  ref.read(resumeFormProvider.notifier).reset();
                  ref.invalidate(resumeOptimizationNotifierProvider);
                  context.push(ResumeOptimizerScreen.routePath);
                },
              ),
            ),
          ),
          // New Resume button (bottom right)
          Positioned(
            right: 16,
            bottom: 48,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ref.read(resumeFormProvider.notifier).reset();
                      context.push(BuilderScreen.routePath);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_rounded, color: AppColors.white),
                        SizedBox(width: 8),
                        Text(
                          'New Resume',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context, {
    required Resume resume,
    required WidgetRef ref,
  }) async {
    final title = resume.title.isEmpty ? 'Untitled Resume' : resume.title;
    final confirmed = await DialogManager.confirm(
      context,
      title: 'Delete Resume',
      message: 'Are you sure you want to delete "$title"?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return false;

    final deleteUseCase = ref.read(deleteResumeUseCaseProvider);
    final result = await deleteUseCase(resume.id);

    if (!context.mounted) return false;

    return result.match(
      (failure) async {
        await DialogManager.showFailure(
          context,
          failure: failure,
          onRetry: () async {
            final deleteUseCase = ref.read(deleteResumeUseCaseProvider);
            await deleteUseCase(resume.id);
            ref.invalidate(resumeListProvider);
          },
          title: 'Delete Failed',
        );
        return false;
      },
      (_) async {
        ref.invalidate(resumeListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume deleted successfully.')),
        );
        return true;
      },
    );
  }
}
