import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/education.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../injection/injection_container.dart';

final resumeFormProvider =
    NotifierProvider<ResumeFormNotifier, ResumeFormState>(
  ResumeFormNotifier.new,
);

class ResumeFormNotifier extends Notifier<ResumeFormState> {
  @override
  ResumeFormState build() {
    return ResumeFormState.initial();
  }

  void loadResume(Resume resume) {
    state = state.copyWith(
      resumeId: resume.id,
      userId: resume.userId,
      title: resume.title,
      personalSummary: resume.personalSummary,
      workExperiences: resume.workExperiences,
      educations: resume.educations,
      skills: resume.skills,
      isEditing: true,
      currentStep: 0,
      validationErrors: {},
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void reset({
    String? userId,
  }) {
    state = ResumeFormState.initial(userId: userId);
  }

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value, validationErrors: {
      ...state.validationErrors..remove('title'),
    });
  }

  void updatePersonalSummary(String value) {
    state = state.copyWith(personalSummary: value, validationErrors: {
      ...state.validationErrors..remove('personalSummary'),
    });
  }

  void addWorkExperience(WorkExperience experience) {
    state = state.copyWith(
      workExperiences: [...state.workExperiences, experience],
    );
  }

  void updateWorkExperience(int index, WorkExperience experience) {
    final items = [...state.workExperiences];
    if (index < 0 || index >= items.length) return;
    items[index] = experience;
    state = state.copyWith(workExperiences: items);
  }

  void removeWorkExperience(int index) {
    final items = [...state.workExperiences];
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    state = state.copyWith(workExperiences: items);
  }

  void addEducation(Education education) {
    state = state.copyWith(
      educations: [...state.educations, education],
    );
  }

  void updateEducation(int index, Education education) {
    final items = [...state.educations];
    if (index < 0 || index >= items.length) return;
    items[index] = education;
    state = state.copyWith(educations: items);
  }

  void removeEducation(int index) {
    final items = [...state.educations];
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    state = state.copyWith(educations: items);
  }

  void addSkill(Skill skill) {
    state = state.copyWith(
      skills: [...state.skills, skill],
    );
  }

  void updateSkill(int index, Skill skill) {
    final items = [...state.skills];
    if (index < 0 || index >= items.length) return;
    items[index] = skill;
    state = state.copyWith(skills: items);
  }

  void removeSkill(int index) {
    final items = [...state.skills];
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    state = state.copyWith(skills: items);
  }

  bool validateCurrentStep() {
    final errors = <String, String>{};

    switch (state.currentStep) {
      case 0:
        if (state.title.trim().isEmpty) {
          errors['title'] = 'Resume title is required';
        }
        if (state.personalSummary.trim().isEmpty) {
          errors['personalSummary'] = 'Personal summary is required';
        }
        break;
      case 1:
        if (state.workExperiences.isEmpty) {
          errors['workExperiences'] = 'Add at least one work experience';
        }
        break;
      case 2:
        if (state.educations.isEmpty) {
          errors['educations'] = 'Add at least one education entry';
        }
        break;
      case 3:
        if (state.skills.isEmpty) {
          errors['skills'] = 'Add at least one skill';
        }
        break;
    }

    state = state.copyWith(validationErrors: errors);
    return errors.isEmpty;
  }

  bool validateAll() {
    final errors = <String, String>{};

    if (state.title.trim().isEmpty) {
      errors['title'] = 'Resume title is required';
    }
    if (state.personalSummary.trim().isEmpty) {
      errors['personalSummary'] = 'Personal summary is required';
    }
    if (state.workExperiences.isEmpty) {
      errors['workExperiences'] = 'Add at least one work experience';
    }
    if (state.educations.isEmpty) {
      errors['educations'] = 'Add at least one education entry';
    }
    if (state.skills.isEmpty) {
      errors['skills'] = 'Add at least one skill';
    }

    state = state.copyWith(validationErrors: errors);
    return errors.isEmpty;
  }

  Future<bool> save() async {
    if (!validateAll()) {
      final errors = state.validationErrors;
      state = state.copyWith(
        currentStep: _firstInvalidStep(errors),
        errorMessage: 'Please complete the required fields before saving.',
        clearSuccessMessage: true,
      );
      return false;
    }
    if (state.userId == null || state.userId!.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'User not found. Please sign in again.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final resume = Resume(
      id: state.resumeId ?? _generateResumeId(),
      userId: state.userId!,
      title: state.title.trim(),
      personalSummary: state.personalSummary.trim(),
      workExperiences: state.workExperiences,
      educations: state.educations,
      skills: state.skills,
      createdAt: state.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = state.isEditing
        ? await ref.read(updateResumeUseCaseProvider)(resume)
        : await ref.read(createResumeUseCaseProvider)(resume);

    return result.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: state.isEditing
              ? 'Resume updated successfully'
              : 'Resume created successfully',
          resumeId: resume.id,
          createdAt: resume.createdAt,
          isEditing: true,
        );
        return true;
      },
    );
  }

  String _generateResumeId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  int _firstInvalidStep(Map<String, String> errors) {
    if (errors.containsKey('title') || errors.containsKey('personalSummary')) {
      return 0;
    }
    if (errors.containsKey('workExperiences')) return 1;
    if (errors.containsKey('educations')) return 2;
    if (errors.containsKey('skills')) return 3;
    return state.currentStep;
  }
}

class ResumeFormState {
  final int currentStep;
  final String? resumeId;
  final String? userId;
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final Map<String, String> validationErrors;
  final bool isLoading;
  final bool isEditing;
  final DateTime? createdAt;
  final String? errorMessage;
  final String? successMessage;

  const ResumeFormState({
    required this.currentStep,
    required this.resumeId,
    required this.userId,
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.validationErrors,
    required this.isLoading,
    required this.isEditing,
    required this.createdAt,
    required this.errorMessage,
    required this.successMessage,
  });

  factory ResumeFormState.initial({
    String? userId,
  }) {
    return ResumeFormState(
      currentStep: 0,
      resumeId: null,
      userId: userId,
      title: '',
      personalSummary: '',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      validationErrors: const {},
      isLoading: false,
      isEditing: false,
      createdAt: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  ResumeFormState copyWith({
    int? currentStep,
    String? resumeId,
    String? userId,
    String? title,
    String? personalSummary,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    Map<String, String>? validationErrors,
    bool? isLoading,
    bool? isEditing,
    DateTime? createdAt,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return ResumeFormState(
      currentStep: currentStep ?? this.currentStep,
      resumeId: resumeId ?? this.resumeId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      personalSummary: personalSummary ?? this.personalSummary,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      validationErrors: validationErrors ?? this.validationErrors,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
