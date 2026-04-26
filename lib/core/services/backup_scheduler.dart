import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/settings_repository.dart';

/// Manages automatic backup scheduling.
/// Periodically checks if a backup is due and creates one.
class BackupScheduler {
  static final BackupScheduler _instance = BackupScheduler._internal();
  factory BackupScheduler() => _instance;
  BackupScheduler._internal();

  Timer? _checkTimer;
  SettingsRepository? _settingsRepository;
  bool _isRunning = false;

  /// Start the scheduler. Call once after app init.
  Future<void> start({required SettingsRepository settingsRepository}) async {
    if (_isRunning) return;
    _settingsRepository = settingsRepository;
    _isRunning = true;

    // Check immediately, then every hour
    _scheduleNextCheck();
    debugPrint('BackupScheduler: Started');
  }

  /// Stop the scheduler. Called when auto-backup is disabled.
  void stop() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _isRunning = false;
    debugPrint('BackupScheduler: Stopped');
  }

  /// Force a check right now (useful after settings change).
  Future<void> checkNow() async {
    await _performBackupCheck();
  }

  void _scheduleNextCheck() {
    _checkTimer?.cancel();
    // Check every 30 minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _performBackupCheck(),
    );
  }

  Future<void> _performBackupCheck() async {
    if (!_isRunning || _settingsRepository == null) return;

    try {
      final settings = await _settingsRepository!.getSettings();
      if (!settings.autoBackupEnabled) {
        debugPrint('BackupScheduler: Auto-backup disabled, skipping');
        return;
      }

      final now = DateTime.now();
      final nextBackup = settings.nextScheduledBackup;

      if (nextBackup == null || now.isAfter(nextBackup)) {
        debugPrint('BackupScheduler: Creating scheduled backup...');
        final backupPath = await _settingsRepository!.createBackup();
        debugPrint('BackupScheduler: Backup created at $backupPath');

        // Update next scheduled backup time
        settings.nextScheduledBackup = now.add(
          Duration(hours: settings.backupIntervalHours),
        );
        await _settingsRepository!.saveSettings(settings);
        debugPrint(
          'BackupScheduler: Next backup scheduled for ${settings.nextScheduledBackup}',
        );
      }
    } catch (e) {
      debugPrint('BackupScheduler: Backup check failed: $e');
    }
  }

  /// Returns the next scheduled backup time or null if disabled.
  Future<DateTime?> getNextBackupTime() async {
    if (_settingsRepository == null) return null;
    try {
      final settings = await _settingsRepository!.getSettings();
      if (!settings.autoBackupEnabled) return null;
      return settings.nextScheduledBackup;
    } catch (e) {
      return null;
    }
  }
}
