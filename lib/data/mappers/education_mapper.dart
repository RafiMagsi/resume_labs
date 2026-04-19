import '../../domain/entities/education.dart';
import '../models/education_model.dart';

extension EducationModelMapper on EducationModel {
  Education toEntity() {
    return Education(
      school: school,
      degree: degree,
      field: field,
      graduationDate: graduationDate,
      gpa: gpa,
    );
  }
}

extension EducationEntityMapper on Education {
  EducationModel toModel() {
    return EducationModel(
      school: school,
      degree: degree,
      field: field,
      graduationDate: graduationDate,
      gpa: gpa,
    );
  }
}
