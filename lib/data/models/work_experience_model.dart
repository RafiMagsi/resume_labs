import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_experience_model.freezed.dart';
part 'work_experience_model.g.dart';

@freezed
class WorkExperienceModel with _$WorkExperienceModel {
  const factory WorkExperienceModel({
    required String company,
    required String role,
    required String location,
    required DateTime startDate,
    DateTime? endDate,
    @Default(<String>[]) List<String> bulletPoints,
    @Default(false) bool isCurrentRole,
  }) = _WorkExperienceModel;

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkExperienceModelFromJson(json);
}
