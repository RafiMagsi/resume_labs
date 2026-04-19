import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/education.dart';

part 'education_model.freezed.dart';
part 'education_model.g.dart';

@freezed
class EducationModel with _$EducationModel {
  const factory EducationModel({
    required String school,
    required String degree,
    required String field,
    required DateTime graduationDate,
    double? gpa,
  }) = _EducationModel;

  factory EducationModel.fromJson(Map<String, dynamic> json) =>
      _$EducationModelFromJson(json);
}

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