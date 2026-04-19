import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/app_exception.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/data/datasources/local/resume_local_datasource.dart';
import 'package:resume_labs/data/datasources/remote/firestore_resume_datasource.dart';
import 'package:resume_labs/data/models/education_model.dart';
import 'package:resume_labs/data/models/resume_model.dart';
import 'package:resume_labs/data/models/skill_model.dart';
import 'package:resume_labs/data/models/work_experience_model.dart';
import 'package:resume_labs/data/repositories/resume_repository_impl.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';

class MockFirestoreResumeDataSource extends Mock
    implements FirestoreResumeDataSource {}

class MockResumeLocalDataSource extends Mock implements ResumeLocalDataSource {}

void main() {
  late FirestoreResumeDataSource remoteDataSource;
  late ResumeLocalDataSource localDataSource;
  late ResumeRepositoryImpl repository;

  late ResumeModel resumeModel;
  late Resume resumeEntity;

  setUpAll(() {
    final fallback = ResumeModel(
      id: 'fallback',
      userId: 'fallback',
      title: 'fallback',
      personalSummary: 'fallback',
      createdAt: DateTime(2000, 1, 1),
      updatedAt: DateTime(2000, 1, 1),
    );
    registerFallbackValue(fallback);
    registerFallbackValue(<ResumeModel>[]);
  });

  setUp(() {
    remoteDataSource = MockFirestoreResumeDataSource();
    localDataSource = MockResumeLocalDataSource();

    repository = ResumeRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    resumeModel = ResumeModel(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Senior Flutter Developer',
      personalSummary: 'Experienced mobile engineer',
      workExperiences: [
        WorkExperienceModel(
          company: 'ABC',
          role: 'Developer',
          location: 'Remote',
          startDate: DateTime(2021, 1, 1),
          endDate: null,
          bulletPoints: const ['Built production apps'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        EducationModel(
          school: 'FAST',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2020, 1, 1),
          gpa: 3.5,
        ),
      ],
      skills: const [
        SkillModel(
          name: 'Flutter',
          category: 'Mobile',
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 2, 1),
    );

    resumeEntity = Resume(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Senior Flutter Developer',
      personalSummary: 'Experienced mobile engineer',
      workExperiences: [
        WorkExperience(
          company: 'ABC',
          role: 'Developer',
          location: 'Remote',
          startDate: DateTime(2021, 1, 1),
          endDate: null,
          bulletPoints: const ['Built production apps'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        Education(
          school: 'FAST',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2020, 1, 1),
          gpa: 3.5,
        ),
      ],
      skills: const [
        Skill(
          name: 'Flutter',
          category: 'Mobile',
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 2, 1),
    );
  });

  group('createResume', () {
    test('returns Right and caches on remote success', () async {
      when(() => remoteDataSource.createResume(any()))
          .thenAnswer((_) async => resumeModel);
      when(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .thenAnswer((_) async {});

      final result = await repository.createResume(resumeEntity);

      expect(result.isRight(), true);
      verify(() => remoteDataSource.createResume(any())).called(1);
      verify(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .called(1);
    });

    test('returns Left(ServerFailure) when remote throws ServerException',
        () async {
      when(() => remoteDataSource.createResume(any())).thenThrow(
        const ServerException('Failed to create resume'),
      );

      final result = await repository.createResume(resumeEntity);

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to create resume');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(
          () => localDataSource.cacheResume(any(that: isA<ResumeModel>())));
    });
  });

  group('updateResume', () {
    test('returns Right and caches on remote success', () async {
      when(() => remoteDataSource.updateResume(any()))
          .thenAnswer((_) async => resumeModel);
      when(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .thenAnswer((_) async {});

      final result = await repository.updateResume(resumeEntity);

      expect(result.isRight(), true);
      verify(() => remoteDataSource.updateResume(any())).called(1);
      verify(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .called(1);
    });
  });

  group('deleteResume', () {
    test('returns Right(null) on remote success', () async {
      when(() => remoteDataSource.deleteResume('resume-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteResume('resume-1');

      expect(result, const Right(null));
      verify(() => remoteDataSource.deleteResume('resume-1')).called(1);
    });

    test('returns Left(NetworkFailure) on network error', () async {
      when(() => remoteDataSource.deleteResume('resume-1')).thenThrow(
        const NetworkException('No internet'),
      );

      final result = await repository.deleteResume('resume-1');

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getResumeById', () {
    test('returns Right(resume) and caches on remote success', () async {
      when(() => remoteDataSource.getResumeById('resume-1'))
          .thenAnswer((_) async => resumeModel);
      when(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .thenAnswer((_) async {});

      final result = await repository.getResumeById('resume-1');

      expect(result.isRight(), true);
      verify(() => remoteDataSource.getResumeById('resume-1')).called(1);
      verify(() => localDataSource.cacheResume(any(that: isA<ResumeModel>())))
          .called(1);
    });

    test('returns Right(null) when remote returns null', () async {
      when(() => remoteDataSource.getResumeById('resume-1'))
          .thenAnswer((_) async => null);

      final result = await repository.getResumeById('resume-1');

      expect(result, const Right(null));
      verifyNever(
          () => localDataSource.cacheResume(any(that: isA<ResumeModel>())));
    });

    test('returns Left(NetworkFailure) on remote network error', () async {
      when(() => remoteDataSource.getResumeById('resume-1')).thenThrow(
        const NetworkException(
            'No internet connection. Unable to load resume.'),
      );

      final result = await repository.getResumeById('resume-1');

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message,
              'No internet connection. Unable to load resume.');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getResumesByUserId', () {
    test('returns remote data and caches it on success', () async {
      when(() => remoteDataSource.getAllResumes(userId: 'user-1'))
          .thenAnswer((_) async => [resumeModel]);
      when(() =>
              localDataSource.cacheResumes(any(that: isA<List<ResumeModel>>())))
          .thenAnswer((_) async {});

      final result = await repository.getResumesByUserId('user-1');

      expect(result.isRight(), true);
      verify(() => remoteDataSource.getAllResumes(userId: 'user-1')).called(1);
      verify(
        () => localDataSource.cacheResumes(any(that: isA<List<ResumeModel>>())),
      ).called(1);
    });

    test('falls back to cache when remote throws NetworkException', () async {
      when(() => remoteDataSource.getAllResumes(userId: 'user-1')).thenThrow(
        const NetworkException('No internet'),
      );
      when(() => localDataSource.getCachedResumes(userId: 'user-1'))
          .thenAnswer((_) async => [resumeModel]);

      final result = await repository.getResumesByUserId('user-1');

      expect(result.isRight(), true);
      verify(() => remoteDataSource.getAllResumes(userId: 'user-1')).called(1);
      verify(() => localDataSource.getCachedResumes(userId: 'user-1'))
          .called(1);
    });

    test('returns Left(CacheFailure) when remote fails and cache also fails',
        () async {
      when(() => remoteDataSource.getAllResumes(userId: 'user-1')).thenThrow(
        const NetworkException('No internet'),
      );
      when(() => localDataSource.getCachedResumes(userId: 'user-1')).thenThrow(
        const CacheException('Cache broken'),
      );

      final result = await repository.getResumesByUserId('user-1');

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Cache broken');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns Left(ServerFailure) on non-network remote error', () async {
      when(() => remoteDataSource.getAllResumes(userId: 'user-1')).thenThrow(
        const ServerException('Firestore unavailable'),
      );

      final result = await repository.getResumesByUserId('user-1');

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Firestore unavailable');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(() => localDataSource.getCachedResumes(userId: 'user-1'));
    });
  });
}
