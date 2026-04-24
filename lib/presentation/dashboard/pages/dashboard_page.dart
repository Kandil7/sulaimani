import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لوحة القيادة',
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: AppSizes.xl),
          // Summary Cards
          Row(
            children: [
              _SummaryCard(title: 'مبيعات اليوم', value: '15,430 ج', icon: Icons.monetization_on, color: AppColors.primary),
              const SizedBox(width: AppSizes.md),
              _SummaryCard(title: 'عدد الفواتير', value: '142', icon: Icons.receipt, color: Colors.purple),
              const SizedBox(width: AppSizes.md),
              _SummaryCard(title: 'متوسط الفاتورة', value: '108.6 ج', icon: Icons.analytics, color: Colors.teal),
              const SizedBox(width: AppSizes.md),
              _SummaryCard(title: 'نواقص الأدوية', value: '5', icon: Icons.warning, color: Colors.orange),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _ChartCard(
                  title: 'مبيعات آخر 7 أيام',
                  child: SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 20000,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 12)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5000,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 15000),
                          _buildBarGroup(1, 12000),
                          _buildBarGroup(2, 18000),
                          _buildBarGroup(3, 14000),
                          _buildBarGroup(4, 16000),
                          _buildBarGroup(5, 19000),
                          _buildBarGroup(6, 17500),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                flex: 1,
                child: _ChartCard(
                  title: 'أكثر المنتجات مبيعاً',
                  child: Column(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: Row(
                          children: [
                            Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Expanded(child: Text('بنادول اكسترا')),
                            Text('${100 - (index * 10)} عبوة', style: const TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Recent Invoices Table
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('أحدث الفواتير', style: AppTextStyles.h2),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('تصدير Excel'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: AppColors.background),
                      children: [
                        _buildTableHeader('رقم الفاتورة'),
                        _buildTableHeader('القيمة'),
                        _buildTableHeader('طريقة الدفع'),
                        _buildTableHeader('الوقت'),
                      ],
                    ),
                    _buildTableRow('1042', '125 ج', 'نقدي', 'منذ 5 دقائق'),
                    _buildTableRow('1041', '85 ج', 'فيزا', 'منذ 15 دقيقة'),
                    _buildTableRow('1040', '450 ج', 'نقدي', 'منذ 45 دقيقة'),
                    _buildTableRow('1039', '30 ج', 'نقدي', 'منذ ساعة'),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  TableRow _buildTableRow(String id, String amount, String method, String time) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(AppSizes.md), child: Text('#$id')),
        Padding(padding: const EdgeInsets.all(AppSizes.md), child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(AppSizes.md), child: Text(method)),
        Padding(padding: const EdgeInsets.all(AppSizes.md), child: Text(time, style: const TextStyle(color: AppColors.textLight))),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: AppSizes.xl),
          child,
        ],
      ),
    );
  }
}
