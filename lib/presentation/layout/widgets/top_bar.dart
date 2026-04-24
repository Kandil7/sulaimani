import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'package:intl/intl.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Search Bar (optional for later)
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'بحث سريع (F3)',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          
          // Right side actions
          Row(
            children: [
              // Sync status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done, color: AppColors.success, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'متصل',
                      style: TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              
              // Current Date/Time
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    DateFormat('hh:mm a | yyyy/MM/dd', 'en_US').format(DateTime.now()),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: AppColors.textSecondary),
                  );
                }
              ),
              const SizedBox(width: AppSizes.lg),
              
              // User Profile Placeholder
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
