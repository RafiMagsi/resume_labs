import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_labs/injection/injection_container.dart';

import '../../../domain/entities/resume.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/resume_list_provider.dart';
import '../../widgets/shared/app_button.dart';
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
        title: const Text('Resume History'),
        centerTitle: true,
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
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 80),
                  const Icon(
                    Icons.description_outlined,
                    size: 72,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No resumes yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first resume and it will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
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

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: resumes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final resume = resumes[index];

                return Dismissible(
                  key: ValueKey(resume.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _showDeleteConfirmationDialog(
                    context,
                    resume: resume,
                    ref: ref,
                  ),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  child: _ResumeHistoryCard(
                    resume: resume,
                    onTap: () {
                      ref.read(resumeFormProvider.notifier).loadResume(resume);
                      context.push(PreviewScreen.routePath);
                    },
                    onEdit: () {
                      ref.read(resumeFormProvider.notifier).loadResume(resume);
                      context.push(BuilderScreen.routePath);
                    },
                    onExport: () {
                      ref.read(resumeFormProvider.notifier).loadResume(resume);
                      context.push(PreviewScreen.routePath);
                    },
                    onDelete: () async {
                      final confirmed = await _showDeleteConfirmationDialog(
                        context,
                        resume: resume,
                        ref: ref,
                      );
                      if (confirmed == true) {
                        ref.invalidate(resumeListProvider);
                      }
                    },
                  ),
                );
              },
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: const [
              SizedBox(height: 40),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 80),
              const Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed to load resumes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
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
                      final deleteUseCase = ref.read(deleteResumeUseCaseProvider);
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
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeHistoryCard extends StatelessWidget {
  final Resume resume;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  const _ResumeHistoryCard({
    required this.resume,
    required this.onTap,
    required this.onEdit,
    required this.onExport,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = resume.title.trim().isEmpty ? 'Untitled Resume' : resume.title.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: () => _showActionSheet(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF6D5EF8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${_formatDateTime(resume.createdAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Modified: ${_formatDateTime(resume.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'export':
                    onExport();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Text('Export'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Export'),
                onTap: () {
                  Navigator.of(context).pop();
                  onExport();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';

  return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute $period';
}
