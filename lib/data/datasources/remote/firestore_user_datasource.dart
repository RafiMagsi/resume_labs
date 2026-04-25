import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/user_profile_model.dart';

abstract interface class FirestoreUserDatasource {
  Future<UserProfileModel> getUserDoc(String uid);

  Stream<int> streamCredits(String uid);

  Future<void> addCredits(String uid, int amount);

  Future<void> deductCredit(String uid);

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
  Stream<int> streamCredits(String uid) {
    return _firestore
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0;
      return doc.data()?['availableCredits'] as int? ?? 0;
    }).handleError((e) {
      throw AppException('Failed to stream credits: $e');
    });
  }

  @override
  Future<void> addCredits(String uid, int amount) async {
    try {
      await _firestore.collection(AppStrings.usersCollection).doc(uid).update({
        'availableCredits': FieldValue.increment(amount),
        'lastPurchaseDate': DateTime.now(),
      });
    } catch (e) {
      throw AppException('Failed to add credits: $e');
    }
  }

  @override
  Future<void> deductCredit(String uid) async {
    try {
      await _firestore.collection(AppStrings.usersCollection).doc(uid).update({
        'availableCredits': FieldValue.increment(-1),
      });
    } catch (e) {
      throw AppException('Failed to deduct credit: $e');
    }
  }

  @override
  Future<void> createUserDoc({
    required String uid,
    required String email,
  }) async {
    try {
      await _firestore.collection(AppStrings.usersCollection).doc(uid).set({
        'uid': uid,
        'email': email,
        'createdAt': DateTime.now(),
        'availableCredits': 0,
      });
    } catch (e) {
      throw AppException('Failed to create user document: $e');
    }
  }
}
