import '../../domain/entities/work_experience.dart';
import '../models/work_experience_model.dart';

extension WorkExperienceModelMapper on WorkExperienceModel {
  WorkExperience toEntity() {
    return WorkExperience(
      company: company,
      role: role,
      location: location,
      startDate: startDate,
      endDate: endDate,
      bulletPoints: bulletPoints,
      isCurrentRole: isCurrentRole,
    );
  }
}

extension WorkExperienceEntityMapper on WorkExperience {
  WorkExperienceModel toModel() {
    return WorkExperienceModel(
      company: company,
      role: role,
      location: location,
      startDate: startDate,
      endDate: endDate,
      bulletPoints: bulletPoints,
      isCurrentRole: isCurrentRole,
    );
  }
}
