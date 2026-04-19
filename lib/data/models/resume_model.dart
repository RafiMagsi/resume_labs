import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/resume.dart';
import 'education_model.dart';
import 'skill_model.dart';
import 'work_experience_model.dart';

part 'resume_model.freezed.dart';
part 'resume_model.g.dart';

@freezed
class ResumeModel with _$ResumeModel {
  const factory ResumeModel({
    required String id,
    required String userId,
    required String title,
    required String personalSummary,
    @Default(<WorkExperienceModel>[]) List<WorkExperienceModel> workExperiences,
    @Default(<EducationModel>[]) List<EducationModel> educations,
    @Default(<SkillModel>[]) List<SkillModel> skills,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ResumeModel;

  factory ResumeModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeModelFromJson(json);
}

extension ResumeModelMapper on ResumeModel {
  Resume toEntity() {
    return Resume(
      id: id,
      userId: userId,
      title: title,
      personalSummary: personalSummary,
      workExperiences: workExperiences.map((e) => e.toEntity()).toList(),
      educations: educations.map((e) => e.toEntity()).toList(),
      skills: skills.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ResumeEntityMapper on Resume {
  ResumeModel toModel() {
    return ResumeModel(
      id: id,
      userId: userId,
      title: title,
      personalSummary: personalSummary,
      workExperiences: workExperiences.map((e) => e.toModel()).toList(),
      educations: educations.map((e) => e.toModel()).toList(),
      skills: skills.map((e) => e.toModel()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}