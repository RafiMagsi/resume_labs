import 'package:hive/hive.dart';

import '../../../models/education_model.dart';
import '../hive_type_ids.dart';

class EducationModelAdapter extends TypeAdapter<EducationModel> {
  @override
  final int typeId = HiveTypeIds.educationModel;

  @override
  EducationModel read(BinaryReader reader) {
    final school = reader.readString();
    final degree = reader.readString();
    final field = reader.readString();
    final graduationDateMillis = reader.readInt();
    final hasGpa = reader.readBool();
    final gpa = hasGpa ? reader.readDouble() : null;

    return EducationModel(
      school: school,
      degree: degree,
      field: field,
      graduationDate: DateTime.fromMillisecondsSinceEpoch(graduationDateMillis),
      gpa: gpa,
    );
  }

  @override
  void write(BinaryWriter writer, EducationModel obj) {
    writer.writeString(obj.school);
    writer.writeString(obj.degree);
    writer.writeString(obj.field);
    writer.writeInt(obj.graduationDate.millisecondsSinceEpoch);
    writer.writeBool(obj.gpa != null);
    if (obj.gpa != null) {
      writer.writeDouble(obj.gpa!);
    }
  }
}