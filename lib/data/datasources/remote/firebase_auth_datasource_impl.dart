import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../models/user_profile_model.dart';
import 'firebase_auth_datasource.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;

  const FirebaseAuthDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserProfileModel> signUp({
    required String email,
    required String password,
  }) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'User account was not created.',
          code: 'user-null-after-sign-up',
        );
      }

      return _mapUser(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw const AuthException(
        'An unexpected authentication error occurred.',
        code: 'unknown-sign-up-error',
      );
    }
  }

  @override
  Future<UserProfileModel> signIn({
    required String email,
    required String password,
  }) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'User account was not returned after sign in.',
          code: 'user-null-after-sign-in',
        );
      }

      return _mapUser(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw const AuthException(
        'An unexpected authentication error occurred.',
        code: 'unknown-sign-in-error',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw const AuthException(
        'Failed to sign out.',
        code: 'unknown-sign-out-error',
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No signed-in user found.',
          code: 'no-current-user',
        );
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      // Special-case common delete-account errors for better UX.
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'For security, please sign in again and try deleting your account.',
          code: 'requires-recent-login',
        );
      }
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw const AuthException(
        'Failed to delete account.',
        code: 'unknown-delete-account-error',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    _validateEmail(email);

    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw const AuthException(
        'Failed to send password reset email.',
        code: 'unknown-reset-password-error',
      );
    }
  }

  @override
  Stream<UserProfileModel?> authStateChanges() {
    return firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : _mapUser(user),
        );
  }

  @override
  UserProfileModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  void _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw const ValidationException(
        'Email is required.',
        code: 'email-empty',
      );
    }

    if (!email.isValidEmail) {
      throw const ValidationException(
        'Please enter a valid email address.',
        code: 'email-invalid',
      );
    }
  }

  void _validatePassword(String password) {
    if (password.trim().isEmpty) {
      throw const ValidationException(
        'Password is required.',
        code: 'password-empty',
      );
    }

    if (!password.hasMinPasswordLength) {
      throw const ValidationException(
        'Password must be at least 8 characters long.',
        code: 'password-too-short',
      );
    }
  }

  UserProfileModel _mapUser(User user) {
    return UserProfileModel(
      uid: user.uid,
      email: user.email ?? '',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const ValidationException(
          'Please enter a valid email address.',
          code: 'invalid-email',
        );
      case 'email-already-in-use':
        return const AuthException(
          'An account already exists for this email.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const ValidationException(
          'Password is too weak. Use at least 8 characters.',
          code: 'weak-password',
        );
      case 'user-not-found':
        return const AuthException(
          'No account found for this email.',
          code: 'user-not-found',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException(
          'Invalid email or password.',
          code: 'invalid-credential',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const NetworkException(
          'Network error. Please check your internet connection.',
          code: 'network-request-failed',
        );
      default:
        return AuthException(
          e.message ?? 'Authentication failed.',
          code: e.code,
        );
    }
  }
}
