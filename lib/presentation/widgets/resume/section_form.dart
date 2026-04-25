import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';
import 'add_experience_sheet.dart';

class SectionForm extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  const SectionForm({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.screenSurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class WorkExperienceSectionForm extends StatelessWidget {
  final List<WorkExperience> items;
  final ValueChanged<WorkExperience> onAdd;
  final void Function(int index, WorkExperience item) onUpdate;
  final ValueChanged<int> onRemove;
  final String? errorText;

  const WorkExperienceSectionForm({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return SectionForm(
      title: 'Work Experience',
      subtitle: 'Add your professional roles and impact bullets.',
      trailing: AppButton(
        text: 'Add',
        expand: false,
        icon: Icons.add,
        onPressed: () => AddExperienceSheet.show(
          context,
          onSave: onAdd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const _EmptySectionState(
              message: 'No work experience added yet.',
            )
          else
            ...List.generate(
              items.length,
              (index) => Padding(
                padding:
                    EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
                child: _WorkExperienceCard(
                  item: items[index],
                  onEdit: () => AddExperienceSheet.show(
                    context,
                    initialExperience: items[index],
                    onSave: (value) => onUpdate(index, value),
                  ),
                  onDelete: () => onRemove(index),
                ),
              ),
            ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EducationSectionForm extends StatelessWidget {
  final List<Education> items;
  final ValueChanged<Education> onAdd;
  final void Function(int index, Education item) onUpdate;
  final ValueChanged<int> onRemove;
  final String? errorText;

  const EducationSectionForm({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return SectionForm(
      title: 'Education',
      subtitle: 'Add degrees, schools, graduation dates, and GPA.',
      trailing: AppButton(
        text: 'Add',
        expand: false,
        icon: Icons.add,
        onPressed: () => _showEducationSheet(
          context,
          onSave: onAdd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const _EmptySectionState(
              message: 'No education entries added yet.',
            )
          else
            ...List.generate(
              items.length,
              (index) => Padding(
                padding:
                    EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
                child: _EducationCard(
                  item: items[index],
                  onEdit: () => _showEducationSheet(
                    context,
                    initialValue: items[index],
                    onSave: (value) => onUpdate(index, value),
                  ),
                  onDelete: () => onRemove(index),
                ),
              ),
            ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SkillsSectionForm extends StatefulWidget {
  final List<Skill> items;
  final ValueChanged<Skill> onAdd;
  final void Function(int index, Skill item) onUpdate;
  final ValueChanged<int> onRemove;
  final String? errorText;

  const SkillsSectionForm({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.errorText,
  });

  @override
  State<SkillsSectionForm> createState() => _SkillsSectionFormState();
}

class _SkillsSectionFormState extends State<SkillsSectionForm> {
  @override
  Widget build(BuildContext context) {
    return SectionForm(
      title: 'Skills',
      subtitle: 'Add important technical or professional skills.',
      trailing: AppButton(
        text: 'Add',
        expand: false,
        icon: Icons.add,
        onPressed: () => _showSkillSheet(
          context,
          onSave: widget.onAdd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.items.isEmpty)
            const _EmptySectionState(
              message: 'No skills added yet.',
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                widget.items.length,
                (index) => _SkillChip(
                  item: widget.items[index],
                  onEdit: () => _showSkillSheet(
                    context,
                    initialValue: widget.items[index],
                    onSave: (value) => widget.onUpdate(index, value),
                  ),
                  onDelete: () => widget.onRemove(index),
                ),
              ),
            ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySectionState extends StatelessWidget {
  final String message;

  const _EmptySectionState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _WorkExperienceCard extends StatelessWidget {
  final WorkExperience item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkExperienceCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final duration = _formatDateRange(
      item.startDate,
      item.endDate,
      item.isCurrentRole,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.role,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _ItemActionButtons(
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
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
            duration,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (item.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...item.bulletPoints.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
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
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final Education item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EducationCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final graduation = _formatMonthYear(item.graduationDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.degree,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _ItemActionButtons(
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
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
            'Graduated: $graduation${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final Skill item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SkillChip({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            if (item.category.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.category,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Remove skill ${item.name}',
              child: IconButton(
                tooltip: 'Remove skill',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onDelete,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemActionButtons({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onEdit,
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          tooltip: 'Delete',
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

Future<void> _showEducationSheet(
  BuildContext context, {
  Education? initialValue,
  required ValueChanged<Education> onSave,
}) async {
  final schoolController =
      TextEditingController(text: initialValue?.school ?? '');
  final degreeController =
      TextEditingController(text: initialValue?.degree ?? '');
  final fieldController =
      TextEditingController(text: initialValue?.field ?? '');
  final graduationDateController = TextEditingController(
    text: initialValue != null
        ? _formatDateForInput(initialValue.graduationDate)
        : '',
  );
  final gpaController = TextEditingController(
    text: initialValue?.gpa?.toString() ?? '',
  );

  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.screenSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      Future<void> pickDate() async {
        final initialDate =
            DateTime.tryParse(graduationDateController.text) ?? DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1970),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          graduationDateController.text = _formatDateForInput(date);
        }
      }

      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  initialValue == null ? 'Add Education' : 'Edit Education',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: schoolController,
                  labelText: 'School',
                  validator: _requiredValidator('School is required'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: degreeController,
                  labelText: 'Degree',
                  validator: _requiredValidator('Degree is required'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: fieldController,
                  labelText: 'Field of Study',
                  validator: _requiredValidator('Field is required'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: graduationDateController,
                  labelText: 'Graduation Date (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                  validator: _dateValidator('Graduation date is required'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: gpaController,
                  labelText: 'GPA (optional)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    if (double.tryParse(text) == null) {
                      return 'Enter a valid GPA';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: initialValue == null
                      ? 'Save Education'
                      : 'Update Education',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    onSave(
                      Education(
                        school: schoolController.text.trim(),
                        degree: degreeController.text.trim(),
                        field: fieldController.text.trim(),
                        graduationDate: DateTime.parse(
                            graduationDateController.text.trim()),
                        gpa: gpaController.text.trim().isEmpty
                            ? null
                            : double.parse(gpaController.text.trim()),
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showSkillSheet(
  BuildContext context, {
  Skill? initialValue,
  required ValueChanged<Skill> onSave,
}) async {
  final nameController = TextEditingController(text: initialValue?.name ?? '');
  final categoryController =
      TextEditingController(text: initialValue?.category ?? '');
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.screenSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  initialValue == null ? 'Add Skill' : 'Edit Skill',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: nameController,
                  labelText: 'Skill Name',
                  validator: _requiredValidator('Skill name is required'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: categoryController,
                  labelText: 'Category',
                  validator: _requiredValidator('Category is required'),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: initialValue == null ? 'Save Skill' : 'Update Skill',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    onSave(
                      Skill(
                        name: nameController.text.trim(),
                        category: categoryController.text.trim(),
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String? Function(String?) _requiredValidator(String message) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  };
}

String? Function(String?) _dateValidator(String message) {
  return (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return message;
    try {
      DateTime.parse(text);
      return null;
    } catch (_) {
      return 'Use YYYY-MM-DD format';
    }
  };
}

String _formatDateForInput(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
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

