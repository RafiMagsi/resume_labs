class UserCredits {
  final String uid;
  final int availableCredits;
  final DateTime lastPurchaseDate;

  const UserCredits({
    required this.uid,
    required this.availableCredits,
    required this.lastPurchaseDate,
  });

  UserCredits copyWith({
    String? uid,
    int? availableCredits,
    DateTime? lastPurchaseDate,
  }) {
    return UserCredits(
      uid: uid ?? this.uid,
      availableCredits: availableCredits ?? this.availableCredits,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserCredits &&
        other.uid == uid &&
        other.availableCredits == availableCredits &&
        other.lastPurchaseDate == lastPurchaseDate;
  }

  @override
  int get hashCode =>
      uid.hashCode ^ availableCredits.hashCode ^ lastPurchaseDate.hashCode;
}
