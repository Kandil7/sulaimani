import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatToDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatToTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatToDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
  }

  static bool isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return today.isAfter(expiry) || today.isAtSameMomentAs(expiry);
  }

  static bool isExpiringSoon(DateTime expiryDate, {int days = 30}) {
    if (isExpired(expiryDate)) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final difference = expiry.difference(today).inDays;
    return difference <= days;
  }
}
