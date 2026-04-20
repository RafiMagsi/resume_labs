import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/services/docx_service.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';

Resume _fullResume() => Resume(
      id: 'r-1',
      userId: 'u-1',
      title: 'Senior Flutter Developer',
      personalSummary: 'Summary text',
      photoUrl: null,
      workExperiences: [
        WorkExperience(
          company: 'ABC',
          role: 'Engineer',
          location: 'Dubai',
          startDate: DateTime(2020, 1, 1),
          endDate: null,
          bulletPoints: const ['Built features', 'Improved performance'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        Education(
          school: 'XYZ University',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2019, 6, 1),
          gpa: 3.5,
        ),
      ],
      skills: const [
        Skill(name: 'Flutter', category: 'Mobile'),
        Skill(name: 'Dart', category: 'Language'),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 2, 1),
    );

Resume _emptyResume() => Resume(
      id: 'r-2',
      userId: 'u-1',
      title: '',
      personalSummary: '',
      photoUrl: null,
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 2, 1),
    );

void main() {
  group('DocxService', () {
    const service = DocxService();

    void expectDocx(Uint8List bytes) {
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(300));
      // DOCX is a ZIP container and starts with "PK"
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);
    }

    for (final template in ResumeTemplate.values) {
      test('generates DOCX bytes for $template (full resume)', () {
        final bytes = service.generateResumeDocx(
          resume: _fullResume(),
          template: template,
        );
        expectDocx(bytes);
      });

      test('generates DOCX bytes for $template (empty resume)', () {
        final bytes = service.generateResumeDocx(
          resume: _emptyResume(),
          template: template,
        );
        expectDocx(bytes);
      });
    }
  });
}
