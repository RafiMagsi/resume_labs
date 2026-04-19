import 'package:flutter/material.dart';

import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
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
  final Future<String?> Function(String bullet)? onImproveBullet;

  const WorkExperienceSectionForm({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.errorText,
    this.onImproveBullet,
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
        onPressed: () => _showWorkExperienceSheet(
          context,
          onSave: onAdd,
          onImproveBullet: onImproveBullet,
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
                padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
                child: _WorkExperienceCard(
                  item: items[index],
                  onEdit: () => _showWorkExperienceSheet(
                    context,
                    initialValue: items[index],
                    onSave: (value) => onUpdate(index, value),
                    onImproveBullet: onImproveBullet,
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
                color: Color(0xFFDC2626),
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
                padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
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
                color: Color(0xFFDC2626),
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
  final Future<List<String>?> Function()? onSuggestSkills;
  final ValueChanged<String>? onAcceptSuggestedSkill;

  const SkillsSectionForm({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.errorText,
    this.onSuggestSkills,
    this.onAcceptSuggestedSkill,
  });

  @override
  State<SkillsSectionForm> createState() => _SkillsSectionFormState();
}

class _SkillsSectionFormState extends State<SkillsSectionForm> {
  bool _isSuggesting = false;

  @override
  Widget build(BuildContext context) {
    return SectionForm(
      title: 'Skills',
      subtitle: 'Add important technical or professional skills.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            text: 'Suggest',
            expand: false,
            variant: AppButtonVariant.secondary,
            icon: Icons.auto_awesome_rounded,
            isLoading: _isSuggesting,
            onPressed: (widget.onSuggestSkills == null || _isSuggesting)
                ? null
                : () async {
	                    setState(() => _isSuggesting = true);
	                    try {
	                      final results = await widget.onSuggestSkills!.call();
	                      if (!context.mounted) return;
	                      if (results == null || results.isEmpty) return;

	                      await _showSuggestedSkillsDialog(
	                        context,
	                        suggestions: results,
	                        onAccept: (skillName) {
                          if (widget.onAcceptSuggestedSkill != null) {
                            widget.onAcceptSuggestedSkill!(skillName);
                          }
                        },
                      );
                    } finally {
                      if (mounted) setState(() => _isSuggesting = false);
                    }
                  },
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Add',
            expand: false,
            icon: Icons.add,
            onPressed: () => _showSkillSheet(
              context,
              onSave: widget.onAdd,
            ),
          ),
        ],
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
                color: Color(0xFFDC2626),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF64748B),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    color: Color(0xFF0F172A),
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
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
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
                        color: Color(0xFF6D5EF8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF334155),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    color: Color(0xFF0F172A),
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
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Graduated: $graduation${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
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
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD8B4FE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B21B6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFF7C3AED),
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
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}

Future<void> _showWorkExperienceSheet(
  BuildContext context, {
  WorkExperience? initialValue,
  required ValueChanged<WorkExperience> onSave,
  Future<String?> Function(String bullet)? onImproveBullet,
}) async {
  final companyController = TextEditingController(text: initialValue?.company ?? '');
  final roleController = TextEditingController(text: initialValue?.role ?? '');
  final locationController = TextEditingController(text: initialValue?.location ?? '');
  final startDateController = TextEditingController(
    text: initialValue != null ? _formatDateForInput(initialValue.startDate) : '',
  );
  final endDateController = TextEditingController(
    text: initialValue?.endDate != null
        ? _formatDateForInput(initialValue!.endDate!)
        : '',
  );
  final bulletController = TextEditingController();
  final bullets = [...?initialValue?.bulletPoints];
  final formKey = GlobalKey<FormState>();
  bool isCurrentRole = initialValue?.isCurrentRole ?? false;
  bool isImprovingBullet = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickDate(TextEditingController controller) async {
            final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = _formatDateForInput(date);
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
                      initialValue == null ? 'Add Work Experience' : 'Edit Work Experience',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: companyController,
                      labelText: 'Company',
                      validator: _requiredValidator('Company is required'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: roleController,
                      labelText: 'Role',
                      validator: _requiredValidator('Role is required'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: locationController,
                      labelText: 'Location',
                      validator: _requiredValidator('Location is required'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: startDateController,
                      labelText: 'Start Date (YYYY-MM-DD)',
                      suffixIcon: IconButton(
                        onPressed: () => pickDate(startDateController),
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                      validator: _dateValidator('Start date is required'),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      value: isCurrentRole,
                      onChanged: (value) {
                        setState(() {
                          isCurrentRole = value;
                          if (value) {
                            endDateController.clear();
                          }
                        });
                      },
                      title: const Text('This is my current role'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: endDateController,
                      labelText: 'End Date (YYYY-MM-DD)',
                      enabled: !isCurrentRole,
                      suffixIcon: IconButton(
                        onPressed: isCurrentRole
                            ? null
                            : () => pickDate(endDateController),
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                      validator: isCurrentRole
                          ? null
                          : _dateValidator('End date is required'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: bulletController,
                            labelText: 'Impact bullet',
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            AppButton(
                              text: 'AI',
                              expand: false,
                              variant: AppButtonVariant.secondary,
                              icon: Icons.auto_awesome_rounded,
                              isLoading: isImprovingBullet,
                              onPressed: (onImproveBullet == null || isImprovingBullet)
                                  ? null
                                  : () async {
                                      final text = bulletController.text.trim();
                                      if (text.isEmpty) return;

                                      setState(() => isImprovingBullet = true);
                                      try {
                                        final improved = await onImproveBullet(text);
                                        if (improved == null ||
                                            improved.trim().isEmpty ||
                                            !context.mounted) {
                                          return;
                                        }

                                        bulletController.text = improved;
                                        bulletController.selection =
                                            TextSelection.fromPosition(
                                          TextPosition(offset: bulletController.text.length),
                                        );
                                      } finally {
                                        if (context.mounted) {
                                          setState(() => isImprovingBullet = false);
                                        }
                                      }
                                    },
                            ),
                            const SizedBox(height: 8),
                            AppButton(
                              text: 'Add',
                              expand: false,
                              onPressed: () {
                                final text = bulletController.text.trim();
                                if (text.isEmpty) return;
                                setState(() {
                                  bullets.add(text);
                                  bulletController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (bullets.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ...List.generate(
                        bullets.length,
                        (index) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(bullets[index]),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                bullets.removeAt(index);
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppButton(
                      text: initialValue == null ? 'Save Experience' : 'Update Experience',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        onSave(
                          WorkExperience(
                            company: companyController.text.trim(),
                            role: roleController.text.trim(),
                            location: locationController.text.trim(),
                            startDate: DateTime.parse(startDateController.text.trim()),
                            endDate: isCurrentRole
                                ? null
                                : DateTime.parse(endDateController.text.trim()),
                            bulletPoints: bullets,
                            isCurrentRole: isCurrentRole,
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
    },
  );
}

Future<void> _showEducationSheet(
  BuildContext context, {
  Education? initialValue,
  required ValueChanged<Education> onSave,
}) async {
  final schoolController = TextEditingController(text: initialValue?.school ?? '');
  final degreeController = TextEditingController(text: initialValue?.degree ?? '');
  final fieldController = TextEditingController(text: initialValue?.field ?? '');
  final graduationDateController = TextEditingController(
    text: initialValue != null ? _formatDateForInput(initialValue.graduationDate) : '',
  );
  final gpaController = TextEditingController(
    text: initialValue?.gpa?.toString() ?? '',
  );

  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  text: initialValue == null ? 'Save Education' : 'Update Education',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    onSave(
                      Education(
                        school: schoolController.text.trim(),
                        degree: degreeController.text.trim(),
                        field: fieldController.text.trim(),
                        graduationDate:
                            DateTime.parse(graduationDateController.text.trim()),
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
    backgroundColor: Colors.white,
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
  final endText = isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
  return '$startText - $endText';
}

Future<void> _showSuggestedSkillsDialog(
  BuildContext context, {
  required List<String> suggestions,
  required ValueChanged<String> onAccept,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Skill Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            ...suggestions.map(
              (skill) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Accept',
                        expand: false,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onAccept(skill);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'Dismiss',
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
