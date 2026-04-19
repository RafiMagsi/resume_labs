import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/usecases/resume/get_all_resumes_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/auth_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_list_provider.dart';

class MockGetAllResumesUseCase extends Mock implements GetAllResumesUseCase {}

void main() {
  late GetAllResumesUseCase useCase;

  setUp(() {
    useCase = MockGetAllResumesUseCase();
  });

  test('returns empty list when user is null', () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => Stream<UserProfile?>.value(null)),
        getAllResumesUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);

    final resumes = await container.read(resumeListProvider.future);
    expect(resumes, isEmpty);

    verifyNever(() => useCase(any()));
  });

  test('returns sorted resumes when use case succeeds', () async {
    final user = UserProfile(
      uid: 'user-1',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
    );

    final older = Resume(
      id: 'r1',
      userId: 'user-1',
      title: 'Old',
      personalSummary: '',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    final newer = older.copyWith(id: 'r2', title: 'New', updatedAt: DateTime(2024, 2, 1));

    when(() => useCase('user-1')).thenAnswer((_) async => Right([older, newer]));

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => Stream<UserProfile?>.value(user)),
        getAllResumesUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);

    final resumes = await container.read(resumeListProvider.future);
    expect(resumes.map((e) => e.id).toList(), ['r2', 'r1']);
    verify(() => useCase('user-1')).called(1);
  });

  test('returns empty list when use case fails', () async {
    final user = UserProfile(
      uid: 'user-1',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
    );

    when(() => useCase('user-1'))
        .thenAnswer((_) async => const Left(NetworkFailure('No internet')));

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => Stream<UserProfile?>.value(user)),
        getAllResumesUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);

    final resumes = await container.read(resumeListProvider.future);
    expect(resumes, isEmpty);
    verify(() => useCase('user-1')).called(1);
  });
}
