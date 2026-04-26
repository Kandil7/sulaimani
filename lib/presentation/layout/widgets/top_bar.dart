import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../alerts/bloc/alerts_bloc.dart';
import '../../alerts/bloc/alerts_state.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import 'package:intl/intl.dart' hide TextDirection;

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) =>
          curr is SettingsLoaded || curr is SettingsSaved,
      builder: (context, settingsState) {
        String pharmacyName = 'صيدلية السليماني';
        if (settingsState is SettingsLoaded) {
          pharmacyName = settingsState.settings.pharmacyName;
        } else if (settingsState is SettingsSaved) {
          pharmacyName = settingsState.settings.pharmacyName;
        }
        return BlocBuilder<AlertsBloc, AlertsState>(
          builder: (context, alertsState) {
            final totalCount =
                alertsState is AlertsLoaded ? alertsState.totalCount : 0;
            final alerts = alertsState is AlertsLoaded
                ? _buildAlertItems(alertsState)
                : <PopupMenuEntry<String>>[];

            return Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Pharmacy name
                  Text(
                    pharmacyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  // Right side actions
                  Row(
                    children: [
                      // Current Date/Time
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          return Text(
                            DateFormat('hh:mm a | yyyy/MM/dd', 'en_US')
                                .format(DateTime.now()),
                            textDirection: TextDirection.ltr,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          );
                        },
                      ),
                      const SizedBox(width: AppSizes.lg),
                      // Notifications
                      PopupMenuButton<String>(
                        icon: Badge(
                          label: totalCount > 0
                              ? Text(totalCount > 99
                                  ? '99+'
                                  : totalCount.toString())
                              : const SizedBox.shrink(),
                          isLabelVisible: totalCount > 0,
                          child: const Icon(Icons.notifications_outlined,
                              color: AppColors.textSecondary),
                        ),
                        offset: const Offset(0, 50),
                        itemBuilder: (context) => alerts,
                        onSelected: (value) {
                          if (value.startsWith('alert_')) {
                            context.go('/alerts');
                          } else if (value == 'view_all') {
                            context.go('/alerts');
                          }
                        },
                      ),
                      const SizedBox(width: AppSizes.lg),
                      // User Profile Placeholder
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          pharmacyName.isNotEmpty ? pharmacyName[0] : 'A',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildAlertItems(AlertsLoaded state) {
    final items = <PopupMenuEntry<String>>[];

    // Header
    items.add(const PopupMenuItem(
      enabled: false,
      child: Text('التنبيهات',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    ));
    items.add(const PopupMenuDivider());

    // Expired products
    if (state.expiredProducts.isNotEmpty) {
      for (final alert in state.expiredProducts.take(3)) {
        items.add(PopupMenuItem(
          value: 'view_all',
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.warning, color: Colors.red, size: 20),
            title: Text(alert.productName, overflow: TextOverflow.ellipsis),
            subtitle: const Text('منتهي الصلاحية',
                style: TextStyle(color: Colors.red, fontSize: 11)),
          ),
        ));
      }
      if (state.expiredProducts.length > 3) {
        items.add(PopupMenuItem(
          enabled: false,
          child: Text('+ ${state.expiredProducts.length - 3} منتهي',
              style: const TextStyle(fontSize: 11, color: Colors.red)),
        ));
      }
    }

    // Expiring soon
    if (state.expiringSoonProducts.isNotEmpty) {
      for (final alert in state.expiringSoonProducts.take(3)) {
        items.add(PopupMenuItem(
          value: 'view_all',
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.info, color: Colors.orange, size: 20),
            title: Text(alert.productName, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                'ينتهي ${alert.expiryDate != null ? DateFormat('dd/MM').format(alert.expiryDate!) : ''}',
                style: const TextStyle(color: Colors.orange, fontSize: 11)),
          ),
        ));
      }
    }

    // Low stock
    if (state.lowStockProducts.isNotEmpty) {
      for (final alert in state.lowStockProducts.take(3)) {
        items.add(PopupMenuItem(
          value: 'view_all',
          child: ListTile(
            dense: true,
            leading:
                const Icon(Icons.inventory, color: AppColors.warning, size: 20),
            title: Text(alert.productName, overflow: TextOverflow.ellipsis),
            subtitle: Text('مخزون: ${alert.quantity}',
                style: const TextStyle(fontSize: 11)),
          ),
        ));
      }
      if (state.lowStockProducts.length > 3) {
        items.add(PopupMenuItem(
          enabled: false,
          child: Text('+ ${state.lowStockProducts.length - 3} منخفض',
              style: const TextStyle(fontSize: 11, color: AppColors.warning)),
        ));
      }
    }

    if (items.length == 2) {
      items.add(const PopupMenuItem(
        child: Center(
            child: Text('لا توجد تنبيهات',
                style: TextStyle(color: AppColors.textSecondary))),
      ));
    }

    items.add(const PopupMenuDivider());
    items.add(PopupMenuItem(
      value: 'view_all',
      child: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('عرض كل التنبيهات'),
        ),
      ),
    ));

    return items;
  }
}
