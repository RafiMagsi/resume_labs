import '../../domain/entities/skill.dart';
import '../models/skill_model.dart';

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