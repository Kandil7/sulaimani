import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
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
      final backupPath = await _repository.createBackup();
      final settings = await _repository.getSettings();
      emit(BackupCreated(backupPath: backupPath, settings: settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackup event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _repository.restoreFromBackup(event.backupPath);
      final settings = await _repository.getSettings();
      emit(BackupRestored(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
