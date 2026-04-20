import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import 'resume_paper.dart';

class ResumePreview extends StatelessWidget {
  final String? photoUrl;
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const ResumePreview({
    super.key,
    required this.photoUrl,
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final pagePadding = MediaQuery.sizeOf(context).width < 380 ? 18.0 : 24.0;
    return ResumePaper(
      maxWidth: 900,
      padding: EdgeInsets.all(pagePadding),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PreviewAvatar(photoUrl: photoUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title.trim().isEmpty ? 'Untitled Resume' : title.trim(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 1,
              color: AppColors.divider,
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Professional Summary',
              child: Text(
                personalSummary.trim().isEmpty
                    ? 'Your personal summary will appear here.'
                    : personalSummary.trim(),
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Work Experience',
              child: workExperiences.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No work experience added yet.',
                    )
                  : Column(
                      children: workExperiences
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PreviewWorkExperienceItem(item: item),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Education',
              child: educations.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No education added yet.',
                    )
                  : Column(
                      children: educations
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PreviewEducationItem(item: item),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _PreviewSection(
              title: 'Skills',
              child: skills.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No skills added yet.',
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondarySurface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                skill.category.trim().isEmpty
                                    ? skill.name
                                    : '${skill.name} • ${skill.category}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewAvatar extends StatelessWidget {
  final String? photoUrl;

  const _PreviewAvatar({
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    if (url.isEmpty) {
      return _placeholder();
    }

    final image = url.startsWith('http')
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : Image.file(
            File(url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.secondarySurface,
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.secondarySurface,
      ),
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 28,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _PreviewEmptyState extends StatelessWidget {
  final String message;

  const _PreviewEmptyState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _PreviewWorkExperienceItem extends StatelessWidget {
  final WorkExperience item;

  const _PreviewWorkExperienceItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        _formatDateRange(item.startDate, item.endDate, item.isCurrentRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.role,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.company} • ${item.location}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        if (item.bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...item.bulletPoints.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewEducationItem extends StatelessWidget {
  final Education item;

  const _PreviewEducationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.degree,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.school} • ${item.field}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

String _formatMonthYear(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
  final startText = _formatMonthYear(start);
  final endText =
      isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
  return '$startText - $endText';
}
