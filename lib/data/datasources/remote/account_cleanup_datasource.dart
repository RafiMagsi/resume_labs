import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';

abstract interface class AccountCleanupDatasource {
  Future<void> deleteUserData({
    required String uid,
  });
}

class AccountCleanupDatasourceImpl implements AccountCleanupDatasource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AccountCleanupDatasourceImpl({
    required this.firestore,
    required this.storage,
  });

  static const String _resumesCollection = 'resumes';

  @override
  Future<void> deleteUserData({
    required String uid,
  }) async {
    try {
      await _deleteUserDoc(uid);
      await _deleteResumes(uid);
      await _deleteResumePhotos(uid);
    } on FirebaseException catch (e) {
      throw AppException(
        'Failed to delete account data. Please try again.',
        code: e.code,
      );
    } catch (e) {
      throw AppException(
        'Failed to delete account data: $e',
        code: 'delete-account-data-failed',
      );
    }
  }

  Future<void> _deleteUserDoc(String uid) async {
    await firestore.collection(AppStrings.usersCollection).doc(uid).delete();
  }

  Future<void> _deleteResumes(String uid) async {
    // Query and hard-delete resume documents owned by the user.
    final query = await firestore
        .collection(_resumesCollection)
        .where('userId', isEqualTo: uid)
        .get();

    if (query.docs.isEmpty) return;

    // Firestore limits batch writes to 500 operations.
    const batchLimit = 450;
    for (var i = 0; i < query.docs.length; i += batchLimit) {
      final batch = firestore.batch();
      final end = (i + batchLimit).clamp(0, query.docs.length);
      for (final doc in query.docs.sublist(i, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteResumePhotos(String uid) async {
    // Best-effort: delete all storage objects under `resumes/<uid>/`.
    // If storage rules disallow listing/deleting, skip without failing the
    // entire account deletion flow (Firestore + Auth deletion is primary).
    try {
      final rootRef = storage.ref('resumes/$uid');
      await _deleteAllUnder(rootRef);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _deleteAllUnder(Reference ref) async {
    final list = await ref.listAll();
    for (final item in list.items) {
      try {
        await item.delete();
      } catch (_) {
        // ignore per-file failures
      }
    }

    for (final prefix in list.prefixes) {
      await _deleteAllUnder(prefix);
    }
  }
}
