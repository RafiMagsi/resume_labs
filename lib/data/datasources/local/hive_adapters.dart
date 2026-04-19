import 'package:hive/hive.dart';

import 'adapters/education_model_adapter.dart';
import 'adapters/resume_model_adapter.dart';
import 'adapters/skill_model_adapter.dart';
import 'adapters/work_experience_model_adapter.dart';
import 'hive_type_ids.dart';

void registerHiveAdapters() {
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
}