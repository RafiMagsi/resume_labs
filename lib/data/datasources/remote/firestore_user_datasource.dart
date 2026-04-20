import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/user_profile_model.dart';

abstract interface class FirestoreUserDatasource {
  Future<UserProfileModel> getUserDoc(String uid);

  Future<void> setPremiumStatus(String uid, bool isPremium);

  Stream<bool> streamPremiumStatus(String uid);

  Future<void> createUserDoc({
    required String uid,
    required String email,
  });
}

class FirestoreUserDatasourceImpl implements FirestoreUserDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserProfileModel> getUserDoc(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppStrings.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw AppException('User document not found');
      }

      return UserProfileModel.fromJson(doc.data()!);
    } catch (e) {
      throw AppException('Failed to fetch user document: $e');
    }
  }

  @override
  Future<void> setPremiumStatus(String uid, bool isPremium) async {
    try {
      await _firestore
          .collection(AppStrings.usersCollection)
          .doc(uid)
          .update({
        'isPremium': isPremium,
      });
    } catch (e) {
      throw AppException('Failed to update premium status: $e');
    }
  }

  @override
  Stream<bool> streamPremiumStatus(String uid) {
    return _firestore
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          return doc.data()?['isPremium'] as bool? ?? false;
        })
        .handleError((e) {
          throw AppException('Failed to stream premium status: $e');
        });
  }

  @override
  Future<void> createUserDoc({
    required String uid,
    required String email,
  }) async {
    try {
      await _firestore
          .collection(AppStrings.usersCollection)
          .doc(uid)
          .set({
        'uid': uid,
        'email': email,
        'createdAt': DateTime.now(),
        'isPremium': false,
      });
    } catch (e) {
      throw AppException('Failed to create user document: $e');
    }
  }
}
