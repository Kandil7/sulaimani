import 'package:equatable/equatable.dart';
import '../../../data/models/settings_model.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final SettingsModel settings;
  const UpdateSettings(this.settings);
  @override
  List<Object?> get props => [settings];
}

class ResetSettings extends SettingsEvent {}

class CreateBackup extends SettingsEvent {
  final String? customPath;
  const CreateBackup({this.customPath});
  @override
  List<Object?> get props => [customPath];
}

class RestoreBackup extends SettingsEvent {
  final String backupPath;
  const RestoreBackup(this.backupPath);
  @override
  List<Object?> get props => [backupPath];
}
