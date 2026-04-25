import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/reports_state.dart';

class TopProductsChart extends StatelessWidget {
  final List<ProductSalesData> topProducts;

  const TopProductsChart({super.key, required this.topProducts});

  @override
  Widget build(BuildContext context) {
    if (topProducts.isEmpty) {
      return _EmptyChart(message: 'لا توجد منتجات');
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أكثر 5 منتجات مبيعاً', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxQuantity().toDouble() * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.textPrimary,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final product = topProducts[group.x];
                      return BarTooltipItem(
                        '${product.productName}\n',
                        AppTextStyles.caption.copyWith(color: Colors.white),
                        children: [
                          TextSpan(
                            text: '${product.quantitySold} قطعة - ',
                            style: AppTextStyles.bodyL
                                .copyWith(color: Colors.white),
                          ),
                          TextSpan(
                            text: '${product.revenue.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyM
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption,
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          // Legend
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.xs,
            children: topProducts.map((product) {
              return _ProductLegendItem(
                rank: topProducts.indexOf(product) + 1,
                name: product.productName,
                quantity: product.quantitySold,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _getMaxQuantity() {
    if (topProducts.isEmpty) return 10;
    return topProducts
        .map((p) => p.quantitySold)
        .reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _generateBarGroups() {
    return topProducts.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.quantitySold.toDouble(),
            color: _getBarColor(entry.key),
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      const Color(0xFF7B1FA2),
      const Color(0xFF00897B),
    ];
    return colors[index % colors.length];
  }
}

class _ProductLegendItem extends StatelessWidget {
  final int rank;
  final String name;
  final int quantity;

  const _ProductLegendItem({
    required this.rank,
    required this.name,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$rank',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            '$name ($quantity)',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أكثر 5 منتجات مبيعاً', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.xl),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: AppSizes.md),
                  Text(message, style: AppTextStyles.bodyM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
