import '../entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<UserProfile> signUp({
    required String email,
    required String password,
  });

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({
    required String email,
  });

  Future<UserProfile?> getCurrentUser();
}