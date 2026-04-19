import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../injection/injection_container.dart';

final aiSuggestionsProvider =
    AsyncNotifierProvider<AiSuggestionsNotifier, AiSuggestionsState>(
  AiSuggestionsNotifier.new,
);

class AiSuggestionsNotifier extends AsyncNotifier<AiSuggestionsState> {
  @override
  Future<AiSuggestionsState> build() async {
    return const AiSuggestionsState();
  }

  Future<void> generateSummary({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(generateSummaryUseCaseProvider);
    final result = await useCase(
      jobTitle: jobTitle,
      skills: skills,
      workHighlights: workHighlights,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (summary) => AsyncData(
        AiSuggestionsState(
          generatedSummary: summary,
        ),
      ),
    );
  }

  Future<void> improveBullet({
    required String bullet,
    String? jobTitle,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(improveBulletUseCaseProvider);
    final result = await useCase(
      bullet: bullet,
      jobTitle: jobTitle,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (improvedBullet) => AsyncData(
        AiSuggestionsState(
          improvedBullet: improvedBullet,
        ),
      ),
    );
  }

  Future<void> suggestSkills({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(suggestSkillsUseCaseProvider);
    final result = await useCase(
      jobTitle: jobTitle,
      existingSkills: existingSkills,
      personalSummary: personalSummary,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (suggestedSkills) => AsyncData(
        AiSuggestionsState(
          suggestedSkills: suggestedSkills,
        ),
      ),
    );
  }

  void clear() {
    state = const AsyncData(AiSuggestionsState());
  }
}

class AiSuggestionsState {
  final String? generatedSummary;
  final String? improvedBullet;
  final List<String> suggestedSkills;

  const AiSuggestionsState({
    this.generatedSummary,
    this.improvedBullet,
    this.suggestedSkills = const [],
  });

  bool get hasSummary =>
      generatedSummary != null && generatedSummary!.trim().isNotEmpty;

  bool get hasImprovedBullet =>
      improvedBullet != null && improvedBullet!.trim().isNotEmpty;

  bool get hasSuggestedSkills => suggestedSkills.isNotEmpty;

  AiSuggestionsState copyWith({
    String? generatedSummary,
    String? improvedBullet,
    List<String>? suggestedSkills,
    bool clearGeneratedSummary = false,
    bool clearImprovedBullet = false,
    bool clearSuggestedSkills = false,
  }) {
    return AiSuggestionsState(
      generatedSummary: clearGeneratedSummary
          ? null
          : (generatedSummary ?? this.generatedSummary),
      improvedBullet:
          clearImprovedBullet ? null : (improvedBullet ?? this.improvedBullet),
      suggestedSkills: clearSuggestedSkills
          ? const []
          : (suggestedSkills ?? this.suggestedSkills),
    );
  }
}
