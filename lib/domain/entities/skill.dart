class Skill {
  final String name;
  final String category;

  const Skill({
    required this.name,
    required this.category,
  });

  Skill copyWith({
    String? name,
    String? category,
  }) {
    return Skill(
      name: name ?? this.name,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Skill &&
        other.name == name &&
        other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;
}