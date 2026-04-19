import 'package:hive/hive.dart';

import '../../../models/skill_model.dart';
import '../hive_type_ids.dart';

class SkillModelAdapter extends TypeAdapter<SkillModel> {
  @override
  final int typeId = HiveTypeIds.skillModel;

  @override
  SkillModel read(BinaryReader reader) {
    final name = reader.readString();
    final category = reader.readString();

    return SkillModel(
      name: name,
      category: category,
    );
  }

  @override
  void write(BinaryWriter writer, SkillModel obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.category);
  }
}