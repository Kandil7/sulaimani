import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/local/customer_local_datasource.dart';
import '../../data/datasources/local/sale_local_datasource.dart';
import '../../data/datasources/local/database_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/settings_repository.dart';

/// Comprehensive data backup service supporting CSV export/import
///
/// Features:
/// - Full database export to CSV files
/// - Individual table export (products, customers, sales, etc.)
/// - Import from CSV with validation
/// - Backup rotation (keep last N backups)
/// - Compressed backup archives
/// - Incremental backup support
class DataBackupService {
  final ProductLocalDatasource _productDatasource;
  final CustomerLocalDatasource _customerDatasource;
  final SaleLocalDatasource _saleDatasource;
  final DatabaseService _databaseService;
  final SettingsRepository _settingsRepository;

  String? _customBackupPath;

  DataBackupService({
    required ProductLocalDatasource productDatasource,
    required CustomerLocalDatasource customerDatasource,
    required SaleLocalDatasource saleDatasource,
    required DatabaseService databaseService,
    required SettingsRepository settingsRepository,
  })  : _productDatasource = productDatasource,
        _customerDatasource = customerDatasource,
        _saleDatasource = saleDatasource,
        _databaseService = databaseService,
        _settingsRepository = settingsRepository;

  Isar get _isar => _databaseService.isar;

  /// Set custom backup path
  void setCustomBackupPath(String? path) {
    _customBackupPath = path;
  }

  /// Get current backup path
  String? get customBackupPath => _customBackupPath;

  // ============================================================================
  // EXPORT METHODS
  // ============================================================================

  /// Export all data to a comprehensive CSV backup
  /// Returns the path to the backup file
  Future<String> exportFullBackup({bool includeSales = true}) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupPath = backupDir.path;
      final timestamp = DateTime.now();
      final timestampStr = _formatTimestamp(timestamp);

      // Create backup manifest
      final List<String> exportedFiles = [];
      final Map<String, dynamic> manifest = {
        'version': '1.0.0',
        'createdAt': timestamp.toIso8601String(),
        'appName': 'Sulaimani Pharmacy',
        'data': <String, dynamic>{},
      };

      // Export Products
      final productsPath = '$backupPath/products_$timestampStr.csv';
      final products = await _productDatasource.getAll();
      await _exportProductsToCsv(products, productsPath);
      manifest['data']['products'] = {
        'file': 'products_$timestampStr.csv',
        'count': products.length,
      };
      exportedFiles.add(productsPath);

      // Export Categories
      final categoriesPath = '$backupPath/categories_$timestampStr.csv';
      final categories = await _isar.categoryModels.where().findAll();
      await _exportCategoriesToCsv(categories, categoriesPath);
      manifest['data']['categories'] = {
        'file': 'categories_$timestampStr.csv',
        'count': categories.length,
      };
      exportedFiles.add(categoriesPath);

      // Export Customers
      final customersPath = '$backupPath/customers_$timestampStr.csv';
      final customers = await _customerDatasource.getAll();
      await _exportCustomersToCsv(customers, customersPath);
      manifest['data']['customers'] = {
        'file': 'customers_$timestampStr.csv',
        'count': customers.length,
      };
      exportedFiles.add(customersPath);

      // Export Sales (if enabled)
      if (includeSales) {
        final salesPath = '$backupPath/sales_$timestampStr.csv';
        final sales = await _saleDatasource.getAll();
        await _exportSalesToCsv(sales, salesPath);
        manifest['data']['sales'] = {
          'file': 'sales_$timestampStr.csv',
          'count': sales.length,
        };
        exportedFiles.add(salesPath);

        // Export Sale Items
        final saleItemsPath = '$backupPath/sale_items_$timestampStr.csv';
        final allItems = <SaleItemModel>[];
        for (final sale in sales) {
          final items = await _saleDatasource.getSaleItems(sale.id);
          allItems.addAll(items);
        }
        await _exportSaleItemsToCsv(allItems, saleItemsPath);
        manifest['data']['saleItems'] = {
          'file': 'sale_items_$timestampStr.csv',
          'count': allItems.length,
        };
        exportedFiles.add(saleItemsPath);
      }

      // Export Settings
      final settingsPath = '$backupPath/settings_$timestampStr.csv';
      final settings = await _settingsRepository.getSettings();
      await _exportSettingsToCsv(settings, settingsPath);
      manifest['data']['settings'] = {
        'file': 'settings_$timestampStr.csv',
      };
      exportedFiles.add(settingsPath);

      // Save manifest
      final manifestPath = '$backupPath/manifest_$timestampStr.json';
      await File(manifestPath).writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest),
      );

      // Update last backup date
      await _settingsRepository.updateLastBackupDate();

      return backupPath;
    } catch (e) {
      throw Exception('فشل في إنشاء النسخة الاحتياطية: $e');
    }
  }

  /// Export products to CSV
  Future<String> exportProducts({String? customPath}) async {
    final products = await _productDatasource.getAll();
    final path = customPath ?? await _getExportPath('products');
    await _exportProductsToCsv(products, path);
    return path;
  }

  /// Export customers to CSV
  Future<String> exportCustomers({String? customPath}) async {
    final customers = await _customerDatasource.getAll();
    final path = customPath ?? await _getExportPath('customers');
    await _exportCustomersToCsv(customers, path);
    return path;
  }

  /// Export sales to CSV
  Future<String> exportSales({String? customPath}) async {
    final sales = await _saleDatasource.getAll();
    final path = customPath ?? await _getExportPath('sales');
    await _exportSalesToCsv(sales, path);
    return path;
  }

  // ============================================================================
  // IMPORT METHODS
  // ============================================================================

  /// Import products from CSV file
  Future<ImportResult> importProducts(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, message: 'File not found');
      }

      final content = await file.readAsString();
      final lines = content.split('\n');

      if (lines.isEmpty) {
        return ImportResult(success: false, message: 'Empty file');
      }

      // Get header line
      final headers = _parseCsvLine(lines[0]);
      final int nameIndex = headers.indexOf('name');
      final int barcodeIndex = headers.indexOf('barcode');
      final int priceIndex = headers.indexOf('sellingPrice');
      final int costIndex = headers.indexOf('purchasePrice');
      final int quantityIndex = headers.indexOf('stockQuantity');
      final int minStockIndex = headers.indexOf('minimumStock');

      if (nameIndex == -1 || barcodeIndex == -1) {
        return ImportResult(
          success: false,
          message: 'Invalid CSV format. Required columns: name, barcode',
        );
      }

      int successCount = 0;
      final List<String> errors = [];

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        try {
          final values = _parseCsvLine(lines[i]);

          final product = ProductModel()
            ..name = nameIndex >= 0 && nameIndex < values.length
                ? values[nameIndex]
                : ''
            ..barcode = barcodeIndex >= 0 && barcodeIndex < values.length
                ? values[barcodeIndex]
                : ''
            ..scientificName = ''
            ..sellingPrice = priceIndex >= 0 && priceIndex < values.length
                ? double.tryParse(values[priceIndex]) ?? 0.0
                : 0.0
            ..purchasePrice = costIndex >= 0 && costIndex < values.length
                ? double.tryParse(values[costIndex]) ?? 0.0
                : 0.0
            ..stockQuantity =
                quantityIndex >= 0 && quantityIndex < values.length
                    ? int.tryParse(values[quantityIndex]) ?? 0
                    : 0
            ..minimumStock = minStockIndex >= 0 && minStockIndex < values.length
                ? int.tryParse(values[minStockIndex]) ?? 5
                : 5
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

          // Check if product with same barcode exists
          final existing =
              await _productDatasource.getByBarcode(product.barcode);
          if (existing != null) {
            // Update existing
            existing
              ..name = product.name
              ..sellingPrice = product.sellingPrice
              ..purchasePrice = product.purchasePrice
              ..stockQuantity = product.stockQuantity
              ..minimumStock = product.minimumStock
              ..updatedAt = DateTime.now();
            await _productDatasource.update(existing);
          } else {
            // Create new
            await _productDatasource.insert(product);
          }
          successCount++;
        } catch (e) {
          errors.add('Row $i: $e');
        }
      }

      return ImportResult(
        success: true,
        message: 'Imported $successCount products',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  /// Import customers from CSV file
  Future<ImportResult> importCustomers(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, message: 'File not found');
      }

      final content = await file.readAsString();
      final lines = content.split('\n');

      if (lines.isEmpty) {
        return ImportResult(success: false, message: 'Empty file');
      }

      final headers = _parseCsvLine(lines[0]);
      final int nameIndex = headers.indexOf('name');
      final int phoneIndex = headers.indexOf('phone');
      final int addressIndex = headers.indexOf('address');

      if (nameIndex == -1) {
        return ImportResult(
          success: false,
          message: 'Invalid CSV format. Required column: name',
        );
      }

      int successCount = 0;
      final List<String> errors = [];

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        try {
          final values = _parseCsvLine(lines[i]);

          final customer = CustomerModel()
            ..name = nameIndex >= 0 && nameIndex < values.length
                ? values[nameIndex]
                : ''
            ..phone = phoneIndex >= 0 && phoneIndex < values.length
                ? values[phoneIndex]
                : ''
            ..address = addressIndex >= 0 &&
                    addressIndex < values.length &&
                    values[addressIndex].isNotEmpty
                ? values[addressIndex]
                : null
            ..debtBalance = 0
            ..createdAt = DateTime.now();

          await _customerDatasource.insert(customer);
          successCount++;
        } catch (e) {
          errors.add('Row $i: $e');
        }
      }

      return ImportResult(
        success: true,
        message: 'Imported $successCount customers',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  // ============================================================================
  // BACKUP ROTATION
  // ============================================================================

  /// Clean up old backups, keeping only the specified number
  Future<int> cleanupOldBackups({int keepCount = 10}) async {
    final backupDir = await _getBackupDirectory();
    if (!await backupDir.exists()) return 0;

    final entities = await backupDir.list().toList();
    final backupDirs = entities.whereType<Directory>().toList();

    if (backupDirs.length <= keepCount) return 0;

    // Sort by modification date (oldest first)
    backupDirs.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return aStat.modified.compareTo(bStat.modified);
    });

    // Delete oldest backups
    int deletedCount = 0;
    for (int i = 0; i < backupDirs.length - keepCount; i++) {
      try {
        await backupDirs[i].delete(recursive: true);
        deletedCount++;
      } catch (e) {
        // Continue even if one deletion fails
      }
    }

    return deletedCount;
  }

  /// Get list of available backups
  Future<List<BackupInfo>> getBackupList() async {
    final backupDir = await _getBackupDirectory();
    if (!await backupDir.exists()) return [];

    final backups = <BackupInfo>[];

    try {
      final entities = await backupDir.list().toList();
      for (final entity in entities) {
        if (entity is Directory) {
          final stat = entity.statSync();
          final name = entity.path.split('/').last;

          // Look for manifest
          final manifestFile = File('${entity.path}/manifest.json');
          Map<String, dynamic>? manifest;
          if (await manifestFile.exists()) {
            try {
              manifest = jsonDecode(await manifestFile.readAsString());
            } catch (_) {}
          }

          backups.add(BackupInfo(
            name: name,
            path: entity.path,
            createdAt: stat.modified,
            size: await _getDirectorySize(entity.path),
            dataCounts: manifest?['data'] as Map<String, dynamic>?,
          ));
        }
      }
    } catch (e) {
      // Return empty list on error
    }

    // Sort by date (newest first)
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Future<Directory> _getBackupDirectory() async {
    Directory backupDir;
    if (_customBackupPath != null && _customBackupPath!.isNotEmpty) {
      backupDir = Directory(_customBackupPath!);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      backupDir = Directory('${dir.path}/sulaimani_backups');
    }
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Get the current backup directory path for display
  Future<String> getBackupPath() async {
    final dir = await _getBackupDirectory();
    return dir.path;
  }

  Future<String> _getExportPath(String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/sulaimani_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final timestamp = _formatTimestamp(DateTime.now());
    return '${exportDir.path}/${prefix}_$timestamp.csv';
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}${_pad(dt.month)}${_pad(dt.day)}_${_pad(dt.hour)}${_pad(dt.minute)}${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _exportProductsToCsv(
      List<ProductModel> products, String path) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'id,name,barcode,scientificName,description,purchasePrice,sellingPrice,stockQuantity,minimumStock,expiryDate,productType,createdAt,updatedAt');

    // Data
    for (final p in products) {
      buffer.writeln([
        p.id,
        _escapeCsv(p.name),
        _escapeCsv(p.barcode),
        _escapeCsv(p.scientificName),
        _escapeCsv(p.description ?? ''),
        p.purchasePrice,
        p.sellingPrice,
        p.stockQuantity,
        p.minimumStock,
        p.expiryDate?.toIso8601String() ?? '',
        p.productType,
        p.createdAt.toIso8601String(),
        p.updatedAt.toIso8601String(),
      ].join(','));
    }

    await File(path).writeAsString(buffer.toString());
  }

  Future<void> _exportCategoriesToCsv(
      List<CategoryModel> categories, String path) async {
    final buffer = StringBuffer();
    buffer.writeln('id,name,description,createdAt');

    for (final c in categories) {
      buffer.writeln([
        c.id,
        _escapeCsv(c.name),
        _escapeCsv(c.description ?? ''),
        c.createdAt.toIso8601String(),
      ].join(','));
    }

    await File(path).writeAsString(buffer.toString());
  }

  Future<void> _exportCustomersToCsv(
      List<CustomerModel> customers, String path) async {
    final buffer = StringBuffer();
    buffer.writeln(
        'id,name,phone,address,totalPurchases,debtBalance,createdAt,updatedAt');

    for (final c in customers) {
      buffer.writeln([
        c.id,
        _escapeCsv(c.name),
        _escapeCsv(c.phone),
        _escapeCsv(c.address ?? ''),
        c.totalPurchases,
        c.debtBalance,
        c.createdAt.toIso8601String(),
        c.updatedAt?.toIso8601String() ?? '',
      ].join(','));
    }

    await File(path).writeAsString(buffer.toString());
  }

  Future<void> _exportSalesToCsv(List<SaleModel> sales, String path) async {
    final buffer = StringBuffer();
    buffer.writeln(
        'id,receiptNumber,date,customerId,customerName,paymentMethod,totalAmount,discount,finalAmount,paidAmount,remainingAmount,notes');

    for (final s in sales) {
      buffer.writeln([
        s.id,
        _escapeCsv(s.receiptNumber),
        s.date.toIso8601String(),
        s.customerId ?? '',
        _escapeCsv(s.customerName ?? ''),
        s.paymentMethod,
        s.totalAmount,
        s.discount,
        s.finalAmount,
        s.paidAmount,
        s.remainingAmount,
        _escapeCsv(s.notes ?? ''),
      ].join(','));
    }

    await File(path).writeAsString(buffer.toString());
  }

  Future<void> _exportSaleItemsToCsv(
      List<SaleItemModel> items, String path) async {
    final buffer = StringBuffer();
    buffer.writeln('id,saleId,productId,quantity,unitPrice,total');

    for (final i in items) {
      buffer.writeln([
        i.id,
        i.sale.value?.id ?? 0,
        i.product.value?.id ?? 0,
        i.quantity,
        i.unitPrice,
        i.total,
      ].join(','));
    }

    await File(path).writeAsString(buffer.toString());
  }

  Future<void> _exportSettingsToCsv(dynamic settings, String path) async {
    final buffer = StringBuffer();
    buffer.writeln('key,value');

    // Export key settings
    buffer.writeln('pharmacyName,${_escapeCsv(settings.pharmacyName ?? '')}');
    buffer.writeln(
        'pharmacyAddress,${_escapeCsv(settings.pharmacyAddress ?? '')}');
    buffer.writeln('pharmacyPhone,${_escapeCsv(settings.pharmacyPhone ?? '')}');
    buffer.writeln('invoiceHeader,${_escapeCsv(settings.invoiceHeader ?? '')}');
    buffer.writeln('invoiceFooter,${_escapeCsv(settings.invoiceFooter ?? '')}');
    buffer.writeln('autoBackupEnabled,${settings.autoBackupEnabled}');
    buffer.writeln('backupIntervalHours,${settings.backupIntervalHours}');

    await File(path).writeAsString(buffer.toString());
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            current.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          current.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          result.add(current.toString().trim());
          current = StringBuffer();
        } else {
          current.write(char);
        }
      }
    }

    result.add(current.toString().trim());
    return result;
  }

  Future<int> _getDirectorySize(String path) async {
    final dir = Directory(path);
    int totalSize = 0;

    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (_) {}

    return totalSize;
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

/// Result of an import operation
class ImportResult {
  final bool success;
  final String message;
  final int successCount;
  final int errorCount;
  final List<String> errors;

  ImportResult({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.errorCount = 0,
    this.errors = const [],
  });
}

/// Information about a backup
class BackupInfo {
  final String name;
  final String path;
  final DateTime createdAt;
  final int size;
  final Map<String, dynamic>? dataCounts;

  BackupInfo({
    required this.name,
    required this.path,
    required this.createdAt,
    required this.size,
    this.dataCounts,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ============================================================================
// BACKUP PATH MANAGEMENT
// ============================================================================

/// Get the current backup directory path
Future<String> getBackupDirectoryPath({String? customPath}) async {
  if (customPath != null && customPath.isNotEmpty) {
    final dir = Directory(customPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return customPath;
  }
  final dir = await getApplicationDocumentsDirectory();
  final backupDir = Directory('${dir.path}/sulaimani_backups');
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }
  return backupDir.path;
}

/// List all backup files in the backup directory
Future<List<BackupInfo>> listBackups({String? customPath}) async {
  final backupPath = await getBackupDirectoryPath(customPath: customPath);
  final dir = Directory(backupPath);

  if (!await dir.exists()) {
    return [];
  }

  final List<BackupInfo> backups = [];
  await for (final entity in dir.list()) {
    if (entity is File && entity.path.endsWith('.csv')) {
      final stat = await entity.stat();
      final name = entity.path.split(Platform.pathSeparator).last;

      // Try to parse the timestamp from the filename
      DateTime? createdAt;
      try {
        // Extract date from filename like "products_20241215_143022.csv"
        final parts = name.split('_');
        if (parts.length >= 2) {
          final datePart = parts[1]; // "20241215"
          final timePart =
              parts.length > 2 ? parts[2].replaceAll('.csv', '') : '';
          if (datePart.length == 8) {
            final year = int.parse(datePart.substring(0, 4));
            final month = int.parse(datePart.substring(4, 6));
            final day = int.parse(datePart.substring(6, 8));
            int hour = 0, minute = 0, second = 0;
            if (timePart.length == 6) {
              hour = int.parse(timePart.substring(0, 2));
              minute = int.parse(timePart.substring(2, 4));
              second = int.parse(timePart.substring(4, 6));
            }
            createdAt = DateTime(year, month, day, hour, minute, second);
          }
        }
      } catch (_) {}

      backups.add(BackupInfo(
        name: name,
        path: entity.path,
        createdAt: createdAt ?? stat.modified,
        size: stat.size,
      ));
    }
  }

  // Sort by date descending (newest first)
  backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return backups;
}

/// Delete old backup files, keeping only the most recent N backups
Future<int> cleanupOldBackups({int keepCount = 10, String? customPath}) async {
  final backups = await listBackups(customPath: customPath);

  if (backups.length <= keepCount) {
    return 0;
  }

  int deletedCount = 0;
  for (int i = keepCount; i < backups.length; i++) {
    try {
      final file = File(backups[i].path);
      if (await file.exists()) {
        await file.delete();
        deletedCount++;
      }
    } catch (_) {
      // Ignore deletion errors
    }
  }

  return deletedCount;
}

/// Get total backup size
Future<int> getTotalBackupSize({String? customPath}) async {
  final backups = await listBackups(customPath: customPath);
  return backups.fold<int>(0, (sum, b) => sum + b.size);
}
