abstract final class DateFormatter {
  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  static String yyyyMmDd(DateTime date) {
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }

  static String ddMmYyyy(DateTime date) {
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  static String monthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String dateTimeReadable(DateTime date) {
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = twoDigits(date.minute);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${ddMmYyyy(date)} $hour:$minute $period';
  }
}
