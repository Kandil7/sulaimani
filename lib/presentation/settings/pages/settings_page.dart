import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/datasources/local/database_service.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        repository: sl<SettingsRepository>(),
        databaseService: sl<DatabaseService>(),
      )..add(LoadSettings()),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الإعدادات بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is BackupCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is BackupRestored) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.success
                    ? 'تم استعادة النسخة الاحتياطية بنجاح. يُنصح بإعادة تشغيل التطبيق.'
                    : 'فشل استعادة النسخة الاحتياطية.',
              ),
              backgroundColor:
                  state.success ? AppColors.success : AppColors.danger,
              duration: const Duration(seconds: 5),
            ),
          );
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final isMobile = ScreenUtils.isMobile(context);
        final padding = ScreenUtils.responsive(
          context,
          mobile: AppSizes.md,
          tablet: AppSizes.md,
          desktop: AppSizes.lg,
        );

        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                SizedBox(height: isMobile ? AppSizes.md : AppSizes.lg),
                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Text('الإعدادات',
            style: isMobile ? AppTextStyles.h2 : AppTextStyles.h1),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => _showResetConfirmation(context),
          icon: const Icon(Icons.restore, size: 18),
          label: Text(isMobile ? '' : 'إعادة تعيين'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSizes.sm : AppSizes.md,
              vertical: AppSizes.sm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SettingsState state) {
    if (state is SettingsLoading || state is SettingsSaving) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    SettingsModel? settings;
    if (state is SettingsLoaded) {
      settings = state.settings;
    } else if (state is SettingsSaving) {
      settings = state.settings;
    } else if (state is SettingsSaved) {
      settings = state.settings;
    } else if (state is BackupCreated) {
      settings = state.settings;
    }

    if (settings == null) {
      if (state is BackupRestored) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh,
                  size: 64, color: AppColors.textSecondary),
              const SizedBox(height: AppSizes.md),
              const Text(
                'تم استعادة البيانات بنجاح',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'يُنصح بإعادة تشغيل التطبيق لتحديث البيانات',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }
      return const Center(
        child: Text('حدث خطأ في تحميل الإعدادات'),
      );
    }

    return SettingsForm(
      settings: settings,
      onSave: (s) => context.read<SettingsBloc>().add(UpdateSettings(s)),
      onReset: () => _showResetConfirmation(context),
      onCreateBackup: () => context.read<SettingsBloc>().add(CreateBackup()),
      onRestore: () => _showRestoreDialog(context),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
            'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SettingsBloc>().add(ResetSettings());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('استعادة من نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل مسار ملف النسخة الاحتياطية:'),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'المسار',
                border: OutlineInputBorder(),
                hintText: 'C:\\Users\\...\\backup.isar',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<SettingsBloc>().add(RestoreBackup(path));
              }
            },
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
  }
}
