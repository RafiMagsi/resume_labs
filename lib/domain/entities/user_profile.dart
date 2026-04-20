class UserProfile {
  final String uid;
  final String email;
  final DateTime createdAt;
  final bool isPremium;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.isPremium = false,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode =>
      uid.hashCode ^ email.hashCode ^ createdAt.hashCode ^ isPremium.hashCode;
}
