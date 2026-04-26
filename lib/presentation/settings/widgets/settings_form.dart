import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/settings_model.dart';
import 'invoice_preview_card.dart';

class SettingsForm extends StatefulWidget {
  final SettingsModel settings;
  final Function(SettingsModel) onSave;
  final VoidCallback onReset;
  final VoidCallback onCreateBackup;
  final VoidCallback onRestore;

  const SettingsForm({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onReset,
    required this.onCreateBackup,
    required this.onRestore,
  });

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pharmacyNameController;
  late TextEditingController _pharmacyAddressController;
  late TextEditingController _pharmacyPhoneController;
  late TextEditingController _invoiceHeaderController;
  late TextEditingController _invoiceFooterController;
  late TextEditingController _expiryDaysController;
  late TextEditingController _lowStockController;

  bool _enableNotificationSounds = true;
  bool _enableWindowsNotifications = true;
  bool _autoBackupEnabled = false;
  int _backupIntervalHours = 24;
  String? _selectedLogoPath;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final s = widget.settings;
    _pharmacyNameController = TextEditingController(text: s.pharmacyName);
    _pharmacyAddressController =
        TextEditingController(text: s.pharmacyAddress ?? '');
    _pharmacyPhoneController =
        TextEditingController(text: s.pharmacyPhone ?? '');
    _invoiceHeaderController =
        TextEditingController(text: s.invoiceHeader ?? '');
    _invoiceFooterController =
        TextEditingController(text: s.invoiceFooter ?? '');
    _expiryDaysController =
        TextEditingController(text: s.expiryWarningDays.toString());
    _lowStockController =
        TextEditingController(text: s.lowStockWarning.toString());
    _enableNotificationSounds = s.enableNotificationSounds;
    _enableWindowsNotifications = s.enableWindowsNotifications;
    _autoBackupEnabled = s.autoBackupEnabled;
    _backupIntervalHours = s.backupIntervalHours;
    _selectedLogoPath = s.invoiceLogoPath;
  }

  @override
  void didUpdateWidget(SettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.id != widget.settings.id) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _pharmacyAddressController.dispose();
    _pharmacyPhoneController.dispose();
    _invoiceHeaderController.dispose();
    _invoiceFooterController.dispose();
    _expiryDaysController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final s = widget.settings;
      s.pharmacyName = _pharmacyNameController.text.trim();
      s.pharmacyAddress = _pharmacyAddressController.text.trim().isEmpty
          ? null
          : _pharmacyAddressController.text.trim();
      s.pharmacyPhone = _pharmacyPhoneController.text.trim().isEmpty
          ? null
          : _pharmacyPhoneController.text.trim();
      s.invoiceHeader = _invoiceHeaderController.text.trim().isEmpty
          ? null
          : _invoiceHeaderController.text.trim();
      s.invoiceFooter = _invoiceFooterController.text.trim().isEmpty
          ? null
          : _invoiceFooterController.text.trim();
      s.expiryWarningDays = int.tryParse(_expiryDaysController.text) ?? 30;
      s.lowStockWarning = int.tryParse(_lowStockController.text) ?? 10;
      s.enableNotificationSounds = _enableNotificationSounds;
      s.enableWindowsNotifications = _enableWindowsNotifications;
      s.autoBackupEnabled = _autoBackupEnabled;
      s.backupIntervalHours = _backupIntervalHours;
      s.invoiceLogoPath = _selectedLogoPath;

      widget.onSave(s);
    }
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size (max 2MB)
        if (file.size > 2 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حجم الملف كبير جداً. الحد الأقصى 2 ميجابايت.'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        // Validate extension
        final ext = file.extension?.toLowerCase();
        if (ext == null ||
            !['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(ext)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('يرجى اختيار ملف صورة (PNG, JPG, GIF, BMP, WEBP)'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        // Store the path for saving
        setState(() {
          _selectedLogoPath = file.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار: ${file.name}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الصورة: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          _buildPharmacyInfoSection(),
          const SizedBox(height: AppSizes.xl),
          _buildInvoiceSettingsSection(),
          const SizedBox(height: AppSizes.xl),
          _buildAlertSettingsSection(),
          const SizedBox(height: AppSizes.xl),
          _buildBackupSection(),
          const SizedBox(height: AppSizes.xl),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfoSection() {
    return _buildSectionCard(
      title: 'معلومات الصيدلية',
      icon: Icons.local_pharmacy,
      children: [
        TextFormField(
          controller: _pharmacyNameController,
          decoration: const InputDecoration(
            labelText: 'اسم الصيدلية',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? 'الحقل مطلوب' : null,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _pharmacyAddressController,
          decoration: const InputDecoration(
            labelText: 'العنوان',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _pharmacyPhoneController,
          decoration: const InputDecoration(
            labelText: 'التليفون',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSizes.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('حفظ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSettingsSection() {
    return _buildSectionCard(
      title: 'إعدادات الفاتورة',
      icon: Icons.receipt,
      children: [
        TextFormField(
          controller: _invoiceHeaderController,
          decoration: const InputDecoration(
            labelText: 'رأس الفاتورة',
            border: OutlineInputBorder(),
            hintText: 'النص الذي يظهر في أعلى الفاتورة',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _invoiceFooterController,
          decoration: const InputDecoration(
            labelText: 'ذيل الفاتورة',
            border: OutlineInputBorder(),
            hintText: 'النص الذي يظهر في أسفل الفاتورة',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.image),
                label: const Text('اختيار شعار'),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showInvoicePreview(context),
                icon: const Icon(Icons.preview),
                label: const Text('معاينة'),
              ),
            ),
          ],
        ),
        if (_selectedLogoPath != null) ...[
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'الشعار: ${_selectedLogoPath!.split(Platform.pathSeparator).last}',
                        style: AppTextStyles.bodyM,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedLogoPath = null;
                      }),
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                      tooltip: 'إزالة الشعار',
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                // Logo preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: Image.file(
                    File(_selectedLogoPath!),
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey.shade200,
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertSettingsSection() {
    return _buildSectionCard(
      title: 'إعدادات التنبيهات',
      icon: Icons.notifications,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDaysController,
                decoration: const InputDecoration(
                  labelText: 'أيام تحذير انتهاء الصلاحية',
                  border: OutlineInputBorder(),
                  suffixText: 'يوم',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'قيمة صحيحة';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: TextFormField(
                controller: _lowStockController,
                decoration: const InputDecoration(
                  labelText: 'حد المخزون المنخفض',
                  border: OutlineInputBorder(),
                  suffixText: 'وحدة',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'قيمة صحيحة';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        SwitchListTile(
          title: const Text('تفعيل أصوات التنبيهات'),
          value: _enableNotificationSounds,
          onChanged: (v) => setState(() => _enableNotificationSounds = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('تفعيل تنبيهات Windows'),
          value: _enableWindowsNotifications,
          onChanged: (v) => setState(() => _enableWindowsNotifications = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildBackupSection() {
    return _buildSectionCard(
      title: 'النسخ الاحتياطي',
      icon: Icons.backup,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onCreateBackup,
                icon: const Icon(Icons.save),
                label: const Text('نسخ احتياطي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onRestore,
                icon: const Icon(Icons.restore),
                label: const Text('استعادة'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        if (widget.settings.lastBackupDate != null)
          Text(
            'آخر نسخة احتياطية: ${_formatDate(widget.settings.lastBackupDate!)}',
            style: AppTextStyles.bodyM,
          )
        else
          Text(
            'لم يتم إجراء نسخة احتياطية بعد',
            style: AppTextStyles.bodyM,
          ),
        const SizedBox(height: AppSizes.md),
        SwitchListTile(
          title: const Text('تفعيل النسخ الاحتياطي التلقائي'),
          subtitle: const Text('إنشاء نسخة احتياطية تلقائياً كل فترة محددة'),
          value: _autoBackupEnabled,
          onChanged: (v) => setState(() => _autoBackupEnabled = v),
          contentPadding: EdgeInsets.zero,
        ),
        if (_autoBackupEnabled) ...[
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فترة النسخ الاحتياطي التلقائي',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    _buildIntervalChip(6, 'كل 6 ساعات'),
                    const SizedBox(width: AppSizes.sm),
                    _buildIntervalChip(12, 'كل 12 ساعة'),
                    const SizedBox(width: AppSizes.sm),
                    _buildIntervalChip(24, 'يومياً'),
                    const SizedBox(width: AppSizes.sm),
                    _buildIntervalChip(72, 'كل 3 أيام'),
                    const SizedBox(width: AppSizes.sm),
                    _buildIntervalChip(168, 'أسبوعياً'),
                  ],
                ),
                if (widget.settings.nextScheduledBackup != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        'النسخة القادمة: ${_formatDate(widget.settings.nextScheduledBackup!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIntervalChip(int hours, String label) {
    final isSelected = _backupIntervalHours == hours;
    return GestureDetector(
      onTap: () => setState(() => _backupIntervalHours = hours),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'حول التطبيق',
      icon: Icons.info,
      children: [
        ListTile(
          leading: const Icon(Icons.apps),
          title: const Text('صيدلية السليماني'),
          subtitle: const Text('نظام إدارة الصيدلية'),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.new_releases),
          title: const Text('الإصدار'),
          subtitle: const Text('1.0.0'),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.developer_mode),
          title: const Text('المطور'),
          subtitle: const Text('فريق السليماني'),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('الدعم'),
          subtitle: const Text('support@sulaimani.com'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(title, style: AppTextStyles.h2),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSizes.md),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showInvoicePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InvoicePreviewCard(
        header: _invoiceHeaderController.text,
        footer: _invoiceFooterController.text,
        logoPath: _selectedLogoPath ?? widget.settings.invoiceLogoPath,
        pharmacyName: _pharmacyNameController.text,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
