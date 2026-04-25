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
import '../../widgets/shared/error_dialog.dart';
import '../resume_detail/resume_detail_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _resumeController = TextEditingController();
    _optimizationPrompt = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _resumeController.dispose();
    _optimizationPrompt.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleOptimize() {
    final resumeText = _resumeController.text.trim();
    if (resumeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resumeTooShort)),
      );
      return;
    }

    try {
      final creditsAsync = ref.read(creditsAvailableProvider);
      if (creditsAsync.hasError) {
        ErrorDialog.show(
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
      ref
          .read(resumeOptimizationNotifierProvider.notifier)
          .optimizeResume(resumeText, customPrompt: prompt);
    } catch (e) {
      ErrorDialog.show(
        context,
        failure: ServerFailure(e.toString()),
        title: 'Error',
      );
    }
  }

  void _handleFileUploaded(String extractedText) {
    _resumeController.text = extractedText;
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
                  optimizedResume: resumeState.value!,
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
          const CircularProgressIndicator(),
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
          ErrorDialog.show(
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

      // AI Optimize import must ALWAYS create a brand new resume record.
      // No linking to, or updating, any currently-loaded resume.
      debugPrint('[ResumeOptimizer] Creating NEW resume record (AI Optimize)');
      notifier.reset(userId: userId);

      // Parse JSON and update each section directly
      _parseJsonAndUpdateSections(optimizedText, notifier);
      debugPrint(
          '[ResumeOptimizer] ✓ All sections parsed and updated from JSON');

      // Save to Firestore (AI Optimize import always creates a new resume)
      debugPrint('[ResumeOptimizer] Saving resume to Firestore...');
      final saveSuccess = await notifier.saveAsNew();

      if (!mounted) {
        debugPrint('[ResumeOptimizer] ✗ Context not mounted after save');
        return;
      }

      if (saveSuccess) {
        debugPrint('[ResumeOptimizer] ✓ Resume saved to Firestore');

        // Navigate to resume details screen
        context.pushReplacement(ResumeDetailScreen.routePath);
        debugPrint('[ResumeOptimizer] ✓ Navigated to resume details screen');

        // Show success message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume created from AI optimization.'),
                duration: Duration(seconds: 3),
              ),
            );
            debugPrint('[ResumeOptimizer] ✓ Import completed successfully');
          }
        });
      } else {
        debugPrint('[ResumeOptimizer] ✗ Failed to save resume');
        if (mounted) {
          final formState = ref.read(resumeFormProvider);
          ErrorDialog.show(
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
        ErrorDialog.show(
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

      // Extract title
      final title = data['title'] as String? ?? 'Optimized Resume';
      notifier.updateTitle(title);
      debugPrint('[ResumeOptimizer] ✓ Title: $title');

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

      // Extract skills
      final skillList = data['skills'] as List? ?? [];
      if (skillList.isNotEmpty) {
        for (final skillData in skillList) {
          final skill = Skill(
            name: skillData['name'] as String? ?? 'Skill',
            category: skillData['category'] as String? ?? 'Technical',
          );
          notifier.addSkill(skill);
        }
        debugPrint('[ResumeOptimizer] ✓ Added ${skillList.length} skills');
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
    ref.read(resumeOptimizationNotifierProvider.notifier).optimizeResume('');
  }
}
