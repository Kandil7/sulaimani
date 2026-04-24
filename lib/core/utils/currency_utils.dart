import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
