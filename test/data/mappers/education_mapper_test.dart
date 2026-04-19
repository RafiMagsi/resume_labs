import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/mappers/education_mapper.dart';
import 'package:resume_labs/data/models/education_model.dart';
import 'package:resume_labs/domain/entities/education.dart';

void main() {
  group('EducationMapper', () {
    test('toEntity maps model to entity correctly', () {
      final model = EducationModel(
        school: 'NED University',
        degree: 'BS',
        field: 'Computer Science',
        graduationDate: DateTime(2020, 6, 1),
        gpa: 3.4,
      );

      final entity = model.toEntity();

      expect(
        entity,
        Education(
          school: 'NED University',
          degree: 'BS',
          field: 'Computer Science',
          graduationDate: DateTime(2020, 6, 1),
          gpa: 3.4,
        ),
      );
    });

    test('toModel maps entity to model correctly', () {
      final entity = Education(
        school: 'FAST',
        degree: 'MS',
        field: 'Software Engineering',
        graduationDate: DateTime(2023, 8, 1),
        gpa: null,
      );

      final model = entity.toModel();

      expect(
        model,
        EducationModel(
          school: 'FAST',
          degree: 'MS',
          field: 'Software Engineering',
          graduationDate: DateTime(2023, 8, 1),
          gpa: null,
        ),
      );
    });
  });
}
