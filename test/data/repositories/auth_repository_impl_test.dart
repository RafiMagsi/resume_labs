import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/app_exception.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:resume_labs/data/models/user_profile_model.dart';
import 'package:resume_labs/data/repositories/auth_repository_impl.dart';

class MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

void main() {
  late FirebaseAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  final testModel = UserProfileModel(
    uid: 'uid-1',
    email: testEmail,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    dataSource = MockFirebaseAuthDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('signUp', () {
    test('returns Right(UserProfile) when datasource succeeds', () async {
      when(
        () => dataSource.signUp(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => testModel);

      final result = await repository.signUp(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right but got Left'),
        (user) {
          expect(user.uid, 'uid-1');
          expect(user.email, testEmail);
        },
      );

      verify(
        () => dataSource.signUp(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    test('returns Left(AuthFailure) when datasource throws AuthException',
        () async {
      when(
        () => dataSource.signUp(
          email: testEmail,
          password: testPassword,
        ),
      ).thenThrow(
        const AuthException('Email already exists', code: 'email-already-in-use'),
      );

      final result = await repository.signUp(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Email already exists');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test(
        'returns Left(ValidationFailure) when datasource throws ValidationException',
        () async {
      when(
        () => dataSource.signUp(
          email: testEmail,
          password: testPassword,
        ),
      ).thenThrow(
        const ValidationException('Invalid email', code: 'invalid-email'),
      );

      final result = await repository.signUp(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Invalid email');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('signIn', () {
    test('returns Right(UserProfile) when datasource succeeds', () async {
      when(
        () => dataSource.signIn(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => testModel);

      final result = await repository.signIn(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isRight(), true);
    });

    test('returns Left(AuthFailure) when datasource throws AuthException',
        () async {
      when(
        () => dataSource.signIn(
          email: testEmail,
          password: testPassword,
        ),
      ).thenThrow(
        const AuthException('Invalid email or password'),
      );

      final result = await repository.signIn(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Invalid email or password');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('signOut', () {
    test('returns Right(null) when datasource succeeds', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right(null));
    });
  });

  group('resetPassword', () {
    test('returns Right(null) when datasource succeeds', () async {
      when(
        () => dataSource.resetPassword(email: testEmail),
      ).thenAnswer((_) async {});

      final result = await repository.resetPassword(email: testEmail);

      expect(result, const Right(null));
    });

    test('returns Left(NetworkFailure) when datasource throws NetworkException',
        () async {
      when(
        () => dataSource.resetPassword(email: testEmail),
      ).thenThrow(
        const NetworkException('No internet'),
      );

      final result = await repository.resetPassword(email: testEmail);

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

  group('getCurrentUser', () {
    test('returns Right(UserProfile?) when datasource returns user', () async {
      when(() => dataSource.getCurrentUser()).thenReturn(testModel);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right but got Left'),
        (user) {
          expect(user?.uid, 'uid-1');
        },
      );
    });

    test('returns Right(null) when datasource returns null', () async {
      when(() => dataSource.getCurrentUser()).thenReturn(null);

      final result = await repository.getCurrentUser();

      expect(result, const Right(null));
    });
  });

  group('authStateChanges', () {
    test('maps model stream to entity stream', () async {
      when(
        () => dataSource.authStateChanges(),
      ).thenAnswer(
        (_) => Stream<UserProfileModel?>.fromIterable([testModel, null]),
      );

      final values = await repository.authStateChanges().toList();

      expect(values.length, 2);
      expect(values.first?.uid, 'uid-1');
      expect(values.last, null);
    });
  });
}
