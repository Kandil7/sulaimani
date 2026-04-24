import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('التقارير', style: AppTextStyles.h1),
          const SizedBox(height: AppSizes.xl),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: AppSizes.md),
                  Text('سيتم إضافة نظام التقارير المتقدم هنا قريباً', style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
