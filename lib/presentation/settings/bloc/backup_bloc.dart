import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/data_backup_service.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class ExportFullBackup extends BackupEvent {
  final bool includeSales;

  const ExportFullBackup({this.includeSales = true});

  @override
  List<Object?> get props => [includeSales];
}

class ExportProducts extends BackupEvent {}

class ExportCustomers extends BackupEvent {}

class ExportSales extends BackupEvent {}

class ImportProducts extends BackupEvent {
  final String filePath;

  const ImportProducts(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ImportCustomers extends BackupEvent {
  final String filePath;

  const ImportCustomers(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class LoadBackupList extends BackupEvent {}

class CleanupOldBackups extends BackupEvent {
  final int keepCount;

  const CleanupOldBackups({this.keepCount = 10});

  @override
  List<Object?> get props => [keepCount];
}

// ============================================================================
// STATES
// ============================================================================

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {
  final String message;

  const BackupLoading(this.message);

  @override
  List<Object?> get props => [message];
}

class BackupSuccess extends BackupState {
  final String message;
  final String? filePath;

  const BackupSuccess(this.message, {this.filePath});

  @override
  List<Object?> get props => [message, filePath];
}

class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImportResultState extends BackupState {
  final ImportResult result;

  const ImportResultState(this.result);

  @override
  List<Object?> get props => [result.success, result.message];
}

class BackupListLoaded extends BackupState {
  final List<BackupInfo> backups;

  const BackupListLoaded(this.backups);

  @override
  List<Object?> get props => [backups];
}

// ============================================================================
// BLOC
// ============================================================================

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final DataBackupService _backupService;

  BackupBloc({required DataBackupService backupService})
      : _backupService = backupService,
        super(BackupInitial()) {
    on<ExportFullBackup>(_onExportFullBackup);
    on<ExportProducts>(_onExportProducts);
    on<ExportCustomers>(_onExportCustomers);
    on<ExportSales>(_onExportSales);
    on<ImportProducts>(_onImportProducts);
    on<ImportCustomers>(_onImportCustomers);
    on<LoadBackupList>(_onLoadBackupList);
    on<CleanupOldBackups>(_onCleanupOldBackups);
  }

  Future<void> _onExportFullBackup(
    ExportFullBackup event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Creating full backup...'));
    try {
      final path = await _backupService.exportFullBackup(
        includeSales: event.includeSales,
      );
      emit(BackupSuccess('Full backup created successfully', filePath: path));
    } catch (e) {
      emit(BackupError('Failed to create backup: $e'));
    }
  }

  Future<void> _onExportProducts(
    ExportProducts event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Exporting products...'));
    try {
      final path = await _backupService.exportProducts();
      emit(BackupSuccess('Products exported successfully', filePath: path));
    } catch (e) {
      emit(BackupError('Failed to export products: $e'));
    }
  }

  Future<void> _onExportCustomers(
    ExportCustomers event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Exporting customers...'));
    try {
      final path = await _backupService.exportCustomers();
      emit(BackupSuccess('Customers exported successfully', filePath: path));
    } catch (e) {
      emit(BackupError('Failed to export customers: $e'));
    }
  }

  Future<void> _onExportSales(
    ExportSales event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Exporting sales...'));
    try {
      final path = await _backupService.exportSales();
      emit(BackupSuccess('Sales exported successfully', filePath: path));
    } catch (e) {
      emit(BackupError('Failed to export sales: $e'));
    }
  }

  Future<void> _onImportProducts(
    ImportProducts event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Importing products...'));
    try {
      final result = await _backupService.importProducts(event.filePath);
      emit(ImportResultState(result));
    } catch (e) {
      emit(BackupError('Failed to import products: $e'));
    }
  }

  Future<void> _onImportCustomers(
    ImportCustomers event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Importing customers...'));
    try {
      final result = await _backupService.importCustomers(event.filePath);
      emit(ImportResultState(result));
    } catch (e) {
      emit(BackupError('Failed to import customers: $e'));
    }
  }

  Future<void> _onLoadBackupList(
    LoadBackupList event,
    Emitter<BackupState> emit,
  ) async {
    try {
      final backups = await _backupService.getBackupList();
      emit(BackupListLoaded(backups));
    } catch (e) {
      emit(BackupError('Failed to load backup list: $e'));
    }
  }

  Future<void> _onCleanupOldBackups(
    CleanupOldBackups event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Cleaning up old backups...'));
    try {
      final deletedCount = await _backupService.cleanupOldBackups(
        keepCount: event.keepCount,
      );
      emit(BackupSuccess('Cleaned up $deletedCount old backups'));
    } catch (e) {
      emit(BackupError('Failed to cleanup backups: $e'));
    }
  }
}
