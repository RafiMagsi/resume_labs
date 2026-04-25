import '../../domain/entities/contact_details.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../models/resume_model.dart';
import 'contact_details_mapper.dart';
import 'education_mapper.dart';
import 'skill_mapper.dart';
import 'work_experience_mapper.dart';

ResumeTemplate _parseResumeTemplate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return ResumeTemplate.classic;
  try {
    return ResumeTemplate.values.byName(trimmed);
  } catch (_) {
    return ResumeTemplate.classic;
  }
}

extension ResumeModelMapper on ResumeModel {
  Resume toEntity() {
    return Resume(
      id: id,
      userId: userId,
      title: title,
      personalSummary: personalSummary,
      photoUrl: photoUrl,
      contactDetails: contactDetails?.toEntity() ?? const ContactDetails(),
      template: _parseResumeTemplate(template),
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
      photoUrl: photoUrl,
      contactDetails: contactDetails.toModel(),
      template: template.name,
      workExperiences: workExperiences.map((e) => e.toModel()).toList(),
      educations: educations.map((e) => e.toModel()).toList(),
      skills: skills.map((e) => e.toModel()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
