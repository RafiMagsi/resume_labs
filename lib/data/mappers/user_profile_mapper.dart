import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

extension UserProfileModelMapper on UserProfileModel {
  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      createdAt: createdAt,
    );
  }
}

extension UserProfileEntityMapper on UserProfile {
  UserProfileModel toModel() {
    return UserProfileModel(
      uid: uid,
      email: email,
      createdAt: createdAt,
    );
  }
}