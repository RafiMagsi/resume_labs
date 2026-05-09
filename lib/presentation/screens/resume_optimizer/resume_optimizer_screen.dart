import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/resume_optimization_provider.dart';
import '../../widgets/shared/credits_paywall.dart';
import '../../widgets/shared/dialog_manager.dart';
import '../../widgets/shared/app_loader.dart';
import '../../widgets/shared/ai_resume_disclosure_dialog.dart';
import 'widgets/resume_optimizer_input.dart';
import 'widgets/resume_optimization_result.dart';
import 'widgets/resume_file_upload.dart';

class ResumeOptimizerScreen extends ConsumerStatefulWidget {
  static const routePath = '/resume-optimizer';
  static const routeName = 'resume-optimizer';

  const ResumeOptimizerScreen({super.key});

  @override
  ConsumerState<ResumeOptimizerScreen> createState() =>
      _ResumeOptimizerScreenState();
}

class _ResumeOptimizerScreenState extends ConsumerState<ResumeOptimizerScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _resumeController;
  late TextEditingController _optimizationPrompt;
  late TabController _tabController;
  bool _isEditMode = false;
  String? _rawResumeText;
  bool _sendSummaryToAi = true;
  bool _sendExperienceToAi = true;
  bool _sendEducationToAi = true;
  bool _sendSkillsToAi = true;
  bool _isScrubbingPersonalInfo = false;

  @override
  void initState() {
    super.initState();
    _resumeController = TextEditingController();
    _optimizationPrompt = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    _resumeController.addListener(_scrubPersonalInfoIfNeeded);

    // Always start with a clean optimization state (new upload/new prompt).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(resumeOptimizationNotifierProvider);

      final formState = ref.read(resumeFormProvider);
      final isEditingExisting =
          formState.resumeId != null && formState.resumeId!.isNotEmpty;

      if (isEditingExisting) {
        setState(() => _isEditMode = true);
        _populateFromExistingResume(formState);
        return;
      }

      setState(() => _isEditMode = false);
      _resumeController.clear();
      _optimizationPrompt.clear();
      _tabController.animateTo(0);
    });
  }

  void _populateFromExistingResume(ResumeFormState formState) {
    // Extract text from current resume for optimization
    final resumeText = _extractResumeText(formState);
    _rawResumeText = resumeText;
    _isScrubbingPersonalInfo = true;
    try {
      _resumeController.text = _sanitizeForDisplay(resumeText);
    } finally {
      _isScrubbingPersonalInfo = false;
    }
    _tabController.animateTo(1); // Switch to paste tab
  }

  String _extractResumeText(ResumeFormState formState) {
    final buffer = StringBuffer();

    // Title
    if (formState.title.isNotEmpty) {
      buffer.writeln(formState.title);
      buffer.writeln('-' * 40);
    }

    // Personal Summary
    if (formState.personalSummary.isNotEmpty) {
      buffer.writeln('\nPROFESSIONAL SUMMARY');
      buffer.writeln(formState.personalSummary);
    }

    // Work Experience
    if (formState.workExperiences.isNotEmpty) {
      buffer.writeln('\nWORK EXPERIENCE');
      for (final exp in formState.workExperiences) {
        buffer.writeln('${exp.role} at ${exp.company}');
        if (exp.location.isNotEmpty) {
          buffer.writeln('Location: ${exp.location}');
        }
        buffer.writeln(
            '${exp.startDate.year} - ${exp.endDate?.year ?? "Present"}');
        for (final bullet in exp.bulletPoints) {
          buffer.writeln('• $bullet');
        }
      }
    }

    // Education
    if (formState.educations.isNotEmpty) {
      buffer.writeln('\nEDUCATION');
      for (final edu in formState.educations) {
        buffer.writeln('${edu.degree} in ${edu.field}');
        buffer.writeln(edu.school);
        buffer.writeln('Graduated: ${edu.graduationDate.year}');
        if (edu.gpa != null && edu.gpa! > 0) {
          buffer.writeln('GPA: ${edu.gpa}');
        }
      }
    }

    // Skills
    if (formState.skills.isNotEmpty) {
      buffer.writeln('\nSKILLS');
      final skillNames = formState.skills.map((s) => s.name).join(', ');
      buffer.writeln(skillNames);
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _resumeController.removeListener(_scrubPersonalInfoIfNeeded);
    _resumeController.dispose();
    _optimizationPrompt.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleOptimize() async {
    final resumeText = _resumeController.text.trim();
    if (resumeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resumeTooShort)),
      );
      return;
    }

    try {
      final ok = await AiResumeDisclosureDialog.show(context);
      if (!mounted) return;
      if (!ok) return;

      final creditsAsync = ref.read(creditsAvailableProvider);
      if (creditsAsync.hasError) {
        DialogManager.showFailure(
          context,
          failure: ServerFailure(creditsAsync.error.toString()),
          title: 'Error Loading Credits',
        );
        return;
      }

      final credits = creditsAsync.value ?? 0;
      if (credits <= 0) {
        CreditsPaywall.show(context, ref);
        return;
      }

      final prompt = _optimizationPrompt.text.trim();

      final rawForAi = (_rawResumeText ?? _resumeController.text).trim();
      final aiInput = _buildAiInput(
        rawForAi,
        includeContactDetails: true,
      );

      ref
          .read(resumeOptimizationNotifierProvider.notifier)
          .optimizeResume(aiInput, customPrompt: prompt);
    } catch (e) {
      DialogManager.showFailure(
        context,
        failure: ServerFailure(e.toString()),
        title: 'Error',
      );
    }
  }

  void _handleFileUploaded(String extractedText) {
    _rawResumeText = extractedText;
    _isScrubbingPersonalInfo = true;
    try {
      _resumeController.text = _sanitizeForDisplay(extractedText);
    } finally {
      _isScrubbingPersonalInfo = false;
    }
    _tabController.animateTo(1); // Switch to paste tab
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume text extracted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeOptimizationNotifierProvider);
    final creditsAsync = ref.watch(creditsAvailableProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.optimizeResume),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreditsIndicator(creditsAsync),
              const SizedBox(height: 24),
              if (resumeState.isLoading)
                _buildLoadingState()
              else if (resumeState.hasError)
                _buildErrorState(resumeState)
              else if (resumeState.hasValue && resumeState.value != null)
                ResumeOptimizationResult(
                  originalResume: _resumeController.text,
                  optimizedResume:
                      _sanitizeOptimizationResultForDisplay(resumeState.value!),
                  onOptimizeAnother: _resetForm,
                  onCreateResume: () =>
                      _handleImportToResume(resumeState.value!),
                )
              else
                _buildInputTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Upload File'),
              Tab(text: 'Paste Text'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 380,
          child: TabBarView(
            controller: _tabController,
            children: [
              ResumeFileUpload(
                onFileSelected: _handleFileUploaded,
                onUploading: () {
                  // Loading state handled in widget
                },
                onError: (error, fileName) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$error: $fileName'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
              ),
              ResumeOptimizerInput(
                controller: _resumeController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildOptimizationPromptInput(),
      ],
    );
  }

  String _sanitizeOptimizationResultForDisplay(String text) {
    // Optimization result is JSON, which may include contact details.
    // Keep them out of the UI for privacy/compliance.
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        decoded.remove('contactDetails');
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {}
    return _stripContactDetailsFromText(text);
  }

  Widget _buildOptimizationPromptInput() {
    const maxLength = 200;
    final currentLength = _optimizationPrompt.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Optimize? (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell AI how you want your resume optimized (e.g., "Focus on tech skills", "Emphasize leadership")',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _optimizationPrompt,
          maxLength: maxLength,
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(
            hintText: 'e.g., Enhance technical skills section...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
            counterText: '$currentLength/$maxLength', // Show character count
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _buildAiScopeToggle(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleOptimize,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.optimize,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsIndicator(AsyncValue<int> creditsAsync) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.premiumGold),
          const SizedBox(width: 8),
          Text(
            creditsAsync.when(
              data: (credits) => '${AppStrings.creditsRemaining}: $credits',
              loading: () => '${AppStrings.creditsRemaining}: ...',
              error: (_, __) => '${AppStrings.creditsRemaining}: 0',
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const AppLoader(size: 36, strokeWidth: 3.2),
          const SizedBox(height: 16),
          Text(
            AppStrings.optimizing,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildErrorState(AsyncValue<String?> state) {
    final error = state.error;
    late final String message;

    if (error is Failure) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = 'An error occurred. Please try again.';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.errorSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetForm,
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Future<void> _handleImportToResume(String optimizedText) async {
    debugPrint('[ResumeOptimizer] Starting import to resume...');
    debugPrint(
        '[ResumeOptimizer] Optimized text length: ${optimizedText.length}');
    debugPrint(
        '[ResumeOptimizer] Mode: ${_isEditMode ? "EDIT existing" : "CREATE new"}');

    try {
      if (!context.mounted) {
        debugPrint('[ResumeOptimizer] ✗ Context not mounted, aborting');
        return;
      }

      // Get the authenticated user's ID
      final authState = ref.read(authProvider);
      final userId = authState.whenData((profile) => profile?.uid).value;

      if (userId == null || userId.isEmpty) {
        debugPrint('[ResumeOptimizer] ✗ User not authenticated');
        if (context.mounted) {
          DialogManager.showFailure(
            context,
            failure: const AuthFailure(
                'User not authenticated. Please sign in again.'),
            title: 'Auth Error',
          );
        }
        return;
      }
      debugPrint('[ResumeOptimizer] User ID: $userId');

      final notifier = ref.read(resumeFormProvider.notifier);

      if (_isEditMode) {
        // EDIT MODE: Update existing resume
        debugPrint('[ResumeOptimizer] ✓ Updating existing resume');
      } else {
        // CREATE MODE: Create a brand new resume record
        debugPrint(
            '[ResumeOptimizer] Creating NEW resume record (AI Optimize)');
        notifier.reset(userId: userId);
      }

      // Parse JSON and update each section directly
      _parseJsonAndUpdateSections(optimizedText, notifier);
      debugPrint(
          '[ResumeOptimizer] ✓ All sections parsed and updated from JSON');

      // Save to Firestore
      debugPrint('[ResumeOptimizer] Saving resume to Firestore...');
      final saveSuccess =
          _isEditMode ? await notifier.save() : await notifier.saveAsNew();

      if (!mounted) {
        debugPrint('[ResumeOptimizer] ✗ Context not mounted after save');
        return;
      }

      if (saveSuccess) {
        debugPrint('[ResumeOptimizer] ✓ Resume saved to Firestore');

        // Navigate back to resume details screen
        context.pop();
        debugPrint(
            '[ResumeOptimizer] ✓ Navigated back to resume details screen');

        // Show success message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final message = _isEditMode
                ? 'Resume optimized and updated.'
                : 'Resume created from AI optimization.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 3),
              ),
            );
            debugPrint('[ResumeOptimizer] ✓ Import completed successfully');
          }
        });
      } else {
        debugPrint('[ResumeOptimizer] ✗ Failed to save resume');
        if (mounted) {
          final formState = ref.read(resumeFormProvider);
          DialogManager.showFailure(
            context,
            failure: ServerFailure(
              formState.errorMessage ??
                  'Failed to save resume. Please check all fields are filled.',
            ),
            title: 'Save Failed',
          );
        }
      }
    } catch (e) {
      debugPrint('[ResumeOptimizer] ✗ Error: $e');
      if (mounted) {
        DialogManager.showFailure(
          context,
          failure: ServerFailure('Failed to import resume: $e'),
          title: 'Import Error',
        );
      }
    }
  }

  // ignore: unused_element
  void _parseAndUpdateSections(
      String optimizedText, ResumeFormNotifier notifier) {
    debugPrint('[ResumeOptimizer] Parsing optimized text...');

    // Split text into sections
    final sections = _splitIntoSections(optimizedText);
    debugPrint('[ResumeOptimizer] Found sections: ${sections.keys.toList()}');

    // Set title if not already set
    final currentState = ref.read(resumeFormProvider);
    if (currentState.title.isEmpty) {
      final title = _extractOrGenerateTitle(sections, optimizedText);
      notifier.updateTitle(title);
      debugPrint('[ResumeOptimizer] ✓ Set Title: $title');
    }

    // Update summary - REQUIRED
    if (sections.containsKey('summary') && sections['summary']!.isNotEmpty) {
      final summary = sections['summary']!.trim();
      notifier.updatePersonalSummary(summary);
      debugPrint(
          '[ResumeOptimizer] ✓ Updated Summary (${summary.length} chars)');
    } else {
      // Use entire text as summary if no summary section found
      final summary = optimizedText.trim();
      notifier.updatePersonalSummary(summary);
      debugPrint(
          '[ResumeOptimizer] ⚠ No summary section found, using entire text (${summary.length} chars)');
    }

    // Update work experience - REQUIRED (create defaults if missing)
    if (sections.containsKey('experience') &&
        sections['experience']!.isNotEmpty) {
      _createOrUpdateExperience(notifier, sections['experience']!);
    } else {
      _createDefaultWorkExperience(notifier);
      debugPrint(
          '[ResumeOptimizer] ⚠ No work experience found, created default entry');
    }

    // Update education - REQUIRED (create defaults if missing)
    if (sections.containsKey('education') &&
        sections['education']!.isNotEmpty) {
      _createOrUpdateEducation(notifier, sections['education']!);
    } else {
      _createDefaultEducation(notifier);
      debugPrint(
          '[ResumeOptimizer] ⚠ No education found, created default entry');
    }

    // Update skills - REQUIRED (create defaults if missing)
    if (sections.containsKey('skills') && sections['skills']!.isNotEmpty) {
      _createOrUpdateSkills(notifier, sections['skills']!);
    } else {
      _createDefaultSkills(notifier);
      debugPrint('[ResumeOptimizer] ⚠ No skills found, created default entry');
    }
  }

  void _createDefaultWorkExperience(ResumeFormNotifier notifier) {
    final currentState = ref.read(resumeFormProvider);
    if (currentState.workExperiences.isEmpty) {
      final experience = WorkExperience(
        company: 'Company Name',
        role: 'Job Title',
        location: 'Location',
        startDate: DateTime.now(),
        endDate: null,
        bulletPoints: ['Achievement or responsibility'],
        isCurrentRole: true,
      );
      notifier.addWorkExperience(experience);
    }
  }

  void _createDefaultEducation(ResumeFormNotifier notifier) {
    final currentState = ref.read(resumeFormProvider);
    if (currentState.educations.isEmpty) {
      final education = Education(
        school: 'University Name',
        degree: 'Bachelor',
        field: 'Field of Study',
        graduationDate: DateTime.now(),
        gpa: null,
      );
      notifier.addEducation(education);
    }
  }

  void _createDefaultSkills(ResumeFormNotifier notifier) {
    final currentState = ref.read(resumeFormProvider);
    if (currentState.skills.isEmpty) {
      final skills = [
        Skill(name: 'Skill 1', category: 'Technical'),
        Skill(name: 'Skill 2', category: 'Technical'),
      ];
      for (final skill in skills) {
        notifier.addSkill(skill);
      }
    }
  }

  String _extractOrGenerateTitle(
      Map<String, String> sections, String optimizedText) {
    // Try to extract title from first line
    final firstLine = optimizedText.split('\n').first.trim();
    if (firstLine.isNotEmpty &&
        firstLine.length > 5 &&
        firstLine.length < 100) {
      return firstLine;
    }
    // Generate default title
    return 'Optimized Resume - ${DateTime.now().toString().split(' ')[0]}';
  }

  Map<String, String> _splitIntoSections(String text) {
    final sections = <String, String>{};
    final lines = text.split('\n');

    String? currentSection;
    final buffer = StringBuffer();

    for (final line in lines) {
      final lower = line.toLowerCase().trim();
      final isEmpty = lower.isEmpty;

      // Detect section headers (look for header patterns)
      final isSummaryHeader = lower.startsWith('summary') ||
          lower.startsWith('professional') ||
          lower.startsWith('objective') ||
          lower == 'summary:' ||
          lower == 'professional summary:';

      final isExperienceHeader = lower.startsWith('experience') ||
          lower.startsWith('work') ||
          lower.startsWith('employment') ||
          lower == 'work experience:' ||
          lower == 'professional experience:';

      final isEducationHeader =
          lower.startsWith('education') || lower == 'education:';

      final isSkillsHeader = lower.startsWith('skill') ||
          lower.startsWith('competenc') ||
          lower == 'skills:' ||
          lower == 'technical skills:';

      if (isSummaryHeader) {
        if (currentSection != null && buffer.isNotEmpty) {
          sections[currentSection] = buffer.toString().trim();
          buffer.clear();
        }
        currentSection = 'summary';
      } else if (isExperienceHeader) {
        if (currentSection != null && buffer.isNotEmpty) {
          sections[currentSection] = buffer.toString().trim();
          buffer.clear();
        }
        currentSection = 'experience';
      } else if (isEducationHeader) {
        if (currentSection != null && buffer.isNotEmpty) {
          sections[currentSection] = buffer.toString().trim();
          buffer.clear();
        }
        currentSection = 'education';
      } else if (isSkillsHeader) {
        if (currentSection != null && buffer.isNotEmpty) {
          sections[currentSection] = buffer.toString().trim();
          buffer.clear();
        }
        currentSection = 'skills';
      } else if (currentSection != null && !isEmpty) {
        buffer.writeln(line.trim());
      }
    }

    // Store last section
    if (currentSection != null && buffer.isNotEmpty) {
      sections[currentSection] = buffer.toString().trim();
    }

    return sections;
  }

  void _createOrUpdateExperience(
      ResumeFormNotifier notifier, String experienceText) {
    final currentExperiences = ref.read(resumeFormProvider).workExperiences;

    // Split experience text by job entries (separated by blank lines)
    final entries = experienceText
        .split(RegExp(r'\n\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      debugPrint('[ResumeOptimizer] No work experience entries found');
      return;
    }

    // Update existing experiences or create new ones
    for (int i = 0; i < entries.length; i++) {
      // Parse bullet points from entry
      final bullets = entries[i]
          .split('\n')
          .map((line) => line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
          .where((line) => line.isNotEmpty && line.length > 5)
          .toList();

      if (bullets.isEmpty) continue;

      if (i < currentExperiences.length) {
        // Update existing
        final updated = currentExperiences[i].copyWith(bulletPoints: bullets);
        notifier.updateWorkExperience(i, updated);
        debugPrint(
            '[ResumeOptimizer] ✓ Updated Work Experience #${i + 1} (${bullets.length} bullets)');
      } else {
        // Create new - use first bullet as role, others as description
        final role = bullets.isNotEmpty
            ? bullets[0].substring(0, math.min(50, bullets[0].length))
            : 'Position';
        final experience = WorkExperience(
          company: 'Company',
          role: role,
          location: 'Location',
          startDate: DateTime.now(),
          endDate: null,
          bulletPoints: bullets,
          isCurrentRole: true,
        );
        notifier.addWorkExperience(experience);
        debugPrint(
            '[ResumeOptimizer] ✓ Created Work Experience #${i + 1} (${bullets.length} bullets)');
      }
    }
  }

  void _createOrUpdateEducation(
      ResumeFormNotifier notifier, String educationText) {
    final currentEducations = ref.read(resumeFormProvider).educations;

    final entries = educationText
        .split(RegExp(r'\n\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      debugPrint('[ResumeOptimizer] No education entries found');
      return;
    }

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];

      // Extract degree and field
      final degreeRegex = RegExp(
        r'(?:Bachelor|Master|Associate|PhD|BS|MS|BA|MA)(?:s)?(?:\s+(?:of|in)\s+)?([^,\n]*)',
      );
      final degreeMatch = degreeRegex.firstMatch(entry);
      final degree = degreeMatch?.group(0) ?? 'Degree';
      final field = (degreeMatch?.group(1) ?? 'Field').trim();

      if (i < currentEducations.length) {
        // Update existing
        final updated = currentEducations[i].copyWith(
          degree: degree,
          field: field,
        );
        notifier.updateEducation(i, updated);
        debugPrint('[ResumeOptimizer] ✓ Updated Education #${i + 1}');
      } else {
        // Create new
        final education = Education(
          school: 'University',
          degree: degree,
          field: field,
          graduationDate: DateTime.now(),
          gpa: null,
        );
        notifier.addEducation(education);
        debugPrint('[ResumeOptimizer] ✓ Created Education #${i + 1}');
      }
    }
  }

  void _createOrUpdateSkills(ResumeFormNotifier notifier, String skillsText) {
    final currentSkills = ref.read(resumeFormProvider).skills;

    // Parse skills (split by comma, bullet, dash, or newline)
    final skillNames = skillsText
        .split(RegExp(r'[,•\-\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .toList();

    if (skillNames.isEmpty) {
      debugPrint('[ResumeOptimizer] No skills found');
      return;
    }

    // Update existing skills or create new ones
    for (int i = 0; i < skillNames.length; i++) {
      if (i < currentSkills.length) {
        // Update existing
        final updated = currentSkills[i].copyWith(name: skillNames[i]);
        notifier.updateSkill(i, updated);
      } else {
        // Create new
        final skill = Skill(
          name: skillNames[i],
          category: 'Technical',
        );
        notifier.addSkill(skill);
        debugPrint('[ResumeOptimizer] ✓ Created Skill: ${skillNames[i]}');
      }
    }

    debugPrint('[ResumeOptimizer] ✓ Processed ${skillNames.length} skills');
  }

  void _parseJsonAndUpdateSections(
      String jsonString, ResumeFormNotifier notifier) {
    debugPrint('[ResumeOptimizer] Parsing JSON response...');

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // In edit mode, clear existing sections to avoid duplication
      if (_isEditMode) {
        debugPrint(
            '[ResumeOptimizer] Clearing existing sections for update...');
        final currentState = ref.read(resumeFormProvider);

        // Remove all work experiences
        for (int i = currentState.workExperiences.length - 1; i >= 0; i--) {
          notifier.removeWorkExperience(i);
        }

        // Remove all educations
        for (int i = currentState.educations.length - 1; i >= 0; i--) {
          notifier.removeEducation(i);
        }

        // Remove all skills
        for (int i = currentState.skills.length - 1; i >= 0; i--) {
          notifier.removeSkill(i);
        }

        debugPrint('[ResumeOptimizer] ✓ Cleared existing sections');
      }

      // Extract title
      final title = data['title'] as String? ?? 'Optimized Resume';
      notifier.updateTitle(title);
      debugPrint('[ResumeOptimizer] ✓ Title: $title');

      // Extract contact details from AI JSON. Keep out of text boxes, but do
      // restore them into the resume form model.
      final contact = data['contactDetails'];
      if (contact is Map<String, dynamic>) {
        void setIfNotEmpty(
          String key,
          void Function(String value) setter,
        ) {
          final value = contact[key];
          if (value is! String) return;
          final trimmed = value.trim();
          if (trimmed.isEmpty) return;
          setter(trimmed);
        }

        setIfNotEmpty('fullName', notifier.updateContactFullName);
        setIfNotEmpty('email', notifier.updateContactEmail);
        setIfNotEmpty('phone', notifier.updateContactPhone);
        setIfNotEmpty('location', notifier.updateContactLocation);
        setIfNotEmpty('website', notifier.updateContactWebsite);
        setIfNotEmpty('linkedin', notifier.updateContactLinkedin);
        setIfNotEmpty('github', notifier.updateContactGithub);
        setIfNotEmpty('dateOfBirth', notifier.updateContactDateOfBirth);
        setIfNotEmpty('nationality', notifier.updateContactNationality);
      }

      // Extract personal summary
      final summary = data['personalSummary'] as String? ?? '';
      if (summary.isNotEmpty) {
        notifier.updatePersonalSummary(summary);
        debugPrint('[ResumeOptimizer] ✓ Summary: ${summary.length} chars');
      }

      // Extract work experiences
      final experienceList = data['workExperiences'] as List? ?? [];
      if (experienceList.isNotEmpty) {
        for (final exp in experienceList) {
          final experience = WorkExperience(
            company: exp['company'] as String? ?? 'Company',
            role: exp['role'] as String? ?? 'Job Title',
            location: exp['location'] as String? ?? 'Location',
            startDate: _parseDate(exp['startDate']) ?? DateTime.now(),
            endDate: _parseDate(exp['endDate']),
            bulletPoints: List<String>.from(exp['bulletPoints'] as List? ?? []),
            isCurrentRole: exp['isCurrentRole'] as bool? ?? false,
          );
          notifier.addWorkExperience(experience);
        }
        debugPrint(
            '[ResumeOptimizer] ✓ Added ${experienceList.length} work experiences');
      }

      // Extract educations
      final educationList = data['educations'] as List? ?? [];
      if (educationList.isNotEmpty) {
        for (final edu in educationList) {
          final gpaValue = edu['gpa'];
          double? gpa;
          if (gpaValue is String) {
            try {
              gpa = double.parse(gpaValue);
            } catch (_) {
              gpa = null;
            }
          } else if (gpaValue is num) {
            gpa = gpaValue.toDouble();
          }

          final education = Education(
            school: edu['school'] as String? ?? 'School',
            degree: edu['degree'] as String? ?? 'Degree',
            field: edu['field'] as String? ?? 'Field',
            graduationDate: _parseDate(edu['graduationDate']) ?? DateTime.now(),
            gpa: gpa,
          );
          notifier.addEducation(education);
        }
        debugPrint(
            '[ResumeOptimizer] ✓ Added ${educationList.length} educations');
      }

      // Extract skills (AI now includes related skills in the response)
      final skillList = data['skills'] as List? ?? [];
      if (skillList.isNotEmpty) {
        for (final skillData in skillList) {
          final skill = Skill(
            name: skillData['name'] as String? ?? 'Skill',
            category: skillData['category'] as String? ?? 'Technical',
          );
          notifier.addSkill(skill);
        }
        debugPrint(
            '[ResumeOptimizer] ✓ Added ${skillList.length} skills (including AI-suggested related skills)');
      }

      debugPrint('[ResumeOptimizer] ✓ JSON parsing completed successfully');
    } catch (e) {
      debugPrint('[ResumeOptimizer] ✗ Error parsing JSON: $e');
      rethrow;
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _resetForm() {
    _resumeController.clear();
    _optimizationPrompt.clear();
    _tabController.animateTo(0);
    _rawResumeText = null;
    _sendSummaryToAi = true;
    _sendExperienceToAi = true;
    _sendEducationToAi = true;
    _sendSkillsToAi = true;
    ref.invalidate(resumeOptimizationNotifierProvider);
  }

  void _scrubPersonalInfoIfNeeded() {
    if (_isScrubbingPersonalInfo) return;
    final raw = _resumeController.text;
    if (raw.trim().isEmpty) {
      _rawResumeText = null;
      return;
    }

    final looksLikeHasPii =
        _containsPersonalInfo(raw) || _looksLikeNameLine(raw);

    // Preserve a raw version that may include contact details for the API call.
    // Do not overwrite it with already-sanitized editor text.
    if (_rawResumeText == null || looksLikeHasPii) {
      _rawResumeText = raw;
    }

    if (!looksLikeHasPii) return;

    _isScrubbingPersonalInfo = true;
    try {
      final sanitized = _sanitizeForDisplay(raw);
      if (sanitized != raw) {
        final selection = _resumeController.selection;
        _resumeController.value = TextEditingValue(
          text: sanitized,
          selection: TextSelection.collapsed(
            offset: selection.baseOffset.clamp(0, sanitized.length),
          ),
        );
      }
    } finally {
      _isScrubbingPersonalInfo = false;
    }
  }

  bool _containsPersonalInfo(String text) {
    final emailRegex = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    );
    final phoneRegex = RegExp(r'\+?\d[\d\s\-\(\)]{7,}\d');
    final urlRegex = RegExp(r'https?://\S+', caseSensitive: false);
    final domainRegex = RegExp(
      r'\b[a-z0-9][a-z0-9\-]{0,62}\.(com|net|org|io|dev|app|me|co|ai|ae|uk|us|pk|in|edu|gov)\b',
      caseSensitive: false,
    );
    final linkedInRegex = RegExp(r'linkedin\.com/\S+', caseSensitive: false);
    final githubRegex = RegExp(r'github\.com/\S+', caseSensitive: false);
    return emailRegex.hasMatch(text) ||
        phoneRegex.hasMatch(text) ||
        urlRegex.hasMatch(text) ||
        domainRegex.hasMatch(text) ||
        linkedInRegex.hasMatch(text) ||
        githubRegex.hasMatch(text);
  }

  bool _looksLikeNameLine(String text) {
    final firstLine = text
        .split('\n')
        .map((e) => e.trim())
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    if (firstLine.isEmpty) return false;
    if (firstLine.length > 50) return false;
    if (RegExp(r'[@0-9]').hasMatch(firstLine)) return false;
    // 2-4 word name-like
    final words = firstLine.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final count = words.length;
    if (count < 2 || count > 4) return false;
    // Avoid headers like "PROFESSIONAL SUMMARY"
    if (firstLine.toUpperCase() == firstLine) return false;
    return true;
  }

  String _sanitizeForDisplay(String text) {
    // Remove obvious contact blocks and contact-like lines.
    final stripped = _stripContactDetailsFromText(text);
    // Also remove the first line if it looks like a name.
    final lines = stripped.split('\n');
    if (lines.isEmpty) return stripped.trim();
    final firstNonEmptyIndex = lines.indexWhere((l) => l.trim().isNotEmpty);
    if (firstNonEmptyIndex == -1) return stripped.trim();

    final firstLine = lines[firstNonEmptyIndex];
    if (_looksLikeNameLine(firstLine)) {
      lines.removeAt(firstNonEmptyIndex);
    }

    return lines.join('\n').trim();
  }

  Widget _buildAiScopeToggle() {
    Widget chip({
      required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return FilterChip(
        label: Text(label),
        selected: value,
        showCheckmark: false,
        onSelected: onChanged,
        selectedColor: AppColors.primarySoft,
        backgroundColor: AppColors.secondarySurface,
        side: BorderSide(
          color: value ? AppColors.primaryLight : AppColors.border,
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data sent to AI',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which sections to include. Contact details are not shown in the editor.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            chip(
              label: 'Summary',
              value: _sendSummaryToAi,
              onChanged: (v) => setState(() => _sendSummaryToAi = v),
            ),
            chip(
              label: 'Experience',
              value: _sendExperienceToAi,
              onChanged: (v) => setState(() => _sendExperienceToAi = v),
            ),
            chip(
              label: 'Education',
              value: _sendEducationToAi,
              onChanged: (v) => setState(() => _sendEducationToAi = v),
            ),
            chip(
              label: 'Skills',
              value: _sendSkillsToAi,
              onChanged: (v) => setState(() => _sendSkillsToAi = v),
            ),
          ],
        ),
      ],
    );
  }

  String _buildAiInput(
    String resumeText, {
    required bool includeContactDetails,
  }) {
    final base = includeContactDetails
        ? resumeText.trim()
        : _stripContactDetailsFromText(resumeText);

    if (_sendSummaryToAi &&
        _sendExperienceToAi &&
        _sendEducationToAi &&
        _sendSkillsToAi) {
      return base;
    }

    final sections = _splitIntoSections(base);
    if (sections.isEmpty) return base;

    final buffer = StringBuffer();
    if (_sendSummaryToAi && (sections['summary'] ?? '').trim().isNotEmpty) {
      buffer.writeln('PROFESSIONAL SUMMARY');
      buffer.writeln(sections['summary']!.trim());
      buffer.writeln();
    }
    if (_sendExperienceToAi &&
        (sections['experience'] ?? '').trim().isNotEmpty) {
      buffer.writeln('WORK EXPERIENCE');
      buffer.writeln(sections['experience']!.trim());
      buffer.writeln();
    }
    if (_sendEducationToAi && (sections['education'] ?? '').trim().isNotEmpty) {
      buffer.writeln('EDUCATION');
      buffer.writeln(sections['education']!.trim());
      buffer.writeln();
    }
    if (_sendSkillsToAi && (sections['skills'] ?? '').trim().isNotEmpty) {
      buffer.writeln('SKILLS');
      buffer.writeln(sections['skills']!.trim());
    }

    final built = buffer.toString().trim();
    return built.isEmpty ? base : built;
  }

  bool _isSectionHeader(String line) {
    final t = line.trim();
    if (t.isEmpty) return false;
    final upper = t.toUpperCase();
    const known = {
      'PROFESSIONAL SUMMARY',
      'SUMMARY',
      'WORK EXPERIENCE',
      'EXPERIENCE',
      'EDUCATION',
      'SKILLS',
      'PROJECTS',
      'CERTIFICATIONS',
      'LANGUAGES',
      'INTERESTS',
      'REFERENCES',
      'ACHIEVEMENTS',
      'AWARDS',
      'PUBLICATIONS',
      'OBJECTIVE',
    };
    if (known.contains(upper)) return true;
    // Generic all-caps header (avoid false positives on normal lines).
    if (t.length <= 32 && t == upper && RegExp(r'^[A-Z &/]+$').hasMatch(t)) {
      return true;
    }
    return false;
  }

  String _stripContactDetailsFromText(String text) {
    final emailRegex = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    );
    final phoneRegex = RegExp(r'\+?\d[\d\s\-\(\)]{7,}\d');
    final urlRegex = RegExp(r'https?://\S+', caseSensitive: false);
    final domainRegex = RegExp(
      r'\b[a-z0-9][a-z0-9\-]{0,62}\.(com|net|org|io|dev|app|me|co|ai|ae|uk|us|pk|in|edu|gov)\b',
      caseSensitive: false,
    );
    final linkedInRegex = RegExp(r'linkedin\.com/\S+', caseSensitive: false);
    final githubRegex = RegExp(r'github\.com/\S+', caseSensitive: false);
    final contactHeaderRegex = RegExp(
      r'^(contact|contact info|contact information|personal details|personal information)\b',
      caseSensitive: false,
    );

    final kept = <String>[];
    var inContactBlock = false;
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (inContactBlock) continue;
        continue;
      }

      if (contactHeaderRegex.hasMatch(trimmed)) {
        inContactBlock = true;
        continue;
      }

      if (inContactBlock) {
        if (_isSectionHeader(trimmed) &&
            !contactHeaderRegex.hasMatch(trimmed)) {
          inContactBlock = false;
          kept.add(line);
        }
        continue;
      }

      final lower = trimmed.toLowerCase();
      final looksLikeContactLine = emailRegex.hasMatch(trimmed) ||
          phoneRegex.hasMatch(trimmed) ||
          urlRegex.hasMatch(trimmed) ||
          domainRegex.hasMatch(trimmed) ||
          linkedInRegex.hasMatch(trimmed) ||
          githubRegex.hasMatch(trimmed) ||
          lower.contains('linkedin') ||
          lower.contains('github');

      if (looksLikeContactLine) {
        continue;
      }
      kept.add(line);
    }
    return kept.join('\n').trim();
  }
}
