import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';
import 'package:resume_labs/domain/repositories/pdf_repository.dart';
import 'package:resume_labs/domain/repositories/resume_repository.dart';
import 'package:resume_labs/domain/usecases/pdf/export_pdf_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/auth_provider.dart';
import 'package:resume_labs/presentation/providers/auth/sign_up_provider.dart';
import 'package:resume_labs/presentation/providers/pdf/pdf_export_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_form_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_list_provider.dart';
import 'package:resume_labs/presentation/screens/auth/register_screen.dart';
import 'package:resume_labs/presentation/screens/history/history_screen.dart';
import 'package:resume_labs/presentation/screens/resume_builder/builder_screen.dart';
import 'package:resume_labs/presentation/screens/resume_builder/preview_screen.dart';
import 'package:resume_labs/presentation/services/pdf_share_service.dart';

class _InMemoryResumeRepository implements ResumeRepository {
  final List<Resume> _items = [];

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    _items.add(resume);
    return Right(resume);
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    _items.removeWhere((e) => e.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Resume?>> getResumeById(String resumeId) async {
    for (final item in _items) {
      if (item.id == resumeId) return Right(item);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Resume>>> getResumesByUserId(
      String userId) async {
    return Right(_items.where((e) => e.userId == userId).toList());
  }

  @override
  Future<Either<Failure, Resume>> updateResume(Resume resume) async {
    final index = _items.indexWhere((e) => e.id == resume.id);
    if (index == -1) return const Left(CacheFailure('Resume not found'));
    _items[index] = resume;
    return Right(resume);
  }
}

class _FakePdfRepository implements PdfRepository {
  @override
  Future<Either<Failure, Uint8List>> generateResumePdfBytes({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    return Right(Uint8List.fromList([0x25, 0x50, 0x44, 0x46])); // "%PDF"
  }

  @override
  Future<Either<Failure, String>> exportResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    final file = File('${Directory.systemTemp.path}/resume_labs_test.pdf');
    await file.writeAsBytes(const [0x25, 0x50, 0x44, 0x46]); // "%PDF"
    return Right(file.path);
  }
}

class _NoopPdfShareService implements PdfShareService {
  const _NoopPdfShareService();

  @override
  Future<void> sharePdf({required String filePath}) async {}
}

class _TestSignUpNotifier extends SignUpNotifier {
  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    state = const AsyncData(null);
  }
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: RegisterScreen.routePath,
    routes: [
      GoRoute(
        path: RegisterScreen.routePath,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: HistoryScreen.routePath,
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: BuilderScreen.routePath,
        builder: (_, __) => const BuilderScreen(),
      ),
      GoRoute(
        path: PreviewScreen.routePath,
        builder: (_, __) => const PreviewScreen(),
      ),
    ],
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signup -> create resume -> save -> export pdf', (tester) async {
    final router = _createRouter();
    final resumeRepository = _InMemoryResumeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signUpProvider.overrideWith(_TestSignUpNotifier.new),
          authProvider.overrideWith(
            (ref) => Stream<UserProfile?>.value(
              UserProfile(
                uid: 'user-1',
                email: 'user@example.com',
                createdAt: DateTime(2024, 1, 1),
              ),
            ),
          ),
          resumeRepositoryProvider.overrideWithValue(resumeRepository),
          exportPdfUseCaseProvider.overrideWithValue(
            ExportPdfUseCase(_FakePdfRepository()),
          ),
          pdfShareServiceProvider
              .overrideWithValue(const _NoopPdfShareService()),
          // Keep History deterministic for this flow.
          resumeListProvider.overrideWith((ref) async => const <Resume>[]),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Signup
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'password123',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'password123',
    );
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    // Create New Resume
    await tester.tap(find.text('Create New Resume'));
    await tester.pumpAndSettle();
    expect(find.byType(BuilderScreen), findsOneWidget);

    // Fill required form state directly (avoid flaky bottom sheets).
    final container =
        ProviderScope.containerOf(tester.element(find.byType(BuilderScreen)));
    final formNotifier = container.read(resumeFormProvider.notifier);
    formNotifier.reset(userId: 'user-1');
    formNotifier.updateTitle('Flutter Developer');
    formNotifier.updatePersonalSummary('Professional summary');
    formNotifier.addWorkExperience(
      WorkExperience(
        company: 'Acme',
        role: 'Engineer',
        location: 'Remote',
        startDate: DateTime(2020, 1, 1),
        endDate: null,
        bulletPoints: const ['Built features'],
        isCurrentRole: true,
      ),
    );
    formNotifier.addEducation(
      Education(
        school: 'Uni',
        degree: 'BS',
        field: 'CS',
        graduationDate: DateTime(2019, 1, 1),
        gpa: null,
      ),
    );
    formNotifier.addSkill(const Skill(name: 'Flutter', category: 'Mobile'));
    formNotifier.setCurrentStep(3);
    await tester.pump();

    // Save
    await tester.tap(find.text('Save Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Success'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Export
    await router.push(PreviewScreen.routePath);
    await tester.pumpAndSettle();
    expect(find.byType(PreviewScreen), findsOneWidget);
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    final exportState = container.read(pdfExportProvider).valueOrNull;
    expect(exportState?.exportedFilePath, isNotNull);
    expect(File(exportState!.exportedFilePath!).existsSync(), true);
  });
}
