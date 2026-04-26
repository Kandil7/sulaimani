import 'package:equatable/equatable.dart';
import '../../../data/models/settings_model.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;
  const SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsSaving extends SettingsState {
  final SettingsModel settings;
  const SettingsSaving(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsSaved extends SettingsState {
  final SettingsModel settings;
  const SettingsSaved(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class BackupCreated extends SettingsState {
  final String backupPath;
  final SettingsModel settings;
  const BackupCreated({required this.backupPath, required this.settings});
  @override
  List<Object?> get props => [backupPath, settings];
}

class BackupRestored extends SettingsState {
  final bool success;
  const BackupRestored({this.success = true});
  @override
  List<Object?> get props => [success];
}
