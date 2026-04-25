import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_details_model.freezed.dart';
part 'contact_details_model.g.dart';

@freezed
class ContactDetailsModel with _$ContactDetailsModel {
  const factory ContactDetailsModel({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? website,
    String? linkedin,
    String? github,
    String? dateOfBirth,
    String? nationality,
  }) = _ContactDetailsModel;

  factory ContactDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsModelFromJson(json);
}
