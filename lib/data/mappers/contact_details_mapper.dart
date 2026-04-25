import '../../domain/entities/contact_details.dart';
import '../models/contact_details_model.dart';

extension ContactDetailsModelMapper on ContactDetailsModel {
  ContactDetails toEntity() {
    return ContactDetails(
      fullName: fullName,
      email: email,
      phone: phone,
      location: location,
      website: website,
      linkedin: linkedin,
      github: github,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
    );
  }
}

extension ContactDetailsEntityMapper on ContactDetails {
  ContactDetailsModel toModel() {
    return ContactDetailsModel(
      fullName: fullName,
      email: email,
      phone: phone,
      location: location,
      website: website,
      linkedin: linkedin,
      github: github,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
    );
  }
}
