import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/work_experience.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

class AddExperienceSheet extends StatefulWidget {
  final WorkExperience? initialExperience;
  final ValueChanged<WorkExperience> onSave;
  final Future<String?> Function(String bullet)? onImproveBullet;
  final bool isAiLoading;

  const AddExperienceSheet({
    super.key,
    this.initialExperience,
    required this.onSave,
    this.onImproveBullet,
    this.isAiLoading = false,
  });

  static Future<void> show(
    BuildContext context, {
    WorkExperience? initialExperience,
    required ValueChanged<WorkExperience> onSave,
    Future<String?> Function(String bullet)? onImproveBullet,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.screenSurface,
      builder: (_) => AddExperienceSheet(
        initialExperience: initialExperience,
        onSave: onSave,
        onImproveBullet: onImproveBullet,
      ),
    );
  }

  @override
  State<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<AddExperienceSheet> {
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _bulletController;
  late DateTime _startDate;
  late DateTime? _endDate;
  late bool _isCurrentRole;
  late List<String> _bullets;
  bool _isImprovingBullet = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.initialExperience;

    _roleController = TextEditingController(text: exp?.role ?? '');
    _companyController = TextEditingController(text: exp?.company ?? '');
    _locationController = TextEditingController(text: exp?.location ?? '');
    _descriptionController = TextEditingController(
      text: exp?.bulletPoints.join('\n') ?? '',
    );
    _bulletController = TextEditingController();
    _bullets = [...?exp?.bulletPoints];
    _startDate = exp?.startDate ?? DateTime.now();
    _endDate = exp?.endDate;
    _isCurrentRole = exp?.isCurrentRole ?? false;
  }

  @override
  void dispose() {
    _roleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _bulletController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_roleController.text.trim().isEmpty ||
        _companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    List<String> bullets;
    if (_bullets.isNotEmpty) {
      bullets = _bullets;
    } else {
      bullets = _descriptionController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final experience = WorkExperience(
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      location: _locationController.text.trim(),
      startDate: _startDate,
      endDate: _isCurrentRole ? null : _endDate,
      bulletPoints: bullets,
      isCurrentRole: _isCurrentRole,
    );

    widget.onSave(experience);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialExperience == null
                  ? 'Add Work Experience'
                  : 'Edit Work Experience',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _roleController,
              labelText: 'Job Title',
              hintText: 'e.g., Senior Developer',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _companyController,
              labelText: 'Company',
              hintText: 'e.g., Tech Corp',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              labelText: 'Location',
              hintText: 'e.g., San Francisco, CA',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, (date) {
                          setState(() => _startDate = date);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_startDate.month}/${_startDate.day}/${_startDate.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isCurrentRole
                            ? null
                            : () => _selectDate(context, (date) {
                                  setState(() => _endDate = date);
                                }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isCurrentRole
                                  ? AppColors.border.withValues(alpha: 0.5)
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: _isCurrentRole
                                ? AppColors.secondarySurface
                                : Colors.transparent,
                          ),
                          child: Text(
                            _isCurrentRole
                                ? 'Present'
                                : _endDate != null
                                    ? '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'
                                    : 'Select',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isCurrentRole
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isCurrentRole,
                  onChanged: (value) {
                    setState(() => _isCurrentRole = value ?? false);
                  },
                ),
                const Text(
                  'I currently work here',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.onImproveBullet == null)
              AppTextField(
                controller: _descriptionController,
                labelText: 'Responsibilities',
                hintText: 'One per line\nLeading cross-functional teams\nImproved app performance',
                maxLines: 4,
                textInputAction: TextInputAction.done,
              )
            else
              _buildAdvancedBulletUI(),
            const SizedBox(height: 24),
            AppButton(
              text: 'Save Experience',
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedBulletUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsibilities',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _bulletController,
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
                  isLoading: _isImprovingBullet,
                  onPressed: (widget.onImproveBullet == null ||
                          _isImprovingBullet)
                      ? null
                      : () async {
                          final text = _bulletController.text.trim();
                          if (text.isEmpty) return;

                          setState(() => _isImprovingBullet = true);
                          try {
                            final improved =
                                await widget.onImproveBullet!(text);
                            if (improved == null ||
                                improved.trim().isEmpty ||
                                !context.mounted) {
                              return;
                            }

                            _bulletController.text = improved;
                            _bulletController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _bulletController.text.length),
                            );
                          } finally {
                            if (context.mounted) {
                              setState(() => _isImprovingBullet = false);
                            }
                          }
                        },
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: 'Add',
                  expand: false,
                  onPressed: () {
                    final text = _bulletController.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _bullets.add(text);
                      _bulletController.clear();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        if (_bullets.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(
            _bullets.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _bullets[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove bullet',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      setState(() {
                        _bullets.removeAt(index);
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
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

  Future<void> _selectDate(
    BuildContext context,
    ValueChanged<DateTime> onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
