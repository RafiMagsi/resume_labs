import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/skill.dart';

part 'skill_model.freezed.dart';
part 'skill_model.g.dart';

@freezed
class SkillModel with _$SkillModel {
  const factory SkillModel({
    required String name,
    required String category,
  }) = _SkillModel;

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);
}

extension SkillModelMapper on SkillModel {
  Skill toEntity() {
    return Skill(
      name: name,
      category: category,
    );
  }
}

extension SkillEntityMapper on Skill {
  SkillModel toModel() {
    return SkillModel(
      name: name,
      category: category,
    );
  }
}