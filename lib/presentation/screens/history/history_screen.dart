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
import '../../widgets/resume/resume_card.dart';
import '../resume_builder/builder_screen.dart';
import '../resume_builder/preview_screen.dart';
import '../resume_detail/resume_detail_screen.dart';
import '../resume_optimizer/resume_optimizer_screen.dart';
import '../../widgets/shared/error_dialog.dart';
import '../../widgets/shared/animated_ai_button.dart';
import '../../widgets/shared/user_profile_sheet.dart' as uprofile;

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
                      _HeroHeader(resumeCount: resumes.length),
                      SliverFillRemaining(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSizes.screenPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            const SizedBox(height: 60),
                            Container(
                              width: 88,
                              height: 88,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.cardHeaderStart,
                                    AppColors.cardHeaderEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(44),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.cardHeaderStart
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                size: 40,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No resumes yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your first resume and it will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: 'Create New Resume',
                              icon: Icons.add_rounded,
                              onPressed: () {
                                ref.read(resumeFormProvider.notifier).reset();
                                context.push(BuilderScreen.routePath);
                              },
                            ),
                              ],
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
                    _HeroHeader(resumeCount: resumes.length),
                    SliverToBoxAdapter(
                      child: _HistoryList(
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
                  _HeroHeader(resumeCount: 0),
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
                  _HeroHeader(resumeCount: 0),
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
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text(
          'Are you sure you want to delete "${resume.title.isEmpty ? 'Untitled Resume' : resume.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final deleteUseCase = ref.read(deleteResumeUseCaseProvider);
              final result = await deleteUseCase(resume.id);

              if (!context.mounted) return;

              result.match(
                (failure) async {
                  Navigator.of(context).pop(false);
                  await ErrorDialog.show(
                    context,
                    failure: failure,
                    onRetry: () async {
                      final deleteUseCase =
                          ref.read(deleteResumeUseCaseProvider);
                      await deleteUseCase(resume.id);
                      ref.invalidate(resumeListProvider);
                    },
                    title: 'Delete Failed',
                  );
                },
                (_) async {
                  Navigator.of(context).pop(true);
                  ref.invalidate(resumeListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resume deleted successfully.'),
                    ),
                  );
                },
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero header widget with gradient background for the resume list.
class _HeroHeader extends StatelessWidget {
  final int resumeCount;

  const _HeroHeader({required this.resumeCount});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient background with accent line
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.heroBannerStart,
                    AppColors.heroBannerEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Shimmer accent line at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.heroShimmerLine.withValues(alpha: 0),
                            AppColors.heroShimmerLine,
                            AppColors.heroShimmerLine.withValues(alpha: 0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Title at bottom
            Positioned(
              bottom: 16,
              left: AppSizes.screenPadding,
              right: AppSizes.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Resumes',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  // Resume count badge
                  if (resumeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.heroBadgeSurface,
                        border: Border.all(color: AppColors.heroBadgeBorder),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$resumeCount resume${resumeCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_rounded, color: AppColors.white),
          onPressed: () => uprofile.UserProfileSheet.show(context),
          tooltip: 'Account',
        ),
      ],
    );
  }
}

class _HistoryList extends StatefulWidget {
  final List<Resume> resumes;
  final ValueChanged<Resume> onTapResume;
  final ValueChanged<Resume> onEditResume;
  final ValueChanged<Resume> onExportResume;
  final ValueChanged<Resume> onDeleteResume;
  final Future<bool?> Function(Resume resume) confirmDismiss;

  const _HistoryList({
    required this.resumes,
    required this.onTapResume,
    required this.onEditResume,
    required this.onExportResume,
    required this.onDeleteResume,
    required this.confirmDismiss,
  });

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? widget.resumes
        : widget.resumes
            .where(
              (r) => r.title.trim().toLowerCase().contains(query),
            )
            .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        120,
      ),
      child: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            filtered.length,
            (index) {
              final resume = filtered[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < filtered.length - 1 ? 12 : 0,
                ),
                child: Dismissible(
                  key: ValueKey(resume.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => widget.confirmDismiss(resume),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.white,
                    ),
                  ),
                  child: ResumeCard(
                    resume: resume,
                    onOpen: () => widget.onTapResume(resume),
                    onEditSteps: () => widget.onEditResume(resume),
                    onExport: () => widget.onExportResume(resume),
                    onDelete: () => widget.onDeleteResume(resume),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search resumes',
              ),
            ),
          ),
          if (controller.text.trim().isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
