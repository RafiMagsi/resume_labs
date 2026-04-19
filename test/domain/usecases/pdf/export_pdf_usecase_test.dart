import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/repositories/pdf_repository.dart';
import 'package:resume_labs/domain/usecases/pdf/export_pdf_usecase.dart';

class MockPdfRepository extends Mock implements PdfRepository {}

void main() {
  late PdfRepository repository;
  late ExportPdfUseCase useCase;

  setUp(() {
    repository = MockPdfRepository();
    useCase = ExportPdfUseCase(repository);
  });

  test('returns Right(String) when repository succeeds', () async {
    final resume = Resume(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Flutter Developer',
      personalSummary: 'Summary',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(
      () => repository.exportResumePdf(
        resume: resume,
        template: ResumeTemplate.classic,
      ),
    ).thenAnswer((_) async => const Right('/tmp/resume.pdf'));

    final result = await useCase(
      resume: resume,
      template: ResumeTemplate.classic,
    );

    expect(result, const Right('/tmp/resume.pdf'));
    verify(
      () => repository.exportResumePdf(
        resume: resume,
        template: ResumeTemplate.classic,
      ),
    ).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    final resume = Resume(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Flutter Developer',
      personalSummary: 'Summary',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(
      () => repository.exportResumePdf(
        resume: resume,
        template: ResumeTemplate.classic,
      ),
    ).thenAnswer((_) async => const Left(PdfFailure('Export failed')));

    final result = await useCase(
      resume: resume,
      template: ResumeTemplate.classic,
    );

    expect(result, const Left(PdfFailure('Export failed')));
  });
}
