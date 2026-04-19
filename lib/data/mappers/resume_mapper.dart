import '../../domain/entities/resume.dart';
import '../models/resume_model.dart';
import 'education_mapper.dart';
import 'skill_mapper.dart';
import 'work_experience_mapper.dart';

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
