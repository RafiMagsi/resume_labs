class ContactDetails {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? location;
  final String? website;
  final String? linkedin;
  final String? github;
  final String? dateOfBirth;
  final String? nationality;

  const ContactDetails({
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.website,
    this.linkedin,
    this.github,
    this.dateOfBirth,
    this.nationality,
  });

  ContactDetails copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? website,
    String? linkedin,
    String? github,
    String? dateOfBirth,
    String? nationality,
  }) {
    return ContactDetails(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactDetails &&
        other.fullName == fullName &&
        other.email == email &&
        other.phone == phone &&
        other.location == location &&
        other.website == website &&
        other.linkedin == linkedin &&
        other.github == github &&
        other.dateOfBirth == dateOfBirth &&
        other.nationality == nationality;
  }

  @override
  int get hashCode {
    return (fullName?.hashCode ?? 0) ^
        (email?.hashCode ?? 0) ^
        (phone?.hashCode ?? 0) ^
        (location?.hashCode ?? 0) ^
        (website?.hashCode ?? 0) ^
        (linkedin?.hashCode ?? 0) ^
        (github?.hashCode ?? 0) ^
        (dateOfBirth?.hashCode ?? 0) ^
        (nationality?.hashCode ?? 0);
  }
}
