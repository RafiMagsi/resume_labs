import '../../../data/models/user_profile_model.dart';

abstract interface class FirebaseAuthDataSource {
  Future<UserProfileModel> signUp({
    required String email,
    required String password,
  });

  Future<UserProfileModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({
    required String email,
  });

  Stream<UserProfileModel?> authStateChanges();

  UserProfileModel? getCurrentUser();
}