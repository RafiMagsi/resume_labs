class UserProfile {
  final String uid;
  final String email;
  final DateTime createdAt;
  final int availableCredits;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.availableCredits = 0,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    int? availableCredits,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      availableCredits: availableCredits ?? this.availableCredits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.availableCredits == availableCredits;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      availableCredits.hashCode;
}
