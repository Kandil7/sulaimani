import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/product_model.dart';
import '../../presentation/alerts/bloc/alerts_state.dart' show ProductAlert;

class NotificationService {
  static NotificationService? _instance;
  static final NotificationService _internalInstance =
      NotificationService._internal();

  factory NotificationService() {
    _instance ??= _internalInstance;
    return _instance!;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final InitializationSettings initSettings;

      if (Platform.isLinux) {
        const LinuxInitializationSettings linuxSettings =
            LinuxInitializationSettings(defaultActionName: 'Open');
        initSettings = const InitializationSettings(linux: linuxSettings);
      } else if (Platform.isMacOS) {
        const DarwinInitializationSettings darwinSettings =
            DarwinInitializationSettings(requestAlertPermission: true);
        initSettings = const InitializationSettings(macOS: darwinSettings);
      } else if (Platform.isWindows) {
        _initialized = true;
        debugPrint('NotificationService: Windows - using toast fallback');
        return;
      } else {
        initSettings = const InitializationSettings(
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          macOS: DarwinInitializationSettings(requestAlertPermission: true),
        );
      }

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      _initialized = true;
      debugPrint('NotificationService: Initialized');
    } catch (e) {
      debugPrint('NotificationService: Initialize failed: $e');
      _initialized = true;
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
        'NotificationService: Notification tapped — ${response.payload}');
  }

  /// Show expiry notification for all alert types
  Future<void> showExpiryNotification(List<ProductAlert> products) async {
    if (products.isEmpty) return;

    // Use Windows toast on Windows
    if (Platform.isWindows) {
      await showWindowsToast(
        title: '🔔 Sulaimani Alerts',
        body: _buildAlertBody(products),
      );
      return;
    }

    await initialize();

    // Group by type
    final expired = products.where((p) => p.type == 'Expired').toList();
    final expiring = products.where((p) => p.type == 'Expiring Soon').toList();
    final lowStock = products.where((p) => p.type == 'Low Stock').toList();

    String title;
    String body;

    if (expired.isNotEmpty && expired.length == products.length) {
      title = '⚠️ Expired Products';
      body = expired.length == 1
          ? '${expired.first.productName} has expired'
          : '${expired.length} products have expired';
    } else if (lowStock.isNotEmpty && lowStock.length == products.length) {
      title = '⚠️ Low Stock';
      body = lowStock.length == 1
          ? '${lowStock.first.productName} is low on stock'
          : '${lowStock.length} products are low on stock';
    } else {
      title = '🔔 Sulaimani Pharmacy Alerts';
      final parts = <String>[];
      if (expired.isNotEmpty) parts.add('$expired expired');
      if (expiring.isNotEmpty) parts.add('$expiring expiring');
      if (lowStock.isNotEmpty) parts.add('$lowStock low stock');
      body = parts.join(' - ');
    }

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
      category: LinuxNotificationCategory.device,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      linux: linuxDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(1, title, body, details, payload: 'expiry_alert');
  }

  String _buildAlertBody(List<ProductAlert> products) {
    final expired = products.where((p) => p.type == 'Expired').length;
    final expiring = products.where((p) => p.type == 'Expiring Soon').length;
    final lowStock = products.where((p) => p.type == 'Low Stock').length;

    final parts = <String>[];
    if (expired > 0) parts.add('$expired expired');
    if (expiring > 0) parts.add('$expiring expiring');
    if (lowStock > 0) parts.add('$lowStock low stock');
    return parts.join(' - ');
  }

  /// Show low stock notification
  Future<void> showLowStockNotification(int count) async {
    if (count <= 0) return;

    if (Platform.isWindows) {
      await showWindowsToast(
        title: '📦 Low Stock Alert',
        body: '$count products have reached minimum stock level',
      );
      return;
    }

    await initialize();

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
      category: LinuxNotificationCategory.device,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      linux: linuxDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(
      2,
      '📦 Low Stock Warning',
      '$count products have reached minimum stock level',
      details,
      payload: 'low_stock_alert',
    );
  }

  /// Show single custom notification
  Future<void> showSingleNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (Platform.isWindows) {
      await showWindowsToast(title: title, body: body);
      return;
    }

    await initialize();

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    final NotificationDetails details = NotificationDetails(
      linux: linuxDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// Show Windows toast notification using PowerShell
  Future<void> showWindowsToast({
    required String title,
    required String body,
  }) async {
    if (!Platform.isWindows) return;

    try {
      // Escape special characters
      final escapedTitle = title.replaceAll('"', "'").replaceAll("'", "''");
      final escapedBody = body.replaceAll('"', "'").replaceAll("'", "''");

      final script = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms
\$notify = New-Object System.Windows.Forms.NotifyIcon
\$notify.Icon = [System.Drawing.SystemIcons]::Info
\$notify.Visible = \$true
\$notify.ShowBalloonTip(5000, "$escapedTitle", "$escapedBody", "Info")
Start-Sleep -Seconds 3
\$notify.Dispose()
''';

      await Process.run(
        'powershell',
        ['-ExecutionPolicy', 'Bypass', '-NoProfile', '-Command', script],
        runInShell: true,
      );
    } catch (e) {
      debugPrint('NotificationService: Windows toast failed: $e');
    }
  }

  /// Check products and show appropriate alerts
  Future<void> checkAndShowAlerts(List<ProductModel> products) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expired = <ProductAlert>[];
    final expiringSoon = <ProductAlert>[];
    final lowStock = <ProductAlert>[];

    for (final p in products) {
      if (p.expiryDate != null) {
        final expiryDay = DateTime(
            p.expiryDate!.year, p.expiryDate!.month, p.expiryDate!.day);

        if (today.isAfter(expiryDay)) {
          expired.add(ProductAlert(
            productId: p.id,
            productName: p.name,
            type: 'Expired',
            expiryDate: p.expiryDate,
            quantity: p.stockQuantity,
            minimumStock: p.minimumStock,
          ));
        } else if (expiryDay.difference(today).inDays <= 30) {
          expiringSoon.add(ProductAlert(
            productId: p.id,
            productName: p.name,
            type: 'Expiring Soon',
            expiryDate: p.expiryDate,
            quantity: p.stockQuantity,
            minimumStock: p.minimumStock,
          ));
        }
      }

      if (p.stockQuantity <= p.minimumStock) {
        lowStock.add(ProductAlert(
          productId: p.id,
          productName: p.name,
          type: 'Low Stock',
          quantity: p.stockQuantity,
          minimumStock: p.minimumStock,
        ));
      }
    }

    final allAlerts = [...expired, ...expiringSoon, ...lowStock];
    if (allAlerts.isNotEmpty) {
      if (Platform.isWindows) {
        await showWindowsToast(
          title: '🔔 Sulaimani Pharmacy',
          body:
              '${expired.length} expired - ${expiringSoon.length} expiring - ${lowStock.length} low stock',
        );
      }
      await showExpiryNotification(allAlerts);
      if (lowStock.isNotEmpty) {
        await showLowStockNotification(lowStock.length);
      }
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
