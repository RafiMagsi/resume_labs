import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:resume_labs/data/datasources/local/adapters/education_model_adapter.dart';
import 'package:resume_labs/data/datasources/local/adapters/resume_model_adapter.dart';
import 'package:resume_labs/data/datasources/local/adapters/skill_model_adapter.dart';
import 'package:resume_labs/data/datasources/local/adapters/work_experience_model_adapter.dart';
import 'package:resume_labs/data/datasources/local/hive_type_ids.dart';
import 'package:resume_labs/data/datasources/local/resume_local_datasource_impl.dart';
import 'package:resume_labs/data/models/education_model.dart';
import 'package:resume_labs/data/models/resume_model.dart';
import 'package:resume_labs/data/models/skill_model.dart';
import 'package:resume_labs/data/models/work_experience_model.dart';

void main() {
  late Directory tempDir;
  late ResumeLocalDataSourceImpl dataSource;

  ResumeModel buildResume({
    required String id,
    required String userId,
    required DateTime updatedAt,
  }) {
    return ResumeModel(
      id: id,
      userId: userId,
      title: 'Resume $id',
      personalSummary: 'Summary $id',
      workExperiences: [
        WorkExperienceModel(
          company: 'Company',
          role: 'Engineer',
          location: 'Remote',
          startDate: DateTime(2020, 1, 1),
          endDate: null,
          bulletPoints: const ['Built features'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        EducationModel(
          school: 'FAST',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2019, 1, 1),
          gpa: 3.5,
        ),
      ],
      skills: const [
        SkillModel(
          name: 'Flutter',
          category: 'Mobile',
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: updatedAt,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resume_labs_hive_test');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(HiveTypeIds.skillModel)) {
      Hive.registerAdapter(SkillModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.educationModel)) {
      Hive.registerAdapter(EducationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.workExperienceModel)) {
      Hive.registerAdapter(WorkExperienceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.resumeModel)) {
      Hive.registerAdapter(ResumeModelAdapter());
    }

    dataSource = ResumeLocalDataSourceImpl(Hive);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('cacheResume writes and getCachedResumes reads back item', () async {
    final resume = buildResume(
      id: '1',
      userId: 'user-1',
      updatedAt: DateTime(2024, 5, 1),
    );

    await dataSource.cacheResume(resume);

    final cached = await dataSource.getCachedResumes(userId: 'user-1');

    expect(cached.length, 1);
    expect(cached.first.id, '1');
  });

  test('cacheResumes stores multiple resumes and filters by userId', () async {
    final resume1 = buildResume(
      id: '1',
      userId: 'user-1',
      updatedAt: DateTime(2024, 5, 1),
    );
    final resume2 = buildResume(
      id: '2',
      userId: 'user-1',
      updatedAt: DateTime(2024, 6, 1),
    );
    final resume3 = buildResume(
      id: '3',
      userId: 'user-2',
      updatedAt: DateTime(2024, 7, 1),
    );

    await dataSource.cacheResumes([resume1, resume2, resume3]);

    final cached = await dataSource.getCachedResumes(userId: 'user-1');

    expect(cached.length, 2);
    expect(cached.first.id, '2');
    expect(cached.last.id, '1');
  });

  test('clearCachedResumes clears only requested user data', () async {
    final resume1 = buildResume(
      id: '1',
      userId: 'user-1',
      updatedAt: DateTime(2024, 5, 1),
    );
    final resume2 = buildResume(
      id: '2',
      userId: 'user-2',
      updatedAt: DateTime(2024, 6, 1),
    );

    await dataSource.cacheResumes([resume1, resume2]);

    await dataSource.clearCachedResumes(userId: 'user-1');

    final user1 = await dataSource.getCachedResumes(userId: 'user-1');
    final user2 = await dataSource.getCachedResumes(userId: 'user-2');

    expect(user1, isEmpty);
    expect(user2.length, 1);
    expect(user2.first.id, '2');
  });

  test('clearCachedResumes with null clears all cache', () async {
    final resume1 = buildResume(
      id: '1',
      userId: 'user-1',
      updatedAt: DateTime(2024, 5, 1),
    );
    final resume2 = buildResume(
      id: '2',
      userId: 'user-2',
      updatedAt: DateTime(2024, 6, 1),
    );

    await dataSource.cacheResumes([resume1, resume2]);
    await dataSource.clearCachedResumes();

    final user1 = await dataSource.getCachedResumes(userId: 'user-1');
    final user2 = await dataSource.getCachedResumes(userId: 'user-2');

    expect(user1, isEmpty);
    expect(user2, isEmpty);
  });
}
