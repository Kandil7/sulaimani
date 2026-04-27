import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/datasources/local/customer_local_datasource.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';

class EditCustomerDialog extends StatefulWidget {
  final CustomerModel customer;

  const EditCustomerDialog({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _phoneError;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newPhone = _phoneController.text.trim();

    // Check for duplicate phone (excluding current customer)
    if (newPhone != widget.customer.phone) {
      final customerDatasource = sl<CustomerLocalDatasource>();
      final exists = await customerDatasource.phoneExists(
        newPhone,
        excludeCustomerId: widget.customer.id,
      );
      if (exists) {
        setState(() {
          _phoneError = 'رقم التليفون مسجل بالفعل لعميل آخر';
        });
        return;
      }
    }

    // Update the customer model in place
    widget.customer.name = _nameController.text.trim();
    widget.customer.phone = newPhone;
    widget.customer.updatedAt = DateTime.now();

    if (mounted) {
      context.read<CustomersBloc>().add(UpdateCustomer(widget.customer));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تعديل بيانات العميل',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'الاسم',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (value.trim().length < 2) {
                          return 'الاسم يجب أن يكون على الأقل حرفين';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'التليفون',
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      errorText: _phoneError,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (!_isValidPhone(value.trim())) {
                          return 'رقم التليفون غير صالح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xl,
                        vertical: AppSizes.md,
                      ),
                    ),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: validator,
    );
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^01[0-9]{9}$');
    final phoneWithPrefix = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return phoneRegex.hasMatch(phoneWithPrefix) || phone.length >= 10;
  }
}
