class Education {
  final String school;
  final String degree;
  final String field;
  final DateTime graduationDate;
  final double? gpa;

  const Education({
    required this.school,
    required this.degree,
    required this.field,
    required this.graduationDate,
    required this.gpa,
  });

  Education copyWith({
    String? school,
    String? degree,
    String? field,
    DateTime? graduationDate,
    double? gpa,
    bool clearGpa = false,
  }) {
    return Education(
      school: school ?? this.school,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      graduationDate: graduationDate ?? this.graduationDate,
      gpa: clearGpa ? null : (gpa ?? this.gpa),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Education &&
        other.school == school &&
        other.degree == degree &&
        other.field == field &&
        other.graduationDate == graduationDate &&
        other.gpa == gpa;
  }

  @override
  int get hashCode {
    return school.hashCode ^
        degree.hashCode ^
        field.hashCode ^
        graduationDate.hashCode ^
        gpa.hashCode;
  }
}