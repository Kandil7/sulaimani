import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/product_model.dart';
import '../../presentation/alerts/bloc/alerts_state.dart' show ProductAlert;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Linux settings
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open');

    // macOS settings
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(requestAlertPermission: true);

    // Build initialization settings based on platform
    InitializationSettings initSettings;
    if (Platform.isWindows) {
      // Windows uses default constructor with app name
      initSettings = const InitializationSettings(
        linux: linuxSettings,
        macOS: darwinSettings,
      );
    } else {
      initSettings = const InitializationSettings(
        linux: linuxSettings,
        macOS: darwinSettings,
      );
    }

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
    debugPrint('NotificationService: Initialized');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
        'NotificationService: Notification tapped — ${response.payload}');
  }

  Future<void> showExpiryNotification(List<ProductAlert> products) async {
    if (products.isEmpty) return;
    await initialize();

    // Group by type
    final expired = products.where((p) => p.type == 'Expired').toList();
    final expiring = products.where((p) => p.type == 'Expiring Soon').toList();
    final lowStock = products.where((p) => p.type == 'Low Stock').toList();

    String title;
    String body;

    if (expired.isNotEmpty && expired.length == products.length) {
      title = 'منتجات منتهية الصلاحية';
      body = expired.length == 1
          ? '${expired.first.productName} منتهي الصلاحية'
          : '${expired.length} منتجات منتهية الصلاحية';
    } else if (lowStock.isNotEmpty && lowStock.length == products.length) {
      title = 'منتجات نفدت من المخزون';
      body = lowStock.length == 1
          ? '${lowStock.first.productName} المخزون منخفض'
          : '${lowStock.length} منتجات المخزون منخفض';
    } else {
      title = 'تنبيهات صيدلية السليماني';
      final parts = <String>[];
      if (expired.isNotEmpty) parts.add('${expired.length} منتهي');
      if (expiring.isNotEmpty) parts.add('${expiring.length} ينتهي قريباً');
      if (lowStock.isNotEmpty) parts.add('${lowStock.length} مخزون منخفض');
      body = parts.join(' • ');
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

    await _notifications.show(
      1,
      title,
      body,
      details,
      payload: 'expiry_alert',
    );
  }

  Future<void> showLowStockNotification(int count) async {
    if (count <= 0) return;
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
      'منتجات نفدت من المخزون',
      '$count منتج(s) وصلت للحد الأدنى من المخزون',
      details,
      payload: 'low_stock_alert',
    );
  }

  Future<void> showSingleNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await initialize();

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    final NotificationDetails details = NotificationDetails(
      linux: linuxDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// Shows Windows toast notification using PowerShell as a fallback.
  /// This works on Windows 10/11 without any additional packages.
  Future<void> showWindowsToast({
    required String title,
    required String body,
  }) async {
    if (!Platform.isWindows) return;

    try {
      // Use PowerShell to show Windows toast notification via BurntToast module
      // Fallback: use old-style toast via msg.exe or a simple dialog
      // We encode the text properly for PowerShell
      // Encode text properly for PowerShell - escape single quotes
      title = title.replaceAll("'", "''");
      body = body.replaceAll("'", "''");

      // Try using Windows.UI.Notifications or fallback msg.exe
      // Using BurntToast-style PowerShell script
      final script = '''
Add-Type -AssemblyName System.Windows.Forms
\$n = New-Object System.Windows.Forms.NotifyIcon
\$n.Icon = [System.Drawing.SystemIcons]::Information
\$n.Visible = \$true
\$n.ShowBalloonTip(3000, '\$title', '\$body', 'Info')
Start-Sleep -Seconds 4
\$n.Dispose()
''';

      final result = await Process.run(
        'powershell',
        ['-ExecutionPolicy', 'Bypass', '-Command', script],
      );
      debugPrint(
          'NotificationService: Windows toast shown, exit code: ${result.exitCode}');
    } catch (e) {
      debugPrint('NotificationService: Failed to show Windows toast: $e');
    }
  }

  Future<void> checkAndShowAlerts(List<ProductModel> products) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expired = <ProductAlert>[];
    final expiringSoon = <ProductAlert>[];
    final lowStock = <ProductAlert>[];

    for (final p in products) {
      if (p.expiryDate != null) {
        final expiryDay = DateTime(
          p.expiryDate!.year,
          p.expiryDate!.month,
          p.expiryDate!.day,
        );

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
      // Try native notification first, then fall back to Windows toast
      if (Platform.isWindows) {
        await showWindowsToast(
          title: 'تنبيهات صيدلية السليماني',
          body:
              '${expired.length} منتهي • ${expiringSoon.length} ينتهي قريباً • ${lowStock.length} مخزون منخفض',
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
