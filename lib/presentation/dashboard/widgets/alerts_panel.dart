import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/dashboard_state.dart';

class AlertsPanel extends StatelessWidget {
  final List<AlertItem> alerts;
  final VoidCallback? onViewAllTap;
  final Function(int productId)? onAlertTap;

  const AlertsPanel({
    super.key,
    required this.alerts,
    this.onViewAllTap,
    this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚨 تنبيهات عاجلة', style: AppTextStyles.h2),
              if (alerts.isNotEmpty) ...[
                const SizedBox(width: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSurface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (alerts.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.lg),
                  Icon(
                    Icons.check_circle,
                    size: 40,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    '✅ لا توجد تنبيهات عاجلة',
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final isCritical = alert.type == 'منتهي';
                return _AlertListItem(
                  alert: alert,
                  isCritical: isCritical,
                  onTap: onAlertTap != null
                      ? () => onAlertTap!(alert.productId)
                      : null,
                );
              },
            ),
          if (alerts.isNotEmpty && onViewAllTap != null) ...[
            const SizedBox(height: AppSizes.md),
            Center(
              child: TextButton(
                onPressed: onViewAllTap,
                child: Text(
                  'عرض كل ا��تنبيهات (${alerts.length})',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertListItem extends StatelessWidget {
  final AlertItem alert;
  final bool isCritical;
  final VoidCallback? onTap;

  const _AlertListItem({
    required this.alert,
    required this.isCritical,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isCritical ? AppColors.danger : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.productName,
                    style: AppTextStyles.bodyL.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alert.type} - ${alert.message}',
                    style: AppTextStyles.caption.copyWith(
                      color: isCritical ? AppColors.danger : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
