import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class WelcomeHeader extends StatefulWidget {
  final String userName;
  final VoidCallback? onRefreshTap;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.onRefreshTap,
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، ${widget.userName} 👋',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              _formatDateTime(_currentTime),
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'إليك ملخص اليوم',
              style: AppTextStyles.bodyM,
            ),
          ],
        ),
        IconButton(
          onPressed: widget.onRefreshTap,
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final days = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ];
    final months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    final dayName = days[dateTime.weekday % 7];
    final monthName = months[dateTime.month];

    return '$dayName ${dateTime.day} $monthName ${dateTime.year} - ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
