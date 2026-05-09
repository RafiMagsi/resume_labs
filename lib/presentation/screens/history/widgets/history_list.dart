import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/resume.dart';
import '../../../widgets/resume/resume_card.dart';

class HistoryList extends StatefulWidget {
  final List<Resume> resumes;
  final ValueChanged<Resume> onTapResume;
  final ValueChanged<Resume> onEditResume;
  final ValueChanged<Resume> onExportResume;
  final ValueChanged<Resume> onDeleteResume;
  final Future<bool?> Function(Resume resume) confirmDismiss;

  const HistoryList({
    super.key,
    required this.resumes,
    required this.onTapResume,
    required this.onEditResume,
    required this.onExportResume,
    required this.onDeleteResume,
    required this.confirmDismiss,
  });

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
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
