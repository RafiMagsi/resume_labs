import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/repositories/docx_repository_impl.dart';
import 'package:resume_labs/data/services/docx_service.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';

Resume _resumeWithUnsafeTitle() => Resume(
      id: 'r-1',
      userId: 'u-1',
      title: 'My/Resume: *Title*',
      personalSummary: 'Summary text',
      photoUrl: null,
      workExperiences: [
        WorkExperience(
          company: 'ABC',
          role: 'Engineer',
          location: 'Dubai',
          startDate: DateTime(2020, 1, 1),
          endDate: null,
          bulletPoints: const ['Built features'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        Education(
          school: 'XYZ',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2019, 6, 1),
          gpa: null,
        ),
      ],
      skills: const [
        Skill(name: 'Flutter', category: 'Mobile'),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 2, 1),
    );

void main() {
  group('DocxRepositoryImpl', () {
    const repository = DocxRepositoryImpl(DocxService());

    test('exportResumeDocx writes a file and returns its path', () async {
      String? filePath;
      final result = await repository.exportResumeDocx(
        resume: _resumeWithUnsafeTitle(),
        template: ResumeTemplate.executive,
      );

      result.match(
        (l) => fail('Expected Right, got $l'),
        (r) => filePath = r,
      );

      expect(filePath, isNotNull);
      expect(filePath!, endsWith('.docx'));

      final file = File(filePath!);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(300));

      // DOCX is a ZIP container and starts with "PK"
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);

      await file.delete();
    });
  });
}
