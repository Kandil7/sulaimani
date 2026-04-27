import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/local/database_service.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/data_backup_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  final DatabaseService _databaseService;
  final DataBackupService? _backupService;

  SettingsBloc({
    required SettingsRepository repository,
    required DatabaseService databaseService,
    DataBackupService? backupService,
  })  : _repository = repository,
        _databaseService = databaseService,
        _backupService = backupService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<ResetSettings>(_onResetSettings);
    on<CreateBackup>(_onCreateBackup);
    on<RestoreBackup>(_onRestoreBackup);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsSaving(event.settings));
    try {
      final settings = await _repository.saveSettings(event.settings);
      emit(SettingsSaved(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _repository.resetToDefaults();
      final settings = await _repository.getSettings();
      emit(SettingsSaved(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onCreateBackup(
    CreateBackup event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      // Get backup service
      final backupService = _backupService ?? sl<DataBackupService>();

      // Get custom path from event or from settings
      String? customPath = event.customPath;
      if (customPath == null || customPath.isEmpty) {
        final settings = await _repository.getSettings();
        customPath = settings.customBackupPath;
      }

      // Set custom path if provided
      if (customPath != null && customPath.isNotEmpty) {
        backupService.setCustomBackupPath(customPath);
      }

      // Export full backup (CSV format)
      final backupPath =
          await backupService.exportFullBackup(includeSales: true);

      // Update last backup date in settings
      await _repository.updateLastBackupDate();
      final settings = await _repository.getSettings();

      emit(BackupCreated(backupPath: backupPath, settings: settings));
    } catch (e) {
      emit(SettingsError('فشل في إنشاء النسخة الاحتياطية: $e'));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackup event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      // Check if it's a CSV file (new backup format)
      final isCsvFile = event.backupPath.toLowerCase().endsWith('.csv');

      if (isCsvFile) {
        // Import from CSV using DataBackupService
        final backupService = _backupService ?? sl<DataBackupService>();
        final fileName =
            event.backupPath.split(RegExp(r'[/\\]')).last.toLowerCase();

        ImportResult? result;

        if (fileName.contains('products')) {
          result = await backupService.importProducts(event.backupPath);
        } else if (fileName.contains('customers')) {
          result = await backupService.importCustomers(event.backupPath);
        } else {
          // Try generic import
          final importResult =
              await backupService.importProducts(event.backupPath);
          if (!importResult.success) {
            final customerResult =
                await backupService.importCustomers(event.backupPath);
            result = ImportResult(
              success: customerResult.success,
              message:
                  'products: ${importResult.message}, customers: ${customerResult.message}',
              successCount:
                  importResult.successCount + customerResult.successCount,
            );
          } else {
            result = importResult;
          }
        }

        if (result != null) {
          final settings = await _repository.getSettings();
          emit(BackupRestored(success: result.success));
          emit(SettingsSaved(settings));
        } else {
          emit(const SettingsError('فشل استيراد البيانات'));
        }
      } else {
        // Original .isar file restore
        final dbPath = await _repository.restoreFromBackup(event.backupPath);
        if (dbPath != null) {
          // DB was closed after restore - reopen it
          await _databaseService.reopen();
          // Reload settings from restored DB
          final settings = await _repository.getSettings();
          emit(SettingsSaved(settings));
        } else {
          emit(const SettingsError('ملف النسخة الاحتياطية غير موجود'));
        }
      }
    } catch (e) {
      emit(SettingsError('خطأ في الاستعادة: $e'));
    }
  }
}
