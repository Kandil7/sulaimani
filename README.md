# السليماني للتنمية الزراعية - نظام الإدارة

نظام إدارة متكامل لصيدلية السليماني لنظام Windows.

## نبذة عن المشروع

**صيدلية السليماني** هو نظام إدارةمحلمتكامل يعمل على نظام Windows، مبني باستخدام Flutter. يهدف النظام إلى استبدال الإدارة اليدوية بنظام رقمي يضمن:
- دقة المخزون
- تتبع الصلاحيات
- إصدار الفواتير بشكل فوري
- متابعة ديون العملاء

## المميزات

### ✅ إدارة المنتجات
- إضافة / تعديل / حذف المنتجات
- البحث بالاسم أو الكود
- فلترة بالنوع (أدوية / مبيدات)
- تنبيهات المخزون المنخفض
- تنبيهات الصلاحية

### ✅ نقطة البيع (POS)
- بحث سريع بالمنتجات
- إضافة للسلة بنقرة واحدة
- دعم الدفع نقدي أو آجل
- توليد فواتير PDF
- مشاركة على واتساب

### ✅ إدارة العملاء
- سجل عملاء كامل
- متابعة الديون
- تسجيل الدفعات

### ✅ نظام التنبيهات
- منتجات منتهية الصلاحية
- منتجات قريبة الانتهاء
- مخزون منخفض

### ✅ التقارير
- تقرير يومي / أسبوعي / شهري
- أكثر المنتجات مبيعاً

## التقنيات المستخدمة

| التقنية | الاستخدام |
|----------|-----------|
| **Flutter 3.x** | Framework |
| **BLoC / Cubit** | State Management |
| **Isar DB** | Database |
| **GetIt** | Dependency Injection |
| **GoRouter** | Navigation |
| **PDF + Printing** | الفواتير |
| **fl_chart** | Charts |

## هيكل المشروع

```
lib/
├── core/
│   ├── constants/     # AppColors, AppSizes, AppStrings
│   ├── di/          # Injection Container
│   ├── theme/       # Theme, Responsive
│   ├── utils/      # Utilities
│   └── widgets/    # Reusable Widgets
├── data/
│   ├── datasources/ # Database Service
│   ├── models/     # Isar Models
│   └── repositories/
├── domain/
│   └── entities/  # Business Entities
└── presentation/
    ├── alerts/   # Alerts Feature
    ├── customers/
    ├── dashboard/
    ├── layout/   # Shell, Sidebar
    ├── pos/      # Point of Sale
    ├── products/
    ├── reports/
    └── settings/
```

## التشغيل

### المتطلبات
- Windows 10/11
- Flutter SDK 3.x

### التثبيت

```bash
# استنساخ المشروع
git clone https://github.com/Kandil7/sulaimani.git
cd sulaimani

# تحميل المتطلبات
flutter pub get

# تشغيل
flutter run
```

### البناء

```bash
# بناء Windows
flutter build windows --release
```

الملف التنفيذي: `build\windows\x64\runner\Release\sulaimani.exe`

## واجهة المستخدم

- **اللغة:** العربية (RTL)
- **الفونت:** Cairo
- **الألوان:**
  - أخضر (#2E7D32) - الأساسي
  - أزرق (#1565C0) - أدوية
  - أحمر (#D32F2F) - خطأ/خطر
  - برتقالي (#F57C00) - تحذير

## المساهمة

نرحب بمسributionsك! أنشئ Fork ثم PR.

## الترخيص

MIT License

---

**صيدلية السليماني** - نظام إدارة متكامل