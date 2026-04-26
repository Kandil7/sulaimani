import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../alerts/bloc/alerts_bloc.dart';
import '../../alerts/bloc/alerts_event.dart';
import '../../alerts/bloc/alerts_state.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AlertsBloc>()..add(LoadAlerts()),
      child: const AlertsView(),
    );
  }
}

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.alerts,
                    style: AppTextStyles.h1,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        context.read<AlertsBloc>().add(LoadAlerts()),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Alerts Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AlertsState state) {
    if (state is AlertsLoading) {
      return _buildLoadingState();
    } else if (state is AlertsLoaded) {
      if (state.totalCount == 0) {
        return EmptyState(
          icon: Icons.check_circle_outline,
          title: 'لا توجد تنبيهات',
          subtitle: 'جميع المنتجات بحالة جيدة',
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(
                  title: 'منتهية الصلاحية',
                  count: state.expiredProducts.length,
                  color: AppColors.danger,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(width: AppSizes.md),
                _buildSummaryCard(
                  title: 'تنتهي قريباً',
                  count: state.expiringSoonProducts.length,
                  color: AppColors.warning,
                  icon: Icons.warning_amber_outlined,
                ),
                const SizedBox(width: AppSizes.md),
                _buildSummaryCard(
                  title: 'مخزون منخفض',
                  count: state.lowStockProducts.length,
                  color: AppColors.warning,
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // Expired Products
            if (state.expiredProducts.isNotEmpty) ...[
              _buildAlertSection(
                title: 'المنتجات منتهية الصلاحية',
                color: AppColors.danger,
                alerts: state.expiredProducts,
                onAlertTap: (productId) => _onAlertTap(context, productId),
              ),
              const SizedBox(height: AppSizes.lg),
            ],

            // Expiring Soon Products
            if (state.expiringSoonProducts.isNotEmpty) ...[
              _buildAlertSection(
                title: 'المنتجات التي تنتهي قريباً',
                color: AppColors.warning,
                alerts: state.expiringSoonProducts,
                onAlertTap: (productId) => _onAlertTap(context, productId),
              ),
              const SizedBox(height: AppSizes.lg),
            ],

            // Low Stock Products
            if (state.lowStockProducts.isNotEmpty)
              _buildAlertSection(
                title: 'المنتجات ذات المخزون المنخفض',
                color: AppColors.warning,
                alerts: state.lowStockProducts,
                onAlertTap: (productId) => _onAlertTap(context, productId),
              ),
          ],
        ),
      );
    } else if (state is AlertsError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<AlertsBloc>().add(LoadAlerts()),
      );
    }

    return const SizedBox();
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSizes.md),
                child: LoadingSkeleton(
                  height: 100,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Expanded(
          child: LoadingSkeleton(
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: AppTextStyles.h1.copyWith(color: color),
                ),
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onAlertTap(BuildContext context, int productId) {
    // Navigate to products page - the product detail panel will show
    context.go('/products');
    // TODO: In a future iteration, pass productId to pre-select the product
  }

  Widget _buildAlertSection({
    required String title,
    required Color color,
    required List<ProductAlert> alerts,
    required Function(int productId) onAlertTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSizes.radiusMd),
                topLeft: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: color),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Dismissible(
                key: Key('${alert.productId}_${alert.type}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error.withValues(alpha: 0.1),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSizes.md),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
                onDismissed: (_) {
                  context.read<AlertsBloc>().add(DismissAlert(
                        productId: alert.productId,
                        alertType: alert.type,
                      ));
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    alert.productName,
                    style: AppTextStyles.bodyL,
                  ),
                  subtitle: Text(
                    alert.type,
                    style: AppTextStyles.caption,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        tooltip: 'تعديل المنتج',
                        onPressed: () => onAlertTap(alert.productId),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'تجاهل',
                        onPressed: () {
                          context.read<AlertsBloc>().add(DismissAlert(
                                productId: alert.productId,
                                alertType: alert.type,
                              ));
                        },
                      ),
                      if (alert.expiryDate != null) ...[
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          '${alert.expiryDate!.day}/${alert.expiryDate!.month}/${alert.expiryDate!.year}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                      const SizedBox(width: AppSizes.md),
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        '${alert.quantity}',
                        style: AppTextStyles.bodyM,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
