import 'package:hive/hive.dart';

import '../../../core/errors/app_exception.dart';
import '../../models/resume_model.dart';
import 'resume_local_datasource.dart';

class ResumeLocalDataSourceImpl implements ResumeLocalDataSource {
  final HiveInterface hive;

  const ResumeLocalDataSourceImpl(this.hive);

  static const String _boxName = 'resume_cache_box';

  Future<Box<ResumeModel>> _openBox() async {
    if (hive.isBoxOpen(_boxName)) {
      return hive.box<ResumeModel>(_boxName);
    }
    return hive.openBox<ResumeModel>(_boxName);
  }

  @override
  Future<void> cacheResume(ResumeModel resume) async {
    try {
      final box = await _openBox();
      await box.put(resume.id, resume);
    } catch (_) {
      throw const CacheException(
        'Failed to cache resume.',
        code: 'cache-resume-failed',
      );
    }
  }

  @override
  Future<void> cacheResumes(List<ResumeModel> resumes) async {
    try {
      final box = await _openBox();
      final map = <String, ResumeModel>{
        for (final resume in resumes) resume.id: resume,
      };
      await box.putAll(map);
    } catch (_) {
      throw const CacheException(
        'Failed to cache resumes.',
        code: 'cache-resumes-failed',
      );
    }
  }

  @override
  Future<List<ResumeModel>> getCachedResumes({
    required String userId,
  }) async {
    try {
      final box = await _openBox();
      final items = box.values.where((resume) => resume.userId == userId).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return items;
    } catch (_) {
      throw const CacheException(
        'Failed to load cached resumes.',
        code: 'get-cached-resumes-failed',
      );
    }
  }

  @override
  Future<void> clearCachedResumes({
    String? userId,
  }) async {
    try {
      final box = await _openBox();

      if (userId == null) {
        await box.clear();
        return;
      }

      final keysToDelete = box.keys
          .where((key) {
            final value = box.get(key);
            return value?.userId == userId;
          })
          .toList();

      await box.deleteAll(keysToDelete);
    } catch (_) {
      throw const CacheException(
        'Failed to clear cached resumes.',
        code: 'clear-cached-resumes-failed',
      );
    }
  }
}