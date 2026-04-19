import 'package:hive/hive.dart';

import '../../../models/education_model.dart';
import '../../../models/resume_model.dart';
import '../../../models/skill_model.dart';
import '../../../models/work_experience_model.dart';
import '../hive_type_ids.dart';

class ResumeModelAdapter extends TypeAdapter<ResumeModel> {
  @override
  final int typeId = HiveTypeIds.resumeModel;

  @override
  ResumeModel read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final title = reader.readString();
    final personalSummary = reader.readString();
    final workExperiences = reader.readList().cast<WorkExperienceModel>();
    final educations = reader.readList().cast<EducationModel>();
    final skills = reader.readList().cast<SkillModel>();
    final createdAtMillis = reader.readInt();
    final updatedAtMillis = reader.readInt();

    return ResumeModel(
      id: id,
      userId: userId,
      title: title,
      personalSummary: personalSummary,
      workExperiences: workExperiences,
      educations: educations,
      skills: skills,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
    );
  }

  @override
  void write(BinaryWriter writer, ResumeModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.title);
    writer.writeString(obj.personalSummary);
    writer.writeList(obj.workExperiences);
    writer.writeList(obj.educations);
    writer.writeList(obj.skills);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
