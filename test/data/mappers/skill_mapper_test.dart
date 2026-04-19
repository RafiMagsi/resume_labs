import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/mappers/skill_mapper.dart';
import 'package:resume_labs/data/models/skill_model.dart';
import 'package:resume_labs/domain/entities/skill.dart';

void main() {
  group('SkillMapper', () {
    test('toEntity maps model to entity correctly', () {
      const model = SkillModel(
        name: 'Flutter',
        category: 'Frontend',
      );

      final entity = model.toEntity();

      expect(
        entity,
        const Skill(
          name: 'Flutter',
          category: 'Frontend',
        ),
      );
    });

    test('toModel maps entity to model correctly', () {
      const entity = Skill(
        name: 'Firebase',
        category: 'Backend',
      );

      final model = entity.toModel();

      expect(
        model,
        const SkillModel(
          name: 'Firebase',
          category: 'Backend',
        ),
      );
    });
  });
}