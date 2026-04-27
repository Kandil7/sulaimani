import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../alerts/bloc/alerts_bloc.dart';
import '../../alerts/bloc/alerts_state.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../../settings/bloc/settings_state.dart';
import 'package:intl/intl.dart' hide TextDirection;

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuToggle;
  final bool isSidebarCollapsed;
  final bool showMobileMenu;
  final VoidCallback? onMobileMenuTap;

  const TopBar({
    super.key,
    this.onMenuToggle,
    this.isSidebarCollapsed = false,
    this.showMobileMenu = false,
    this.onMobileMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) =>
          curr is SettingsLoaded || curr is SettingsSaved,
      builder: (context, settingsState) {
        String pharmacyName = 'محل السليماني';
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
              height: isMobile ? 60 : 70,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSizes.md : AppSizes.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Menu toggle (mobile) or pharmacy name
                  if (showMobileMenu && isMobile)
                    IconButton(
                      icon: Icon(Icons.menu, color: AppColors.primary),
                      onPressed: onMobileMenuTap,
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          color: AppColors.primary,
                          size: isMobile ? 18 : 22,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          pharmacyName,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  // Right side actions
                  Row(
                    children: [
                      // Current Date/Time (hide on very small screens)
                      if (!isMobile)
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Text(
                                DateFormat('hh:mm a | yyyy/MM/dd', 'en_US')
                                    .format(DateTime.now()),
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      if (!isMobile) const SizedBox(width: AppSizes.md),
                      // Notifications
                      PopupMenuButton<String>(
                        icon: Badge(
                          label: totalCount > 0
                              ? Text(
                                  totalCount > 99
                                      ? '99+'
                                      : totalCount.toString(),
                                  style: const TextStyle(fontSize: 10),
                                )
                              : const SizedBox.shrink(),
                          backgroundColor: AppColors.danger,
                          textStyle: AppTextStyles.badge,
                          isLabelVisible: totalCount > 0,
                          child: Icon(Icons.notifications_outlined,
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
                      const SizedBox(width: AppSizes.md),
                      // User Profile Placeholder
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isMobile ? 14 : 16,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            pharmacyName.isNotEmpty ? pharmacyName[0] : 'ص',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
          onPressed: () {
            // This will be handled by onSelected
          },
          child: const Text('عرض كل التنبيهات'),
        ),
      ),
    ));

    return items;
  }
}
