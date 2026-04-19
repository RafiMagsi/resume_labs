extension ListX<T> on List<T> {
  bool get isNullOrEmpty => isEmpty;

  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;
}