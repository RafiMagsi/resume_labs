import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';
import '../../providers/resume/resume_optimization_provider.dart';
import '../../widgets/shared/credits_paywall.dart';
import '../../widgets/shared/error_dialog.dart';
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
                  onImportToResume: () {
                    Navigator.of(context).pop(resumeState.value);
                  },
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
            counterText:
                '$currentLength/$maxLength', // Show character count
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

  void _resetForm() {
    _resumeController.clear();
    _optimizationPrompt.clear();
    _tabController.animateTo(0);
    ref
        .read(resumeOptimizationNotifierProvider.notifier)
        .optimizeResume('');
  }
}
