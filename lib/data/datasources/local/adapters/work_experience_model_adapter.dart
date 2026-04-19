import 'package:hive/hive.dart';

import '../../../models/work_experience_model.dart';
import '../hive_type_ids.dart';

class WorkExperienceModelAdapter extends TypeAdapter<WorkExperienceModel> {
  @override
  final int typeId = HiveTypeIds.workExperienceModel;

  @override
  WorkExperienceModel read(BinaryReader reader) {
    final company = reader.readString();
    final role = reader.readString();
    final location = reader.readString();
    final startDateMillis = reader.readInt();
    final hasEndDate = reader.readBool();
    final endDateMillis = hasEndDate ? reader.readInt() : null;
    final bulletPoints = reader.readList().cast<String>();
    final isCurrentRole = reader.readBool();

    return WorkExperienceModel(
      company: company,
      role: role,
      location: location,
      startDate: DateTime.fromMillisecondsSinceEpoch(startDateMillis),
      endDate: endDateMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(endDateMillis),
      bulletPoints: bulletPoints,
      isCurrentRole: isCurrentRole,
    );
  }

  @override
  void write(BinaryWriter writer, WorkExperienceModel obj) {
    writer.writeString(obj.company);
    writer.writeString(obj.role);
    writer.writeString(obj.location);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeBool(obj.endDate != null);
    if (obj.endDate != null) {
      writer.writeInt(obj.endDate!.millisecondsSinceEpoch);
    }
    writer.writeList(obj.bulletPoints);
    writer.writeBool(obj.isCurrentRole);
  }
}