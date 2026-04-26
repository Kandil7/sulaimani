import 'dart:io';
import 'package:isar/isar.dart';
import '../models/settings_model.dart';
import 'package:path_provider/path_provider.dart';

class SettingsRepository {
  final Isar _isar;

  SettingsRepository(this._isar);

  Future<SettingsModel> getSettings() async {
    final settings = await _isar.settingsModels.get(1);
    if (settings != null) {
      return settings;
    }
    // Create default settings if none exist
    final defaultSettings = SettingsModel.defaults;
    defaultSettings.createdAt = DateTime.now();
    defaultSettings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.settingsModels.put(defaultSettings);
    });
    return defaultSettings;
  }

  Future<SettingsModel> saveSettings(SettingsModel settings) async {
    settings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.settingsModels.put(settings);
    });
    return settings;
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = SettingsModel.defaults;
    defaultSettings.createdAt = DateTime.now();
    defaultSettings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.settingsModels.put(defaultSettings);
    });
  }

  Future<String> createBackup() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/sulaimani_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${backupDir.path}/backup_$timestamp.isar';

    // Copy the database file
    final dbPath = _isar.path;
    if (dbPath != null) {
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
      }
    }

    // Update last backup date
    final settings = await getSettings();
    settings.lastBackupDate = DateTime.now();
    await saveSettings(settings);

    return backupPath;
  }

  /// Returns the current database path so callers know where to copy
  String? get currentDbPath => _isar.path;

  /// Restore from a backup file. After restore, the app may need a refresh.
  /// Returns true if restore succeeded.
  Future<bool> restoreFromBackup(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      return false;
    }

    final dbPath = _isar.path;
    if (dbPath == null) return false;

    // Close the database first
    await _isar.close();

    // Copy backup over current db
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await backupFile.copy(dbPath);

    return true;
  }
}
