class UserProfile {
  final String uid;
  final String email;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ createdAt.hashCode;
}
