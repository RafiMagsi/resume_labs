import 'package:freezed_annotation/freezed_annotation.dart';

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