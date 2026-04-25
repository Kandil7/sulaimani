import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSizes.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(
                    width: 200,
                    height: 30,
                    borderRadius: AppSizes.radiusSm,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  LoadingSkeleton(
                    width: 150,
                    height: 16,
                    borderRadius: AppSizes.radiusSm,
                  ),
                ],
              ),
              const LoadingSkeleton(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Stats row skeleton
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? AppSizes.md : 0,
                  ),
                  child: const LoadingSkeleton(
                    height: 100,
                    borderRadius: AppSizes.radiusLg,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          // Charts row skeleton
          Row(
            children: [
              Expanded(
                flex: 2,
                child: LoadingSkeleton(
                  height: 300,
                  borderRadius: AppSizes.radiusLg,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: LoadingSkeleton(
                  height: 300,
                  borderRadius: AppSizes.radiusLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Recent sales skeleton
          LoadingSkeleton(
            height: 250,
            borderRadius: AppSizes.radiusLg,
          ),
        ],
      ),
    );
  }
}
