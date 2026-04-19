import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/mappers/work_experience_mapper.dart';
import 'package:resume_labs/data/models/work_experience_model.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';

void main() {
  group('WorkExperienceMapper', () {
    test('toEntity maps model to entity correctly', () {
      final model = WorkExperienceModel(
        company: 'Google',
        role: 'Software Engineer',
        location: 'Dubai',
        startDate: DateTime(2022, 1, 1),
        endDate: DateTime(2024, 1, 1),
        bulletPoints: const ['Built features', 'Improved performance'],
        isCurrentRole: false,
      );

      final entity = model.toEntity();

      expect(
        entity,
        WorkExperience(
          company: 'Google',
          role: 'Software Engineer',
          location: 'Dubai',
          startDate: DateTime(2022, 1, 1),
          endDate: DateTime(2024, 1, 1),
          bulletPoints: const ['Built features', 'Improved performance'],
          isCurrentRole: false,
        ),
      );
    });

    test('toModel maps entity to model correctly', () {
      final entity = WorkExperience(
        company: 'Meta',
        role: 'Mobile Engineer',
        location: 'Remote',
        startDate: DateTime(2021, 5, 1),
        endDate: null,
        bulletPoints: const ['Led app rewrite'],
        isCurrentRole: true,
      );

      final model = entity.toModel();

      expect(
        model,
        WorkExperienceModel(
          company: 'Meta',
          role: 'Mobile Engineer',
          location: 'Remote',
          startDate: DateTime(2021, 5, 1),
          endDate: null,
          bulletPoints: const ['Led app rewrite'],
          isCurrentRole: true,
        ),
      );
    });
  });
}