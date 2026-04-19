import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/domain/entities/skill.dart';

import '../../../core/utils/input_validators.dart';
import '../../../core/errors/failure.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../widgets/resume/resume_preview.dart';
import '../../widgets/resume/section_form.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../../providers/ai/ai_suggestions_provider.dart';
import '../../widgets/ai/ai_suggestion_dialog.dart';
import '../../widgets/shared/error_dialog.dart';

class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key});

  static const String routeName = 'builder';
  static const String routePath = '/builder';

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _summaryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authProvider).valueOrNull;
      final notifier = ref.read(resumeFormProvider.notifier);
      final state = ref.read(resumeFormProvider);

      if (state.userId == null && authUser != null) {
        notifier.reset(userId: authUser.uid);
      }

      _syncControllers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _titleFocusNode.dispose();
    _summaryFocusNode.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final state = ref.read(resumeFormProvider);

    if (_titleController.text != state.title) {
      _titleController.text = state.title;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: _titleController.text.length),
      );
    }

    if (_summaryController.text != state.personalSummary) {
      _summaryController.text = state.personalSummary;
      _summaryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _summaryController.text.length),
      );
    }
  }

  Future<void> _handleNext() async {
    final notifier = ref.read(resumeFormProvider.notifier);
    final isValid = notifier.validateCurrentStep();

    if (!isValid) {
      _showErrorDialog(
        title: 'Validation Error',
        message: 'Please fix the required fields before continuing.',
      );
      return;
    }

    notifier.nextStep();
  }

  void _handleBack() {
    ref.read(resumeFormProvider.notifier).previousStep();
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(resumeFormProvider.notifier);
    final success = await notifier.save();

    final state = ref.read(resumeFormProvider);
    if (!mounted) return;

    if (!success) {
      _showErrorDialog(
        title: 'Save Failed',
        message: state.errorMessage ?? 'Unable to save resume.',
      );
      return;
    }

    _showSuccessDialog(
      title: 'Success',
      message: state.successMessage ?? 'Resume saved successfully.',
    );
  }

  Future<void> _handleGenerateSummary() async {
    final formState = ref.read(resumeFormProvider);

    final allBullets = formState.workExperiences
        .expand((e) => e.bulletPoints)
        .toList();

    if (allBullets.isEmpty) {
      await _showErrorDialog(
        title: 'Missing Work Experience',
        message: 'Add work experience bullets first so AI can generate a meaningful summary.',
      );
      return;
    }

    await ref.read(aiSuggestionsProvider.notifier).generateSummary(
          jobTitle: formState.title.trim().isEmpty
              ? 'Professional Resume'
              : formState.title.trim(),
          skills: formState.skills.map((e) => e.name).toList(),
          workHighlights: allBullets,
        );

    final aiState = ref.read(aiSuggestionsProvider);
    final suggestion = aiState.valueOrNull?.generatedSummary;

    if (!mounted) return;

    if (suggestion == null || suggestion.trim().isEmpty) {
      final failure = aiState.error is Failure
          ? aiState.error as Failure
          : const ServerFailure('Unable to generate AI summary.');
      await ErrorDialog.show(
        context,
        failure: failure,
        onRetry: _handleGenerateSummary,
        title: 'AI Suggestion Failed',
      );
      return;
    }

    await AiSuggestionDialog.show(
      context,
      title: 'Generated Personal Summary',
      description: 'Review the AI-generated summary before applying it.',
      suggestion: suggestion,
      acceptText: 'Use Summary',
      onAccept: () {
        ref.read(resumeFormProvider.notifier).updatePersonalSummary(suggestion);
        _summaryController.text = suggestion;
        _summaryController.selection = TextSelection.fromPosition(
          TextPosition(offset: _summaryController.text.length),
        );
      },
    );
  }

  Future<String?> _handleImproveBullet(String bullet) async {
    await ref.read(aiSuggestionsProvider.notifier).improveBullet(
          bullet: bullet,
          jobTitle: ref.read(resumeFormProvider).title.trim(),
        );

    final aiState = ref.read(aiSuggestionsProvider);
    final suggestion = aiState.valueOrNull?.improvedBullet;

    if (!mounted) return null;

    if (suggestion == null || suggestion.trim().isEmpty) {
      final failure = aiState.error is Failure
          ? aiState.error as Failure
          : const ServerFailure('Unable to improve bullet.');
      await ErrorDialog.show(
        context,
        failure: failure,
        onRetry: () async => _handleImproveBullet(bullet),
        title: 'AI Suggestion Failed',
      );
      return null;
    }

    String? acceptedValue;
    await AiSuggestionDialog.show(
      context,
      title: 'Improved Bullet Point',
      description: 'Review the improved bullet before applying it.',
      suggestion: suggestion,
      acceptText: 'Use Bullet',
      onAccept: () {
        acceptedValue = suggestion;
      },
    );

    return acceptedValue;
  }

  Future<List<String>?> _handleSuggestSkills() async {
    final formState = ref.read(resumeFormProvider);

    await ref.read(aiSuggestionsProvider.notifier).suggestSkills(
          jobTitle: formState.title.trim().isEmpty
              ? 'Professional Resume'
              : formState.title.trim(),
          existingSkills: formState.skills.map((e) => e.name).toList(),
          personalSummary: formState.personalSummary,
        );

    final aiState = ref.read(aiSuggestionsProvider);
    final suggestions = aiState.valueOrNull?.suggestedSkills ?? [];

    if (!mounted) return null;

    if (suggestions.isEmpty) {
      final failure = aiState.error is Failure
          ? aiState.error as Failure
          : const ServerFailure('Unable to suggest skills.');
      await ErrorDialog.show(
        context,
        failure: failure,
        onRetry: _handleSuggestSkills,
        title: 'AI Suggestion Failed',
      );
      return null;
    }

    return suggestions;
  }

  Future<void> _showErrorDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Info';
      case 1:
        return 'Work Experience';
      case 2:
        return 'Education';
      case 3:
        return 'Skills';
      default:
        return 'Resume Builder';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(resumeFormProvider);
    final formNotifier = ref.read(resumeFormProvider.notifier);
    final aiState = ref.watch(aiSuggestionsProvider);
    final isAiLoading = aiState.isLoading;

    _syncControllers();

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(formState.currentStep)),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: formState.isLoading,
        message: formState.isEditing ? 'Updating resume...' : 'Saving resume...',
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortestSide = MediaQuery.sizeOf(context).shortestSide;
                final isWide = constraints.maxWidth >= 980 || shortestSide >= 720;

                final formContent = _BuilderFormContent(
                  formState: formState,
                  formNotifier: formNotifier,
                  titleController: _titleController,
                  summaryController: _summaryController,
                  titleFocusNode: _titleFocusNode,
                  summaryFocusNode: _summaryFocusNode,
                  isAiLoading: isAiLoading,
                  onNext: _handleNext,
                  onBack: _handleBack,
                  onSave: _handleSave,
                  onGenerateSummary: _handleGenerateSummary,
                  onImproveBullet: _handleImproveBullet,
                  onSuggestSkills: _handleSuggestSkills,
                );

                final preview = ResumePreview(
                  title: formState.title,
                  personalSummary: formState.personalSummary,
                  workExperiences: formState.workExperiences,
                  educations: formState.educations,
                  skills: formState.skills,
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(20),
                          child: formContent,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                          child: preview,
                        ),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      formContent,
                      const SizedBox(height: 20),
                      preview,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BuilderFormContent extends StatelessWidget {
  final ResumeFormState formState;
  final ResumeFormNotifier formNotifier;
  final TextEditingController titleController;
  final TextEditingController summaryController;
  final FocusNode titleFocusNode;
  final FocusNode summaryFocusNode;
  final bool isAiLoading;
  final Future<void> Function() onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;
  final Future<void> Function() onGenerateSummary;
  final Future<String?> Function(String bullet) onImproveBullet;
  final Future<List<String>?> Function() onSuggestSkills;

  const _BuilderFormContent({
    required this.formState,
    required this.formNotifier,
    required this.titleController,
    required this.summaryController,
    required this.titleFocusNode,
    required this.summaryFocusNode,
    required this.isAiLoading,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onGenerateSummary,
    required this.onImproveBullet,
    required this.onSuggestSkills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepHeader(currentStep: formState.currentStep),
        const SizedBox(height: 20),
        _buildCurrentStep(),
        const SizedBox(height: 20),
        _BuilderActions(
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
          subtitle: 'Add a resume title and a strong personal summary.',
          trailing: AppButton(
            text: 'AI Summary',
            expand: false,
            variant: AppButtonVariant.secondary,
            icon: Icons.auto_awesome_rounded,
            isLoading: isAiLoading,
            onPressed: (formState.isLoading || isAiLoading) ? null : onGenerateSummary,
          ),
          child: Column(
            children: [
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
                      color: Color(0xFFDC2626),
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
                      color: Color(0xFFDC2626),
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
          onImproveBullet: onImproveBullet,
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
          onSuggestSkills: onSuggestSkills,
          onAcceptSuggestedSkill: (skillName) {
            formNotifier.addSkill(
              Skill(
                name: skillName,
                category: 'Suggested',
              ),
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;

  const _StepHeader({
    required this.currentStep,
  });

  static const _labels = [
    'Personal Info',
    'Work Exp',
    'Education',
    'Skills',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            _labels.length,
            (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: isActive || isCompleted
                                  ? const Color(0xFF6D5EF8)
                                  : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive || isCompleted
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _labels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != _labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 24),
                          color: index < currentStep
                              ? const Color(0xFF6D5EF8)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BuilderActions extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function() onNext;
  final Future<void> Function() onSave;

  const _BuilderActions({
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == 3;

    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: AppButton(
              text: 'Back',
              variant: AppButtonVariant.secondary,
              onPressed: isLoading ? null : onBack,
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: isLastStep ? 'Save Resume' : 'Next',
            isLoading: isLoading,
            onPressed: isLoading
                ? null
                : () async {
                    if (isLastStep) {
                      await onSave();
                    } else {
                      await onNext();
                    }
                  },
          ),
        ),
      ],
    );
  }
}
