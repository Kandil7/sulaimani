import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart' show ProductType;

class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;
  final ValueChanged<ProductModel>? onSave;

  const AddEditProductDialog({
    super.key,
    this.product,
    this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ProductModel? product,
    ValueChanged<ProductModel>? onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditProductDialog(
        product: product,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _minimumStockController;
  late TextEditingController _notesController;

  ProductType _productType = ProductType.medicine;
  DateTime? _expiryDate;

  _AddEditProductDialogState();

  @override
  void initState() {
    super.initState();
    _barcodeController =
        TextEditingController(text: widget.product?.barcode ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _scientificNameController =
        TextEditingController(text: widget.product?.scientificName ?? '');
    _purchasePriceController = TextEditingController(
        text: widget.product?.purchasePrice.toString() ?? '');
    _sellingPriceController = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
    _stockQuantityController = TextEditingController(
        text: widget.product?.stockQuantity.toString() ?? '');
    _minimumStockController = TextEditingController(
        text: widget.product?.minimumStock.toString() ?? '');
    _notesController =
        TextEditingController(text: widget.product?.description ?? '');
    _expiryDate = widget.product?.expiryDate;
    // Load product type from model
    if (widget.product != null) {
      _productType = widget.product!.productType == 'pesticide'
          ? ProductType.pesticide
          : ProductType.medicine;
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _scientificNameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockQuantityController.dispose();
    _minimumStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _profit {
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    return selling - purchase;
  }

  double get _profitPercentage {
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
    if (purchase <= 0) return 0;
    return (_profit / purchase) * 100;
  }

  Future<void> _selectDate() async {
    final locale = const Locale('ar');
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: locale,
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final product = widget.product ?? ProductModel();
    product.barcode = _barcodeController.text;
    product.name = _nameController.text;
    product.scientificName = _scientificNameController.text;
    product.purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0;
    product.sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;
    product.stockQuantity = int.tryParse(_stockQuantityController.text) ?? 0;
    product.minimumStock = int.tryParse(_minimumStockController.text) ?? 0;
    product.expiryDate = _expiryDate;
    product.description =
        _notesController.text.isNotEmpty ? _notesController.text : null;
    product.productType =
        _productType == ProductType.medicine ? 'medicine' : 'pesticide';

    widget.onSave?.call(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Gradient Bar
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppSizes.radiusLg),
                  topLeft: Radius.circular(AppSizes.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_box,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    isEditing ? 'تعديل منتج' : 'إضافة منتج جديد',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Type Toggle
                      Text(
                        'نوع المنتج',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      SegmentedButton<ProductType>(
                        segments: const [
                          ButtonSegment<ProductType>(
                            value: ProductType.medicine,
                            label: Text('أدوية'),
                            icon: Icon(Icons.medication),
                          ),
                          ButtonSegment<ProductType>(
                            value: ProductType.pesticide,
                            label: Text('مبيدات'),
                            icon: Icon(Icons.science),
                          ),
                        ],
                        selected: {_productType},
                        onSelectionChanged: (values) {
                          setState(() => _productType = values.first);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.primary;
                              }
                              return AppColors.surface;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Form Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: barcode, name
                          Expanded(
                            child: _buildTextField(
                              controller: _barcodeController,
                              label: 'الكود',
                              hint: 'أدخل الباركود',
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الكود مطلوب';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'اسم المنتج',
                              hint: 'أدخل الاسم',
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الاسم مطلوب';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 2: scientificName, category
                          Expanded(
                            child: _buildTextField(
                              controller: _scientificNameController,
                              label: 'المادة الفعالة',
                              hint: 'أدخل المادة الفعالة',
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: _buildProductTypeDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 3: purchasePrice, sellingPrice
                          Expanded(
                            child: _buildTextField(
                              controller: _purchasePriceController,
                              label: 'سعر الشراء',
                              hint: 'أدخل السعر',
                              isNumber: true,
                              isRequired: true,
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'السعر مطلوب';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'قيمة رقمية';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: _buildTextField(
                              controller: _sellingPriceController,
                              label: 'سعر البيع',
                              hint: 'أدخل السعر',
                              isNumber: true,
                              isRequired: true,
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'السعر مطلوب';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'قيمة رقمية';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Profit Margin Display
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: _profit >= 0
                              ? AppColors.successSurface
                              : AppColors.dangerSurface,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _profit >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: _profit >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              'الهامش: ${_profit.toStringAsFixed(2)} ج (${_profitPercentage.toStringAsFixed(1)}%)',
                              style: AppTextStyles.bodyL.copyWith(
                                color: _profit >= 0
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 4: stockQuantity, minimumStock
                          Expanded(
                            child: _buildTextField(
                              controller: _stockQuantityController,
                              label: 'الكمية',
                              hint: 'أدخل الكمية',
                              isNumber: true,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الكمية مطلوبة';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'قيمة رقمية';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: _buildTextField(
                              controller: _minimumStockController,
                              label: 'الحد الأدنى',
                              hint: 'أدخل الحد الأدنى',
                              isNumber: true,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الحد الأدنى مطلوب';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'قيمة رقمية';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Row 5: Expiry Date
                      _buildDatePicker(),
                      const SizedBox(height: AppSizes.md),

                      // Notes
                      _buildTextField(
                        controller: _notesController,
                        label: 'ملاحظات',
                        hint: 'أدخل الملاحظات',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(AppSizes.radiusLg),
                  bottomLeft: Radius.circular(AppSizes.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isNumber = false,
    bool isRequired = false,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTextStyles.bodyL,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        hintStyle: AppTextStyles.bodyM.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildProductTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'الفئة',
        hintText: 'اختر الفئة',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
      ),
      value: _productType == ProductType.medicine ? 'medicine' : 'pesticide',
      items: const [
        DropdownMenuItem(value: 'medicine', child: Text('أدوية')),
        DropdownMenuItem(value: 'pesticide', child: Text('مبيدات')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _productType = value == 'medicine'
                ? ProductType.medicine
                : ProductType.pesticide;
          });
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تاريخ الصلاحية',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _expiryDate != null
                  ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                  : 'اختر التاريخ',
              style: AppTextStyles.bodyL.copyWith(
                color: _expiryDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
