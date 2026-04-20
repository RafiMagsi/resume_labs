import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String uid,
    required String email,
    required DateTime createdAt,
    @Default(false) bool isPremium,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

extension UserProfileModelMapper on UserProfileModel {
  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      createdAt: createdAt,
      isPremium: isPremium,
    );
  }
}

extension UserProfileEntityMapper on UserProfile {
  UserProfileModel toModel() {
    return UserProfileModel(
      uid: uid,
      email: email,
      createdAt: createdAt,
      isPremium: isPremium,
    );
  }
}
