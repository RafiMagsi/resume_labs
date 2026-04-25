import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';

abstract interface class SystemSettingsDatasource {
  Future<String?> getOpenAiApiKey();
}

class FirestoreSystemSettingsDatasource implements SystemSettingsDatasource {
  final FirebaseFirestore firestore;

  FirestoreSystemSettingsDatasource(this.firestore);

  static const String _collection = 'system_settings';
  static const String _openAiDoc = 'openai';
  static const String _apiKeyField = 'apiKey';

  String? _cachedKey;
  DateTime? _cachedAt;

  static const Duration _cacheTtl = Duration(minutes: 15);

  @override
  Future<String?> getOpenAiApiKey() async {
    final now = DateTime.now();
    final cachedAt = _cachedAt;
    if (_cachedKey != null &&
        cachedAt != null &&
        now.difference(cachedAt) < _cacheTtl) {
      return _cachedKey;
    }

    try {
      final snapshot =
          await firestore.collection(_collection).doc(_openAiDoc).get();
      final raw = snapshot.data()?[_apiKeyField];
      final key = raw is String ? raw.trim() : null;

      _cachedKey = (key == null || key.isEmpty) ? null : key;
      _cachedAt = now;

      return _cachedKey;
    } on FirebaseException catch (e) {
      throw AppException(
        'Failed to load system settings.',
        code: e.code,
      );
    } catch (e) {
      throw AppException(
        'Failed to load system settings: $e',
        code: 'system-settings-load-failed',
      );
    }
  }
}
