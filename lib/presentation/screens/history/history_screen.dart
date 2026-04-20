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
import '../../widgets/shared/app_button.dart';
import '../../widgets/resume/resume_card.dart';
import '../resume_builder/builder_screen.dart';
import '../resume_builder/preview_screen.dart';
import '../../widgets/shared/error_dialog.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const String routeName = 'history';
  static const String routePath = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeListState = ref.watch(resumeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(resumeListProvider);
          await ref.read(resumeListProvider.future);
        },
        child: resumeListState.when(
          data: (resumes) {
            if (resumes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  const SizedBox(height: 80),
                  const Icon(
                    Icons.description_outlined,
                    size: 72,
                    color: AppColors.textTertiary,
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
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Create New Resume',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      ref.read(resumeFormProvider.notifier).reset();
                      context.push(BuilderScreen.routePath);
                    },
                  ),
                ],
              );
            }

            return _HistoryList(
              resumes: resumes,
              onTapResume: (resume) {
                ref.read(resumeFormProvider.notifier).loadResume(resume);
                context.push(PreviewScreen.routePath);
              },
              onEditResume: (resume) {
                ref.read(resumeFormProvider.notifier).loadResume(resume);
                context.push(BuilderScreen.routePath);
              },
              onExportResume: (resume) {
                ref.read(resumeFormProvider.notifier).loadResume(resume);
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
              confirmDismiss: (resume) => _showDeleteConfirmationDialog(
                context,
                resume: resume,
                ref: ref,
              ),
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.lg),
            children: const [
              SizedBox(height: 40),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(resumeFormProvider.notifier).reset();
          context.push(BuilderScreen.routePath);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Resume'),
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

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.lg),
      itemCount: filtered.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SearchBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          );
        }

        final resume = filtered[index - 1];

        return Dismissible(
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
            onEdit: () => widget.onEditResume(resume),
            onExport: () => widget.onExportResume(resume),
            onDelete: () => widget.onDeleteResume(resume),
          ),
        );
      },
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(10),
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
