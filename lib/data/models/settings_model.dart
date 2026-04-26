import 'package:isar/isar.dart';

part 'settings_model.g.dart';

@collection
class SettingsModel {
  Id id = 1; // Singleton - always use id 1

  late String pharmacyName;
  String? pharmacyAddress;
  String? pharmacyPhone;
  String? invoiceHeader;
  String? invoiceFooter;
  String? invoiceLogoPath;

  // Alert Settings
  int expiryWarningDays = 30;
  int lowStockWarning = 10;
  bool enableNotificationSounds = true;
  bool enableWindowsNotifications = true;

  // Backup Settings
  bool autoBackupEnabled = false;
  int backupIntervalHours = 24;
  DateTime? lastBackupDate;
  DateTime? nextScheduledBackup;

  late DateTime createdAt;
  late DateTime updatedAt;

  static SettingsModel get defaults => SettingsModel()
    ..pharmacyName = 'صيدلية السليماني'
    ..pharmacyAddress = null
    ..pharmacyPhone = null
    ..invoiceHeader = null
    ..invoiceFooter = null
    ..invoiceLogoPath = null
    ..expiryWarningDays = 30
    ..lowStockWarning = 10
    ..enableNotificationSounds = true
    ..enableWindowsNotifications = true
    ..autoBackupEnabled = false
    ..backupIntervalHours = 24
    ..lastBackupDate = null
    ..nextScheduledBackup = null
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();
}
