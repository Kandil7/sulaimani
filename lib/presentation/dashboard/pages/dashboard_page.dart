import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/stats_row.dart';
import '../widgets/sales_chart.dart';
import '../widgets/alerts_panel.dart';
import '../widgets/recent_sales_table.dart';
import '../widgets/welcome_header.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/top_products_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _autoRefreshTimer;
  final String _userName = 'أحمد';

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          context.read<DashboardBloc>().add(RefreshDashboard());
        }
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const DashboardLoadingSkeleton();
        }

        if (state is DashboardError) {
          return _buildErrorState(state.message);
        }

        if (state is DashboardLoaded) {
          return _buildLoadedState(state);
        }

        return const DashboardLoadingSkeleton();
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSizes.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
            child: Text(
              message,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(LoadDashboard());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeHeader(
              userName: _userName,
              onRefreshTap: () {
                context.read<DashboardBloc>().add(RefreshDashboard());
              },
            ),
            const SizedBox(height: AppSizes.xl),
            QuickActionsRow(
              onQuickSaleTap: () => _navigateTo('/pos'),
              onAddProductTap: () => _showAddProductDialog(),
              onRecordPaymentTap: () => _navigateTo('/customers'),
            ),
            const SizedBox(height: AppSizes.xl),
            StatsRow(
              data: state,
              onAlertsTap: () => _navigateTo('/alerts'),
            ),
            const SizedBox(height: AppSizes.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SalesChart(data: state.last7DaysSales),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  flex: 2,
                  child: AlertsPanel(
                    alerts: state.urgentAlerts,
                    onViewAllTap: () => _navigateTo('/alerts'),
                    onAlertTap: (productId) =>
                        _navigateTo('/products/$productId'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: RecentSalesTable(
                    sales: state.recentSales,
                    onViewAllTap: () => _navigateTo('/reports'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: TopProductsChart(
                    products: const [
                      ProductSalesData(name: 'بنادول', salesCount: 120),
                      ProductSalesData(name: 'فيفان', salesCount: 95),
                      ProductSalesData(name: 'اسيبرو', salesCount: 80),
                      ProductSalesData(name: 'اوميغا', salesCount: 65),
                      ProductSalesData(name: 'فيتا', salesCount: 50),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    // Use GoRouter for navigation
    switch (route) {
      case '/pos':
        context.go('/pos');
        break;
      case '/products':
      case '/products/new':
        context.go('/products');
        break;
      case '/customers':
        context.go('/customers');
        break;
      case '/alerts':
        context.go('/alerts');
        break;
      case '/reports':
        context.go('/reports');
        break;
      case '/settings':
        context.go('/settings');
        break;
      default:
        context.go(route);
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: const Text('سيتم فتح نموذج إضافة منتج جديد'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateTo('/products/new');
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
