extension StringX on String {
  bool get isValidEmail {
    // Practical email validation (not fully RFC-complete) that supports common
    // real-world addresses like `hello+tag@example.co.uk`.
    final emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
      r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
    );
    return emailRegex.hasMatch(trim());
  }

  bool get hasMinPasswordLength => trim().length >= 8;

  bool get isNotBlank => trim().isNotEmpty;

  String get capitalize {
    if (trim().isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get initials {
    final parts = trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
