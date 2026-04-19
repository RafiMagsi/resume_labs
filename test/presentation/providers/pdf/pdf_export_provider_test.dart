import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/usecases/pdf/export_pdf_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/pdf/pdf_export_provider.dart';

class MockExportPdfUseCase extends Mock implements ExportPdfUseCase {}

void main() {
  late ExportPdfUseCase useCase;

  setUpAll(() {
    registerFallbackValue(ResumeTemplate.classic);
    registerFallbackValue(
      Resume(
        id: 'fallback',
        userId: 'fallback',
        title: 'fallback',
        personalSummary: '',
        workExperiences: const [],
        educations: const [],
        skills: const [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    useCase = MockExportPdfUseCase();
  });

  test('exportPdf emits loading then data on success', () async {
    when(
      () => useCase(
        resume: any(named: 'resume'),
        template: any(named: 'template'),
      ),
    ).thenAnswer((_) async => const Right('/tmp/resume.pdf'));

    final container = ProviderContainer(
      overrides: [
        exportPdfUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final resume = Resume(
      id: 'r1',
      userId: 'u1',
      title: 'Title',
      personalSummary: '',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final notifier = container.read(pdfExportProvider.notifier);

    final future = notifier.exportPdf(
      resume: resume,
      template: ResumeTemplate.classic,
    );

    expect(container.read(pdfExportProvider), const AsyncLoading<PdfExportState>());
    await future;

    final state = container.read(pdfExportProvider).valueOrNull;
    expect(state?.exportedFilePath, '/tmp/resume.pdf');
  });

  test('exportPdf emits loading then error on failure', () async {
    when(
      () => useCase(
        resume: any(named: 'resume'),
        template: any(named: 'template'),
      ),
    ).thenAnswer((_) async => const Left(PdfFailure('Export failed')));

    final container = ProviderContainer(
      overrides: [
        exportPdfUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final resume = Resume(
      id: 'r1',
      userId: 'u1',
      title: 'Title',
      personalSummary: '',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    await container.read(pdfExportProvider.notifier).exportPdf(
          resume: resume,
          template: ResumeTemplate.classic,
        );

    final providerState = container.read(pdfExportProvider);
    expect(providerState.hasError, true);
    expect(providerState.error, const PdfFailure('Export failed'));
  });
}
