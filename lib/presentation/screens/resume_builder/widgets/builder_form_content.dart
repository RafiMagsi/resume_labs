import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../providers/resume/resume_form_provider.dart';
import '../../../widgets/resume/section_form.dart';
import '../../../widgets/shared/app_text_field.dart';
import '../../../widgets/shared/photo_picker.dart';
import 'builder_actions.dart';
import 'builder_step_header.dart';

class BuilderFormContent extends StatelessWidget {
  final ResumeFormState formState;
  final ResumeFormNotifier formNotifier;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController websiteController;
  final TextEditingController linkedinController;
  final TextEditingController githubController;
  final TextEditingController dobController;
  final TextEditingController nationalityController;
  final TextEditingController titleController;
  final TextEditingController summaryController;
  final FocusNode fullNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode titleFocusNode;
  final FocusNode summaryFocusNode;
  final bool isAiLoading;
  final Future<void> Function() onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;
  final Future<void> Function(String path) onPhotoUpload;

  const BuilderFormContent({
    super.key,
    required this.formState,
    required this.formNotifier,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.locationController,
    required this.websiteController,
    required this.linkedinController,
    required this.githubController,
    required this.dobController,
    required this.nationalityController,
    required this.titleController,
    required this.summaryController,
    required this.fullNameFocusNode,
    required this.emailFocusNode,
    required this.titleFocusNode,
    required this.summaryFocusNode,
    required this.isAiLoading,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onPhotoUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuilderStepHeader(currentStep: formState.currentStep),
        const SizedBox(height: 20),
        _buildCurrentStep(),
        const SizedBox(height: 20),
        BuilderActions(
          currentStep: formState.currentStep,
          isLoading: formState.isLoading,
          onBack: onBack,
          onNext: onNext,
          onSave: onSave,
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (formState.currentStep) {
      case 0:
        return SectionForm(
          title: 'Personal Information',
          subtitle: 'Add your contact details, resume title, and summary.',
          child: Column(
            children: [
              PhotoPicker(
                photoUrl: formState.photoUrl,
                onPickPhoto: onPhotoUpload,
                onRemovePhoto: () {
                  formNotifier.updatePhotoUrl(null);
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoColumn = constraints.maxWidth >= 560;

                  final fields = <Widget>[
                    AppTextField(
                      controller: fullNameController,
                      labelText: 'Full Name',
                      hintText: 'e.g. John Mathew',
                      focusNode: fullNameFocusNode,
                      nextFocusNode: emailFocusNode,
                      onChanged: formNotifier.updateContactFullName,
                      autofillHints: const [AutofillHints.name],
                    ),
                    AppTextField(
                      controller: emailController,
                      labelText: 'Email',
                      hintText: 'e.g. john@email.com',
                      keyboardType: TextInputType.emailAddress,
                      focusNode: emailFocusNode,
                      onChanged: formNotifier.updateContactEmail,
                      autofillHints: const [AutofillHints.email],
                    ),
                    AppTextField(
                      controller: phoneController,
                      labelText: 'Phone',
                      hintText: 'e.g. +1 555 123 4567',
                      keyboardType: TextInputType.phone,
                      onChanged: formNotifier.updateContactPhone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    AppTextField(
                      controller: locationController,
                      labelText: 'Location',
                      hintText: 'e.g. Dubai',
                      onChanged: formNotifier.updateContactLocation,
                      autofillHints: const [AutofillHints.fullStreetAddress],
                    ),
                    AppTextField(
                      controller: websiteController,
                      labelText: 'Website',
                      hintText: 'e.g. dropticks.com',
                      keyboardType: TextInputType.url,
                      onChanged: formNotifier.updateContactWebsite,
                    ),
                    AppTextField(
                      controller: linkedinController,
                      labelText: 'LinkedIn',
                      hintText: 'e.g. linkedin.com/in/username',
                      keyboardType: TextInputType.url,
                      onChanged: formNotifier.updateContactLinkedin,
                    ),
                    AppTextField(
                      controller: githubController,
                      labelText: 'GitHub',
                      hintText: 'e.g. github.com/username',
                      keyboardType: TextInputType.url,
                      onChanged: formNotifier.updateContactGithub,
                    ),
                    AppTextField(
                      controller: dobController,
                      labelText: 'Date of Birth (Optional)',
                      hintText: 'e.g. 01/01/1990',
                      keyboardType: TextInputType.datetime,
                      onChanged: formNotifier.updateContactDateOfBirth,
                    ),
                    AppTextField(
                      controller: nationalityController,
                      labelText: 'Nationality (Optional)',
                      hintText: 'e.g. Canadian',
                      onChanged: formNotifier.updateContactNationality,
                    ),
                  ];

                  if (!isTwoColumn) {
                    return Column(
                      children: [
                        ...fields
                            .expand((w) => [w, const SizedBox(height: 14)]),
                      ]..removeLast(),
                    );
                  }

                  final left = <Widget>[];
                  final right = <Widget>[];
                  for (var i = 0; i < fields.length; i++) {
                    (i.isEven ? left : right).add(fields[i]);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ...left.expand(
                              (w) => [w, const SizedBox(height: 14)],
                            ),
                          ]..removeLast(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            ...right.expand(
                              (w) => [w, const SizedBox(height: 14)],
                            ),
                          ]..removeLast(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: titleController,
                labelText: 'Resume Title',
                hintText: 'e.g. Senior Flutter Developer',
                validator: InputValidators.requiredField,
                focusNode: titleFocusNode,
                nextFocusNode: summaryFocusNode,
                onChanged: formNotifier.updateTitle,
              ),
              if (formState.validationErrors['title'] != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formState.validationErrors['title']!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                controller: summaryController,
                labelText: 'Personal Summary',
                hintText: 'Write a short professional summary',
                maxLines: 5,
                minLines: 5,
                textInputAction: TextInputAction.newline,
                validator: InputValidators.requiredField,
                focusNode: summaryFocusNode,
                onChanged: formNotifier.updatePersonalSummary,
              ),
              if (formState.validationErrors['personalSummary'] != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formState.validationErrors['personalSummary']!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

      case 1:
        return WorkExperienceSectionForm(
          items: formState.workExperiences,
          errorText: formState.validationErrors['workExperiences'],
          onAdd: formNotifier.addWorkExperience,
          onUpdate: formNotifier.updateWorkExperience,
          onRemove: formNotifier.removeWorkExperience,
        );

      case 2:
        return EducationSectionForm(
          items: formState.educations,
          errorText: formState.validationErrors['educations'],
          onAdd: formNotifier.addEducation,
          onUpdate: formNotifier.updateEducation,
          onRemove: formNotifier.removeEducation,
        );

      case 3:
        return SkillsSectionForm(
          items: formState.skills,
          errorText: formState.validationErrors['skills'],
          onAdd: formNotifier.addSkill,
          onUpdate: formNotifier.updateSkill,
          onRemove: formNotifier.removeSkill,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
