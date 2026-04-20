import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/resume/resume_optimization_provider.dart';
import '../../widgets/shared/credits_paywall.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _resumeController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _resumeController.dispose();
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

    final credits = ref.read(creditsAvailableProvider).value ?? 0;
    if (credits <= 0) {
      CreditsPaywall.show(context, ref);
      return;
    }

    ref
        .read(resumeOptimizationNotifierProvider.notifier)
        .optimizeResume(resumeText);
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
          height: 450,
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
                onOptimize: _handleOptimize,
              ),
            ],
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
    final message = error is Exception ? error.toString() : 'An error occurred';

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
    _tabController.animateTo(0);
    ref
        .read(resumeOptimizationNotifierProvider.notifier)
        .optimizeResume('');
  }
}
