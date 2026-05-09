import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth/auth_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/photo_upload_provider.dart';
import '../../widgets/resume/resume_preview.dart';
import '../../widgets/shared/dialog_manager.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../../providers/ai/ai_suggestions_provider.dart';
import '../history/history_screen.dart';
import 'widgets/builder_form_content.dart';

class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key});

  static const String routeName = 'builder';
  static const String routePath = '/builder';

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _summaryFocusNode = FocusNode();

  bool _isDisposed = false;
  bool _syncScheduled = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual<ResumeFormState>(resumeFormProvider, (_, __) {
      _scheduleControllerSync();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authProvider).valueOrNull;
      final notifier = ref.read(resumeFormProvider.notifier);
      final state = ref.read(resumeFormProvider);

      if (state.userId == null && authUser != null) {
        notifier.reset(userId: authUser.uid);
      }

      _scheduleControllerSync();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _titleController.dispose();
    _summaryController.dispose();

    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _titleFocusNode.dispose();
    _summaryFocusNode.dispose();
    super.dispose();
  }

  void _scheduleControllerSync() {
    if (_isDisposed || _syncScheduled) return;

    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted || _isDisposed) return;
      _syncControllers();
    });
  }

  String _safeText(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  void _syncControllers() {
    if (!mounted || _isDisposed) return;

    final state = ref.read(resumeFormProvider);
    final contact = state.contactDetails;

    void sync(
      TextEditingController controller,
      Object? rawValue, {
      FocusNode? focusNode,
    }) {
      if (!mounted || _isDisposed) return;

      final value = _safeText(rawValue);
      if (controller.text == value) return;

      // Do not overwrite a field while the user is typing.
      if (focusNode?.hasFocus ?? false) return;

      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    sync(_fullNameController, contact.fullName, focusNode: _fullNameFocusNode);
    sync(_emailController, contact.email, focusNode: _emailFocusNode);
    sync(_phoneController, contact.phone);
    sync(_locationController, contact.location);
    sync(_websiteController, contact.website);
    sync(_linkedinController, contact.linkedin);
    sync(_githubController, contact.github);
    sync(_dobController, contact.dateOfBirth);
    sync(_nationalityController, contact.nationality);
    sync(_titleController, state.title, focusNode: _titleFocusNode);
    sync(_summaryController, state.personalSummary,
        focusNode: _summaryFocusNode);
  }

  Future<void> _handlePhotoUpload(String localPath) async {
    final uploadedUrl = await ref.read(photoUploadProvider(localPath).future);
    if (uploadedUrl != null) {
      ref.read(resumeFormProvider.notifier).updatePhotoUrl(uploadedUrl);

      final formState = ref.read(resumeFormProvider);
      if (formState.resumeId != null) {
        await _handleSave();
      }
    }
  }

  Future<void> _handleNext() async {
    final notifier = ref.read(resumeFormProvider.notifier);
    final isValid = notifier.validateCurrentStep();

    if (!isValid) {
      DialogManager.showError(
        context,
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
      DialogManager.showError(
        context,
        title: 'Save Failed',
        message: state.errorMessage ?? 'Unable to save resume.',
      );
      return;
    }

    DialogManager.showSuccess(
      context,
      title: 'Success',
      message: state.successMessage ?? 'Resume saved successfully.',
    ).then((_) {
      if (mounted) {
        context.go(HistoryScreen.routePath);
      }
    });
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

    // (Post-frame controller sync now handled via ref.listenManual and _scheduleControllerSync)

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(formState.currentStep)),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: formState.isLoading,
        message:
            formState.isEditing ? 'Updating resume...' : 'Saving resume...',
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortestSide = MediaQuery.sizeOf(context).shortestSide;
                final isWide =
                    constraints.maxWidth >= 980 || shortestSide >= 720;

                final formContent = BuilderFormContent(
                  formState: formState,
                  formNotifier: formNotifier,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  locationController: _locationController,
                  websiteController: _websiteController,
                  linkedinController: _linkedinController,
                  githubController: _githubController,
                  dobController: _dobController,
                  nationalityController: _nationalityController,
                  titleController: _titleController,
                  summaryController: _summaryController,
                  fullNameFocusNode: _fullNameFocusNode,
                  emailFocusNode: _emailFocusNode,
                  titleFocusNode: _titleFocusNode,
                  summaryFocusNode: _summaryFocusNode,
                  isAiLoading: isAiLoading,
                  onNext: _handleNext,
                  onBack: _handleBack,
                  onSave: _handleSave,
                  onPhotoUpload: _handlePhotoUpload,
                );

                final preview = ResumePreview(
                  photoUrl: formState.photoUrl,
                  contactDetails: formState.contactDetails,
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
