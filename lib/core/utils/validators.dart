class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'يجب إدخال رقم صحيح';
    }
    if (number <= 0) {
      return 'الرقم يجب أن يكون أكبر من صفر';
    }
    return null;
  }

  static String? positiveNumberOrZero(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'يجب إدخال رقم صحيح';
    }
    if (number < 0) {
      return 'الرقم يجب أن يكون أكبر من أو يساوي صفر';
    }
    return null;
  }

  static String? integerNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'يجب إدخال عدد صحيح';
    }
    if (number <= 0) {
      return 'الرقم يجب أن يكون أكبر من صفر';
    }
    return null;
  }
}
