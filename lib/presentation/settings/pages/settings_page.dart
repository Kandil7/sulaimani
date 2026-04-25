import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/di/injection_container.dart';
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
            const SnackBar(
              content: Text('تم استعادة النسخة الاحتياطية بنجاح'),
              backgroundColor: AppColors.success,
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
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSizes.lg),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text('الإعدادات', style: AppTextStyles.h1),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => _showResetConfirmation(context),
          icon: const Icon(Icons.restore),
          label: const Text('إعادة تعيين'),
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
    } else if (state is BackupRestored) {
      settings = state.settings;
    }

    if (settings == null) {
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
