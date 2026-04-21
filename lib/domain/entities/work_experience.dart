class WorkExperience {
  final String company;
  final String role;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> bulletPoints;
  final bool isCurrentRole;

  const WorkExperience({
    required this.company,
    required this.role,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.bulletPoints,
    required this.isCurrentRole,
  });

  WorkExperience copyWith({
    String? company,
    String? role,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? bulletPoints,
    bool? isCurrentRole,
    bool clearEndDate = false,
  }) {
    return WorkExperience(
      company: company ?? this.company,
      role: role ?? this.role,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      bulletPoints: bulletPoints ?? this.bulletPoints,
      isCurrentRole: isCurrentRole ?? this.isCurrentRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkExperience &&
        other.company == company &&
        other.role == role &&
        other.location == location &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        _listEquals(other.bulletPoints, bulletPoints) &&
        other.isCurrentRole == isCurrentRole;
  }

  @override
  int get hashCode {
    return company.hashCode ^
        role.hashCode ^
        location.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        Object.hashAll(bulletPoints) ^
        isCurrentRole.hashCode;
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
