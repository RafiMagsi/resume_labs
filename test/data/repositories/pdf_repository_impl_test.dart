import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/data/repositories/pdf_repository_impl.dart';
import 'package:resume_labs/data/services/pdf_service.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfRepositoryImpl', () {
    final repository = PdfRepositoryImpl(PdfService());

    test('generateResumePdfBytes returns bytes on success', () async {
      final result = await repository.generateResumePdfBytes(
        resume: _resumeWithUnsafeTitle(),
        template: ResumeTemplate.modern,
      );

      result.match(
        (l) => fail('Expected Right, got $l'),
        (r) => expect(r.length, greaterThan(800)),
      );
    });

    test('exportResumePdf writes a file and returns its path', () async {
      String? filePath;
      final result = await repository.exportResumePdf(
        resume: _resumeWithUnsafeTitle(),
        template: ResumeTemplate.modernClean,
      );

      result.match(
        (l) => fail('Expected Right, got $l'),
        (r) => filePath = r,
      );

      expect(filePath, isNotNull);
      expect(filePath!, endsWith('.pdf'));

      final file = File(filePath!);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(800));

      await file.delete();
    });
  });
}
