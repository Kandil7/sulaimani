import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/product_model.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _scientificNameController = TextEditingController(text: widget.product?.scientificName ?? '');
    _purchasePriceController = TextEditingController(text: widget.product?.purchasePrice.toString() ?? '');
    _sellingPriceController = TextEditingController(text: widget.product?.sellingPrice.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '');
    _minStockController = TextEditingController(text: widget.product?.minimumStock.toString() ?? '');
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _scientificNameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.product != null;
      final product = isEditing ? widget.product! : ProductModel();
      
      product.barcode = _barcodeController.text;
      product.name = _nameController.text;
      product.scientificName = _scientificNameController.text;
      product.purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0;
      product.sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;
      product.stockQuantity = int.tryParse(_stockController.text) ?? 0;
      product.minimumStock = int.tryParse(_minStockController.text) ?? 0;

      if (!isEditing) {
        product.createdAt = DateTime.now();
      }
      product.updatedAt = DateTime.now();

      if (isEditing) {
        context.read<ProductsBloc>().add(UpdateProduct(product));
      } else {
        context.read<ProductsBloc>().add(AddProduct(product));
      }
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product == null ? 'إضافة منتج جديد' : 'تعديل منتج',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(child: _buildTextField(_barcodeController, 'الباركود', isRequired: true)),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: _buildTextField(_nameController, 'الاسم التجاري', isRequired: true)),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              _buildTextField(_scientificNameController, 'المادة الفعالة', isRequired: true),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(child: _buildTextField(_purchasePriceController, 'سعر الشراء', isNumber: true, isRequired: true)),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: _buildTextField(_sellingPriceController, 'سعر البيع', isNumber: true, isRequired: true)),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(child: _buildTextField(_stockController, 'الكمية المتوفرة', isNumber: true, isRequired: true)),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: _buildTextField(_minStockController, 'الحد الأدنى للكمية', isNumber: true, isRequired: true)),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: AppSizes.md),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
                    ),
                    child: const Text('حفظ'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }
}
