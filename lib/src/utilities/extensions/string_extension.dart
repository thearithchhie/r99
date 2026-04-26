extension StringsExtension on String {
  String removeDotsExceptFirst() {
    int firstDot = indexOf('.');
    return firstDot == -1 ? this : substring(0, firstDot + 1) + substring(firstDot + 1).replaceAll('.', '');
  }

  String formatPhonePreview(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || !digits.startsWith('0')) return value;

    return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 10)}';
  }
}
