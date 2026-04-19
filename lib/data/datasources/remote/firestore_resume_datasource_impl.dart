import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../models/resume_model.dart';
import 'firestore_resume_datasource.dart';

class FirestoreResumeDataSourceImpl implements FirestoreResumeDataSource {
  final FirebaseFirestore firestore;

  const FirestoreResumeDataSourceImpl(this.firestore);

  static const String _collectionName = 'resumes';

  CollectionReference<Map<String, dynamic>> get _resumesCollection =>
      firestore.collection(_collectionName);

  @override
  Future<ResumeModel> createResume(ResumeModel resume) async {
    try {
      final data = resume.toJson();
      await _resumesCollection.doc(resume.id).set(data);
      return resume;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to create resume.',
        code: 'unknown-create-resume-error',
      );
    }
  }

  @override
  Future<ResumeModel?> getResumeById(String resumeId) async {
    try {
      final doc = await _resumesCollection.doc(resumeId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return ResumeModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to load resume.',
        code: 'unknown-get-resume-error',
      );
    }
  }

  @override
  Future<ResumeModel> updateResume(ResumeModel resume) async {
    try {
      final data = resume.toJson();
      await _resumesCollection.doc(resume.id).update(data);
      return resume;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to update resume.',
        code: 'unknown-update-resume-error',
      );
    }
  }

  @override
  Future<void> deleteResume(String resumeId) async {
    try {
      await _resumesCollection.doc(resumeId).delete();
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to delete resume.',
        code: 'unknown-delete-resume-error',
      );
    }
  }

  @override
  Future<List<ResumeModel>> getAllResumes({
    required String userId,
  }) async {
    try {
      final snapshot = await _resumesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ResumeModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to load resumes.',
        code: 'unknown-get-all-resumes-error',
      );
    }
  }

  @override
  Stream<List<ResumeModel>> watchAllResumes({
    required String userId,
  }) {
    try {
      return _resumesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ResumeModel.fromJson(doc.data()))
                .toList(),
          );
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const ServerException(
        'Failed to watch resumes.',
        code: 'unknown-watch-resumes-error',
      );
    }
  }

  AppException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const AuthException(
          'You do not have permission to access this resume data.',
          code: 'permission-denied',
        );
      case 'unavailable':
        return const NetworkException(
          'Service is currently unavailable. Please try again later.',
          code: 'unavailable',
        );
      case 'not-found':
        return const ServerException(
          'Requested resume was not found.',
          code: 'not-found',
        );
      case 'already-exists':
        return const ServerException(
          'A resume with this ID already exists.',
          code: 'already-exists',
        );
      case 'cancelled':
        return const ServerException(
          'The request was cancelled.',
          code: 'cancelled',
        );
      case 'deadline-exceeded':
        return const NetworkException(
          'The request timed out. Please try again.',
          code: 'deadline-exceeded',
        );
      case 'invalid-argument':
        return const ValidationException(
          'Invalid resume data was provided.',
          code: 'invalid-argument',
        );
      default:
        return ServerException(
          e.message ?? 'Firestore operation failed.',
          code: e.code,
        );
    }
  }
}