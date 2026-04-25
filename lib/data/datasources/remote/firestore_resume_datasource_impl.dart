import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
      final data = _deepJsonMap(resume.toJson());
      await _resumesCollection.doc(resume.id).set(data);
      if (kDebugMode) {
        debugPrint(
          'Firestore: created resume at $_collectionName/${resume.id} (userId=${resume.userId})',
        );
      }
      return resume;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to create resume.',
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

      return ResumeModel.fromJson(_normalizeFirestoreMap(doc.data()!));
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to load resume.',
        code: 'unknown-get-resume-error',
      );
    }
  }

  @override
  Future<ResumeModel> updateResume(ResumeModel resume) async {
    try {
      if (resume.photoUrl != null && resume.photoUrl!.isNotEmpty) {
        final currentDoc = await _resumesCollection.doc(resume.id).get();
        final currentPhotoUrl = currentDoc.data()?['photoUrl'] as String?;

        if (currentPhotoUrl != resume.photoUrl) {
          final otherResumesWithPhoto = await _resumesCollection
              .where('userId', isEqualTo: resume.userId)
              .where('photoUrl', isEqualTo: resume.photoUrl)
              .where(FieldPath.documentId, isNotEqualTo: resume.id)
              .limit(1)
              .get();

          if (otherResumesWithPhoto.docs.isNotEmpty) {
            throw AppException(
              'This profile image is already linked to another resume. Please upload a new image.',
              code: 'image-already-in-use',
            );
          }
        }
      }

      final data = _deepJsonMap(resume.toJson());
      await _resumesCollection.doc(resume.id).update(data);
      if (kDebugMode) {
        debugPrint(
          'Firestore: updated resume at $_collectionName/${resume.id} (userId=${resume.userId})',
        );
      }
      return resume;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to update resume.',
        code: 'unknown-update-resume-error',
      );
    }
  }

  @override
  Future<void> deleteResume(String resumeId) async {
    try {
      await _resumesCollection.doc(resumeId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        debugPrint(
            'Firestore: soft-deleted resume at $_collectionName/$resumeId');
      }
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to delete resume.',
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
          .where('isDeleted', isNotEqualTo: true)
          .get();

      final results = <ResumeModel>[];
      var parseFailures = 0;

      for (final doc in snapshot.docs) {
        try {
          results.add(ResumeModel.fromJson(_normalizeFirestoreMap(doc.data())));
        } catch (e, st) {
          parseFailures += 1;
          if (kDebugMode) {
            debugPrint(
              'Failed to parse resume doc ${doc.id}: $e\n$st',
            );
          }
        }
      }

      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (results.isEmpty && snapshot.docs.isNotEmpty && parseFailures > 0) {
        throw const ServerException(
          'Resumes exist but could not be loaded due to incompatible data. Please update the app or re-save the resume.',
          code: 'resume-parse-error',
        );
      }

      return results;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to load resumes.',
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
          .where('isDeleted', isNotEqualTo: true)
          .snapshots()
          .map(
        (snapshot) {
          final results = <ResumeModel>[];
          for (final doc in snapshot.docs) {
            try {
              results.add(
                  ResumeModel.fromJson(_normalizeFirestoreMap(doc.data())));
            } catch (e, st) {
              if (kDebugMode) {
                debugPrint(
                  'Failed to parse resume doc ${doc.id}: $e\n$st',
                );
              }
            }
          }
          results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return results;
        },
      );
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e, st) {
      throw _mapUnknownException(
        e,
        st,
        fallbackMessage: 'Failed to watch resumes.',
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
      case 'failed-precondition':
        return const ServerException(
          'A required Firestore index may be missing. Please check your Firestore indexes and try again.',
          code: 'failed-precondition',
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

  AppException _mapUnknownException(
    Object error,
    StackTrace stackTrace, {
    required String fallbackMessage,
    required String code,
  }) {
    if (kDebugMode) {
      debugPrint(
        'FirestoreResumeDataSourceImpl error ($code): $error\n$stackTrace',
      );
    }

    if (error is AppException) return error;

    if (error is SocketException) {
      return const NetworkException(
        'No internet connection. Please check your network and try again.',
        code: 'no-internet',
      );
    }

    if (error is PlatformException) {
      return ServerException(
        error.message ?? fallbackMessage,
        code: error.code,
      );
    }

    if (error is ArgumentError || error is UnsupportedError) {
      return const ValidationException(
        'Resume data contains unsupported values. Please review your inputs and try again.',
        code: 'invalid-resume-payload',
      );
    }

    return ServerException(
      fallbackMessage,
      code: code,
    );
  }

  Map<String, dynamic> _deepJsonMap(Map<String, dynamic> json) {
    final decoded = jsonDecode(jsonEncode(json));
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const ValidationException(
      'Invalid resume data was provided.',
      code: 'invalid-resume-payload',
    );
  }

  Map<String, dynamic> _normalizeFirestoreMap(Map<String, dynamic> json) {
    final out = <String, dynamic>{};
    for (final entry in json.entries) {
      out[entry.key] = _normalizeFirestoreValue(entry.value);
    }
    return out;
  }

  dynamic _normalizeFirestoreValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map<String, dynamic>) {
      return _normalizeFirestoreMap(value);
    }

    if (value is Map) {
      return _normalizeFirestoreMap(Map<String, dynamic>.from(value));
    }

    if (value is List) {
      return value.map(_normalizeFirestoreValue).toList();
    }

    return value;
  }
}
