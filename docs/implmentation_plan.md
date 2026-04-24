# خطة التنفيذ الكاملة — صيدلية السليماني

**الإصدار:** v1.0 | **المدة:** 4 أسابيع | **التاريخ:** 24 أبريل 2026

***

## 📋 نظرة عامة على الخطة

```
Phase 1: Foundation      (الأسبوع 1) — Days 1-7
Phase 2: Core Features   (الأسبوع 2) — Days 8-14
Phase 3: POS & Invoices  (الأسبوع 3) — Days 15-21
Phase 4: Polish & Done   (الأسبوع 4) — Days 22-28
```

***

## 🗂️ هيكل المشروع الكامل

```
sulaimani_pharmacy/
│
├── lib/
│   ├── main.dart
│   ├── injection_container.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_sizes.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_constants.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── responsive/
│   │   │       ├── breakpoints.dart
│   │   │       └── responsive_layout.dart
│   │   │
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   │
│   │   ├── usecases/
│   │   │   └── usecase.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── currency_utils.dart
│   │   │   ├── invoice_generator.dart
│   │   │   └── validators.dart
│   │   │
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   │
│   │   └── widgets/
│   │       ├── app_shell.dart
│   │       ├── app_sidebar.dart
│   │       ├── app_top_bar.dart
│   │       ├── stat_card.dart
│   │       ├── data_table_widget.dart
│   │       ├── empty_state.dart
│   │       ├── error_state.dart
│   │       ├── loading_skeleton.dart
│   │       ├── confirm_dialog.dart
│   │       ├── app_badge.dart
│   │       └── toast_notification.dart
│   │
│   └── features/
│       │
│       ├── dashboard/
│       │   ├── domain/
│       │   │   ├── entities/dashboard_stats.dart
│       │   │   ├── repositories/dashboard_repository.dart
│       │   │   └── usecases/get_dashboard_stats.dart
│       │   ├── data/
│       │   │   ├── datasources/dashboard_local_datasource.dart
│       │   │   └── repositories/dashboard_repository_impl.dart
│       │   └── presentation/
│       │       ├── cubit/dashboard_cubit.dart
│       │       ├── cubit/dashboard_state.dart
│       │       ├── screens/dashboard_screen.dart
│       │       └── widgets/
│       │           ├── stats_row.dart
│       │           ├── sales_chart.dart
│       │           ├── alerts_panel.dart
│       │           └── recent_sales_table.dart
│       │
│       ├── products/
│       │   ├── domain/
│       │   │   ├── entities/product.dart
│       │   │   ├── repositories/product_repository.dart
│       │   │   └── usecases/
│       │   │       ├── add_product.dart
│       │   │       ├── update_product.dart
│       │   │       ├── delete_product.dart
│       │   │       ├── get_all_products.dart
│       │   │       ├── search_products.dart
│       │   │       └── get_low_stock_products.dart
│       │   ├── data/
│       │   │   ├── models/product_model.dart
│       │   │   ├── datasources/product_local_datasource.dart
│       │   │   └── repositories/product_repository_impl.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── product_cubit.dart
│       │       │   └── product_state.dart
│       │       ├── screens/
│       │       │   └── products_screen.dart
│       │       └── widgets/
│       │           ├── products_toolbar.dart
│       │           ├── products_table.dart
│       │           ├── product_detail_panel.dart
│       │           ├── add_edit_product_dialog.dart
│       │           ├── type_badge.dart
│       │           ├── expiry_cell.dart
│       │           └── quantity_cell.dart
│       │
│       ├── pos/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── cart_item.dart
│       │   │   │   └── sale.dart
│       │   │   ├── repositories/sale_repository.dart
│       │   │   └── usecases/
│       │   │       ├── create_sale.dart
│       │   │       └── get_sales_by_date.dart
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── sale_model.dart
│       │   │   │   └── sale_item_model.dart
│       │   │   ├── datasources/sale_local_datasource.dart
│       │   │   └── repositories/sale_repository_impl.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── pos_cubit.dart
│       │       │   └── pos_state.dart
│       │       ├── screens/
│       │       │   └── pos_screen.dart
│       │       └── widgets/
│       │           ├── pos_search_bar.dart
│       │           ├── product_pos_card.dart
│       │           ├── product_grid.dart
│       │           ├── cart_panel.dart
│       │           ├── cart_item_row.dart
│       │           ├── cart_summary.dart
│       │           ├── payment_dialog.dart
│       │           └── invoice_preview_dialog.dart
│       │
│       ├── customers/
│       │   ├── domain/
│       │   │   ├── entities/customer.dart
│       │   │   ├── repositories/customer_repository.dart
│       │   │   └── usecases/
│       │   │       ├── add_customer.dart
│       │   │       ├── get_all_customers.dart
│       │   │       ├── update_customer.dart
│       │   │       └── record_payment.dart
│       │   ├── data/
│       │   │   ├── models/customer_model.dart
│       │   │   ├── datasources/customer_local_datasource.dart
│       │   │   └── repositories/customer_repository_impl.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── customer_cubit.dart
│       │       │   └── customer_state.dart
│       │       ├── screens/customers_screen.dart
│       │       └── widgets/
│       │           ├── customers_table.dart
│       │           ├── customer_detail_panel.dart
│       │           ├── add_customer_dialog.dart
│       │           └── record_payment_dialog.dart
│       │
│       ├── alerts/
│       │   ├── domain/
│       │   │   ├── entities/alert_item.dart
│       │   │   ├── repositories/alerts_repository.dart
│       │   │   └── usecases/get_all_alerts.dart
│       │   ├── data/
│       │   │   ├── datasources/alerts_local_datasource.dart
│       │   │   └── repositories/alerts_repository_impl.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── alerts_cubit.dart
│       │       │   └── alerts_state.dart
│       │       ├── screens/alerts_screen.dart
│       │       └── widgets/
│       │           ├── alert_section.dart
│       │           └── alert_row.dart
│       │
│       └── reports/
│           ├── domain/
│           │   ├── entities/report_data.dart
│           │   ├── repositories/reports_repository.dart
│           │   └── usecases/get_sales_report.dart
│           ├── data/
│           │   ├── datasources/reports_local_datasource.dart
│           │   └── repositories/reports_repository_impl.dart
│           └── presentation/
│               ├── cubit/
│               │   ├── reports_cubit.dart
│               │   └── reports_state.dart
│               ├── screens/reports_screen.dart
│               └── widgets/
│                   ├── report_filter_bar.dart
│                   ├── report_summary_row.dart
│                   ├── sales_bar_chart.dart
│                   ├── top_products_chart.dart
│                   └── invoices_table.dart
│
├── assets/
│   ├── fonts/
│   │   └── Cairo/
│   │       ├── Cairo-Regular.ttf
│   │       ├── Cairo-Medium.ttf
│   │       ├── Cairo-SemiBold.ttf
│   │       └── Cairo-Bold.ttf
│   └── images/
│       └── logo.png
│
├── test/
│   ├── unit/
│   │   ├── usecases/
│   │   └── repositories/
│   └── widget/
│
└── pubspec.yaml
```

***

## 📦 pubspec.yaml الكامل

```yaml
name: sulaimani_pharmacy
description: نظام إدارة صيدلية السليماني
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.4

  # DI
  get_it: ^7.7.0

  # Functional Programming
  dartz: ^0.10.1

  # Navigation
  go_router: ^14.0.0

  # PDF & Printing
  pdf: ^3.11.0
  printing: ^5.13.0

  # Charts
  fl_chart: ^0.69.0

  # Tables
  data_table_2: ^2.5.12

  # Notifications
  flutter_local_notifications: ^17.2.0

  # Window Management (Desktop)
  window_manager: ^0.3.9

  # Date Formatting
  intl: ^0.19.0

  # Utilities
  uuid: ^4.5.1
  share_plus: ^10.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  isar_generator: ^3.1.0
  build_runner: ^2.4.13
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo/Cairo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Cairo/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo/Cairo-Bold.ttf
          weight: 700
```

***

## 📅 الأسبوع الأول — Foundation

### Day 1: Project Setup

**المهام:**
```
□ flutter create sulaimani_pharmacy --platforms=windows
□ إضافة كل الـ dependencies في pubspec.yaml
□ تحميل Cairo font من Google Fonts
□ إعداد folder structure كاملة
□ إعداد .gitignore + git init
□ إعداد analysis_options.yaml
```

**analysis_options.yaml:**
```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - use_key_in_widget_constructors
    - avoid_print
    - prefer_single_quotes
```

***

### Day 2: Core — Errors + UseCase Base

**الملفات المنفَّذة:**

```
core/errors/failures.dart
core/errors/exceptions.dart
core/usecases/usecase.dart
core/utils/date_utils.dart
core/utils/currency_utils.dart
core/utils/validators.dart
```

**التسلسل المنطقي:**
```
Exceptions (Data Layer) 
    → تُلتقط في Repository
        → تتحول لـ Failures (Domain Layer)
            → ترجع لـ Cubit كـ Either<Failure, T>
                → تظهر للمستخدم كـ ErrorState
```

***

### Day 3: Design System

**الملفات المنفَّذة:**
```
core/constants/app_colors.dart
core/constants/app_sizes.dart
core/constants/app_strings.dart
core/theme/app_text_styles.dart
core/theme/app_theme.dart
core/theme/responsive/breakpoints.dart
core/theme/responsive/responsive_layout.dart
```

**اختبار الـ Theme:**
```dart
// main.dart مؤقت للاختبار
void main() {
  runApp(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: Text('صيدلية السليماني',
          style: AppTextStyles.headline1),
      ),
    ),
  ));
}
```

***

### Day 4: App Shell + Navigation

**الملفات المنفَّذة:**
```
core/router/app_router.dart
core/widgets/app_shell.dart
core/widgets/app_sidebar.dart
core/widgets/app_top_bar.dart
```

**ترتيب التنفيذ:**
```
1. app_router.dart     → تعريف كل الـ routes + ShellRoute
2. app_sidebar.dart    → Sidebar مع Nav Items + Hover states
3. app_top_bar.dart    → TopBar مع التاريخ + Bell icon
4. app_shell.dart      → يجمع Sidebar + TopBar + Content
5. main.dart           → ربط AppTheme + AppRouter + GetIt
```

***

### Day 5: Shared Widgets

**الملفات المنفَّذة:**
```
core/widgets/stat_card.dart
core/widgets/empty_state.dart
core/widgets/error_state.dart
core/widgets/loading_skeleton.dart
core/widgets/confirm_dialog.dart
core/widgets/app_badge.dart
core/widgets/toast_notification.dart
```

**أولوية التنفيذ:**
```
1. loading_skeleton.dart  → يُستخدم في كل الشاشات
2. empty_state.dart       → يُستخدم في كل القوائم
3. error_state.dart       → يُستخدم مع كل Cubit
4. confirm_dialog.dart    → للحذف والإجراءات الخطرة
5. toast_notification.dart → للـ Success/Error feedback
6. stat_card.dart         → للـ Dashboard
7. app_badge.dart         → للـ Tags والـ Status
```

***

### Day 6-7: Isar Database Models

**ترتيب إنشاء الـ Models:**

```
1. ProductModel     → مستقل (لا يعتمد على أحد)
2. CustomerModel    → مستقل
3. SaleModel        → يعتمد على Customer
4. SaleItemModel    → يعتمد على Sale + Product
```

**بعد كتابة كل model:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**injection_container.dart — يُكتب في نهاية اليوم 7:**
```
ترتيب التسجيل:
1. Isar instance (singleton)
2. Datasources (lazy singleton)
3. Repositories (lazy singleton)
4. UseCases (lazy singleton)
5. Cubits (factory — جديد مع كل BlocProvider)
```

***

## 📅 الأسبوع الثاني — Products Feature

### Day 8: Product Domain Layer

**الترتيب:**
```
1. product.dart (Entity)
      ↓
2. product_repository.dart (Abstract)
      ↓
3. add_product.dart (UseCase)
4. update_product.dart
5. delete_product.dart
6. get_all_products.dart
7. search_products.dart
8. get_low_stock_products.dart
```

**قاعدة كل UseCase:**
```
- يعتمد على Repository (abstract)
- يُرجع Either<Failure, T>
- Params class منفصل لو في parameters
- NoParams لو مفيش parameters
```

***

### Day 9: Product Data Layer

**الترتيب:**
```
1. product_model.dart
      ↓ build_runner
2. product_local_datasource.dart
      ↓
3. product_repository_impl.dart
```

**product_local_datasource — الـ methods:**
```
□ Future<void> addProduct(ProductModel)
□ Future<void> updateProduct(ProductModel)
□ Future<void> deleteProduct(int id)
□ Future<List<ProductModel>> getAllProducts()
□ Future<List<ProductModel>> searchProducts(String query)
□ Future<List<ProductModel>> getLowStockProducts()
□ Future<List<ProductModel>> getExpiringProducts(int daysThreshold)
□ Future<List<ProductModel>> getExpiredProducts()
□ Stream<List<ProductModel>> watchAllProducts()
```

***

### Day 10: Product Cubit + State

**product_state.dart — الـ States:**
```
ProductInitial
ProductLoading
ProductLoaded(List<Product> products, List<Product> filtered)
ProductError(String message)
ProductOperationSuccess(String message)
```

**product_cubit.dart — الـ Methods:**
```
□ loadProducts()
□ searchProducts(String query)
□ filterByType(ProductType? type)
□ addProduct(Product)
□ updateProduct(Product)
□ deleteProduct(int id)
□ selectProduct(Product?)    → للـ Detail Panel
```

***

### Day 11-12: Products Screen + Widgets

**ترتيب بناء الـ UI:**
```
1. products_toolbar.dart
   - Search field
   - Filter chips (الكل / أدوية / مبيدات)
   - Add button

2. type_badge.dart         → micro widget
3. expiry_cell.dart        → micro widget
4. quantity_cell.dart      → micro widget

5. products_table.dart
   - DataTable2
   - Sortable columns
   - Row selection
   - Right-click menu

6. product_detail_panel.dart
   - Product info sections
   - Stock progress bar
   - Edit / Delete actions

7. add_edit_product_dialog.dart
   - Form with validation
   - Type toggle
   - Date picker
   - Live profit margin

8. products_screen.dart
   - يجمع كل الـ widgets
   - Master-Detail layout
```

***

### Day 13-14: Customer Feature

**ترتيب التنفيذ:**
```
Domain:
□ customer.dart (Entity)
□ customer_repository.dart (Abstract)
□ add_customer.dart
□ get_all_customers.dart
□ update_customer_debt.dart
□ record_payment.dart

Data:
□ customer_model.dart → build_runner
□ customer_local_datasource.dart
□ customer_repository_impl.dart

Presentation:
□ customer_state.dart
□ customer_cubit.dart
□ customers_table.dart
□ customer_detail_panel.dart
□ add_customer_dialog.dart
□ record_payment_dialog.dart
□ customers_screen.dart
```

***

## 📅 الأسبوع الثالث — POS & Invoices

### Day 15-16: Sale Domain + Data Layer

**الـ Entities:**
```
CartItem:
  - product: Product
  - quantity: int
  - unitPrice: double
  - get totalPrice → quantity * unitPrice

Sale:
  - id: int
  - invoiceNumber: String
  - items: List<CartItem>
  - totalAmount: double
  - paidAmount: double
  - paymentType: PaymentType (cash/credit)
  - customerId: int?
  - createdAt: DateTime
  - get remainingAmount → totalAmount - paidAmount

SaleItem:
  - saleId: int
  - productId: int
  - productName: String  ← مهم: نحفظ الاسم لو المنتج اتحذف
  - quantity: int
  - unitPrice: double
```

**create_sale UseCase — المنطق:**
```
1. التحقق من توفر المخزون لكل منتج
2. إنشاء Sale record
3. إنشاء SaleItems records
4. تحديث كمية كل منتج (quantity -= soldQty)
5. لو آجل: تحديث debtBalance للعميل
6. توليد invoice number تلقائي
7. كل ده في Isar Transaction واحدة (atomic)
```

***

### Day 17-18: POS Cubit + State

**pos_state.dart:**
```
PosState (base):
  - searchResults: List<Product>
  - cart: List<CartItem>
  - searchQuery: String
  - isLoading: bool
  - error: String?
  - completedSale: Sale?    → لفتح Invoice Preview

// getters على الـ State:
  - get totalAmount → cart.fold(0, (sum, i) => sum + i.totalPrice)
  - get itemCount   → cart.length
  - get isEmpty     → cart.isEmpty
```

**pos_cubit.dart — الـ Methods:**
```
□ search(String query)
□ addToCart(Product)
□ removeFromCart(int productId)
□ incrementQty(int productId)
□ decrementQty(int productId)
□ clearCart()
□ completeSale({PaymentType, double paidAmount, int? customerId})
□ resetAfterSale()
```

***

### Day 19: POS Screen + Widgets

**ترتيب البناء:**
```
1. pos_search_bar.dart
   - TextField مع autofocus
   - Keyboard shortcuts hint
   - onChanged → cubit.search()

2. product_pos_card.dart
   - Hover animation
   - Out of stock state
   - Added to cart indicator

3. product_grid.dart
   - GridView 3 columns
   - Pagination (بعدين)

4. cart_item_row.dart
   - اسم + سعر الوحدة
   - [-] qty [+] controls
   - المبلغ الإجمالي
   - زرار الحذف

5. cart_summary.dart
   - Subtotal / Discount / Total
   - 3 Action buttons

6. cart_panel.dart
   - Header + CartItems + CartSummary

7. pos_screen.dart
   - Left Panel + Right Panel
   - Keyboard handler
```

***

### Day 20: Payment Dialog + Invoice

**payment_dialog.dart — الـ Flow:**
```
Step 1: اختيار طريقة الدفع
        [● نقدي]  [○ آجل]

Step 2a (نقدي):
        المبلغ المدفوع: [_______]
        الباقي: XX ج  ← live calc

Step 2b (آجل):
        العميل: [Dropdown/Search]
        [+ عميل جديد]

Step 3: زرار [✅ إتمام البيع]
        → cubit.completeSale(...)
        → Navigator.pop()
        → show InvoicePreviewDialog
```

**invoice_generator.dart:**
```
generateInvoicePdf(Sale sale):
  1. إنشاء PDF document
  2. Header: شعار + اسم المحل + عنوان
  3. Invoice info: رقم + تاريخ + وقت
  4. Customer info (لو آجل)
  5. Items Table: المنتج | الكمية | سعر الوحدة | الإجمالي
  6. Summary: الإجمالي + الخصم + الصافي + المدفوع + الباقي
  7. Footer: شكراً للزيارة + تليفون المحل
  → return Uint8List (PDF bytes)
```

**invoice_preview_dialog.dart:**
```
□ عرض PDF داخل الـ Dialog
□ [🖨️ طباعة] → Printing.layoutPdf()
□ [📤 مشاركة] → Share.shareXFiles()
□ [بيع جديد]  → cubit.resetAfterSale() + Navigator.pop()
```

***

### Day 21: Alerts Feature

**get_all_alerts UseCase:**
```
يرجع AlertsData:
  - expired:      List<Product>  (expiryDate < today)
  - expiringSoon: List<Product>  (expiryDate < today + 30)
  - lowStock:     List<Product>  (qty ≤ minQty)
  - get totalCount → expired.length + expiringSoon.length + lowStock.length
```

**alerts_screen.dart:**
```
□ 3 Sections مرتبة: منتهية → قريبة → مخزون
□ كل Section: Collapsible + Count badge
□ Empty state لكل section
□ زرار "تعديل" في كل row → يفتح Edit Product Dialog
```

***

## 📅 الأسبوع الرابع — Dashboard, Reports & Polish

### Day 22: Dashboard Feature

**get_dashboard_stats UseCase:**
```
DashboardStats:
  - todaySales: double
  - todayInvoicesCount: int
  - totalProductsCount: int
  - alertsCount: int
  - totalDebt: double
  - last7DaysSales: List<DailySales>  ← للـ Chart
  - recentSales: List<Sale>           ← آخر 5 فواتير
  - urgentAlerts: List<AlertItem>     ← أهم 3 تنبيهات
```

**Dashboard Widgets:**
```
1. stats_row.dart          → 4 stat cards
2. sales_chart.dart        → Line chart (fl_chart)
3. alerts_panel.dart       → أهم 3 تنبيهات
4. recent_sales_table.dart → آخر 5 فواتير
5. dashboard_screen.dart   → يجمع الكل
```

***

### Day 23: Reports Feature

**get_sales_report UseCase:**
```
Params: DateRange (from, to)

ReportData:
  - totalSales: double
  - invoicesCount: int
  - averageInvoice: double
  - dailySales: List<DailySales>      ← للـ Bar Chart
  - topProducts: List<ProductSales>   ← أكثر 5 مبيعاً
  - invoices: List<Sale>              ← الجدول التفصيلي
```

**Reports Widgets:**
```
1. report_filter_bar.dart     → اليوم/الأسبوع/الشهر/مخصص
2. report_summary_row.dart    → 3 stat cards
3. sales_bar_chart.dart       → Bar chart يومي
4. top_products_chart.dart    → Horizontal bars
5. invoices_table.dart        → جدول تفصيلي
6. reports_screen.dart        → يجمع الكل
```

***

### Day 24: Notifications System

**ترتيب التنفيذ:**
```
1. إعداد flutter_local_notifications للـ Windows
2. NotificationService class:
   □ initialize()
   □ showExpiryAlert(List<Product> products)
   □ showLowStockAlert(List<Product> products)
3. ربطه في main.dart عند فتح التطبيق
4. Notification Dropdown في TopBar
5. تحديث Badge count في Sidebar
```

***

### Day 25: Window Manager + Settings

**window_manager setup:**
```dart
// main.dart
await windowManager.ensureInitialized();
WindowOptions windowOptions = WindowOptions(
  size: Size(1280, 800),
  minimumSize: Size(1024, 600),
  center: true,
  title: 'صيدلية السليماني — نظام الإدارة',
  titleBarStyle: TitleBarStyle.normal,
);
await windowManager.waitUntilReadyToShow(windowOptions, () async {
  await windowManager.show();
  await windowManager.focus();
});
```

**Settings Screen (بسيط للـ MVP):**
```
□ اسم المحل
□ عنوان المحل
□ رقم التليفون
□ تُستخدم في header الفاتورة
□ تُحفظ في Isar Settings collection
```

***

### Day 26: Integration Testing + Bug Fixes

**سيناريوهات الاختبار:**
```
Happy Path:
□ إضافة منتج جديد → يظهر في القائمة
□ بيع منتج → المخزون يتحدث
□ بيع آجل → الدين يُضاف للعميل
□ سداد عميل → الدين ينخفض
□ فاتورة PDF تتولد وتُشارك

Edge Cases:
□ بيع كمية أكبر من المخزون → يُمنع
□ حذف منتج له مبيعات → warning
□ منتج منتهي الصلاحية → تحذير
□ قاعدة البيانات فارغة → Empty states صح
□ بحث بنص غير موجود → Empty state
```

***

### Day 27: UI Polish

**Checklist:**
```
Animation & Transitions:
□ Sidebar nav transitions (150ms)
□ Card hover animations
□ Dialog open/close animations
□ Toast slide animation

RTL تدقيق:
□ كل النصوص من اليمين لليسار
□ الأيقونات في المكان الصح
□ الـ DataTable columns بترتيب صح
□ الـ Padding متماثل

Typography:
□ Cairo font تظهر صح
□ كل الـ text styles متسقة
□ أحجام النصوص مناسبة للـ Desktop

Colors:
□ Hover states كلها شغالة
□ Active states في الـ Sidebar
□ Danger/Warning colors صح
□ Disabled states واضحة
```

***

### Day 28: Final Testing + Delivery

**Build للـ Windows:**
```bash
flutter build windows --release
```

**Checklist قبل التسليم:**
```
Performance:
□ البحث < 200ms
□ POS screen تحميل < 500ms
□ لا يوجد memory leaks

Data Integrity:
□ Isar transactions تعمل صح
□ لا يفقد بيانات عند إغلاق التطبيق
□ Invoice numbers متسلسلة بدون تكرار

UX Final Check:
□ كل الـ error messages بالعربي
□ كل الـ empty states موجودة
□ Keyboard shortcuts شغالة
□ Window size يتذكر بعد الإغلاق
```

***

## 📊 ملخص الخطة

| الأسبوع | الأيام | المخرجات |
|---------|--------|---------|
| **1 — Foundation** | 1-7 | Project setup + Design System + App Shell + DB Models |
| **2 — Core Features** | 8-14 | Products كامل + Customers كامل |
| **3 — POS & Invoices** | 15-21 | POS + Payment + PDF + Alerts |
| **4 — Polish & Done** | 22-28 | Dashboard + Reports + Notifications + Testing |

***

## 🔜 ابدأ دلوقتي
