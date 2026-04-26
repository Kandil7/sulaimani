أكيد — هشرح لك **كل feature** في نظام **صيدلية السليماني** بالتفصيل، ومع كل feature هحط **user stories** واضحة ومعاها **acceptance criteria** علشان يبقى عندك تصور منتج/تنفيذ كامل. أمثلة user story الجيدة بتكون بصيغة “As a… I want… so that…” مع acceptance criteria واضحة لتقليل الغموض. [pmprompt](https://pmprompt.com/blog/user-story-examples)

## 1) إدارة المنتجات

دي أهم feature في النظام لأنها أساس المخزون والبيع. في محل أدوية ومبيدات، لازم المنتج يكون ليه هوية دقيقة: اسم، كود، نوع، سعر شراء، سعر بيع، كمية، حد أدنى، تاريخ صلاحية، وملاحظات. أنظمة المخزون الصيدلاني عادةً تعتمد على تتبع المخزون والمنتجات المنتهية والتنبيهات المبكرة لتقليل الأخطاء. [scribd](https://www.scribd.com/document/699760092/EM-S-PHARMACY-INVENTORY-MANAGEMENT-SYSTEM)

### لماذا هذه الـ feature مهمة؟
- تمنع ضياع المنتجات أو تكرارها.
- تسهّل البحث السريع وقت البيع.
- تضمن إن المنتجات المنتهية أو القريبة من الانتهاء تظهر بوضوح.
- تهيّئ البيانات لباقي الموديولات مثل POS والتقارير.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-PROD-01 | كصاحب محل، أريد إضافة منتج جديد بكل بياناته حتى أتمكن من بيعه وتتبع مخزونه. | عند حفظ المنتج يظهر فورًا في القائمة، الحقول الأساسية تكون مطلوبة، ويظهر تنبيه لو تاريخ الصلاحية غير صالح. |
| US-PROD-02 | كصاحب محل، أريد تعديل بيانات المنتج حتى أصحح الأسعار أو الكمية أو الصلاحية. | التعديل يحدث بدون فقد البيانات الأخرى، ويظهر التحديث في الجدول وPOS فورًا. |
| US-PROD-03 | كصاحب محل، أريد حذف منتج غير مستخدم حتى أنظف القائمة. | يظهر Confirm قبل الحذف، ولو المنتج مرتبط بمبيعات يتم منعه أو تحذيريًا حسب السياسة. |
| US-PROD-04 | كصاحب محل، أريد البحث بالاسم أو الكود حتى أصل للمنتج بسرعة. | البحث يعمل لحظيًا، ويستجيب خلال لحظات، ويعرض “لا توجد نتائج” لو لا يوجد مطابق. |
| US-PROD-05 | كصاحب محل، أريد فلترة المنتجات حسب النوع حتى أفرق بين الأدوية والمبيدات. | الفلترة تعرض “الكل / أدوية / مبيدات”، والنتائج تتحدث فورًا. |
| US-PROD-06 | كصاحب محل، أريد رؤية حالة المنتج من حيث الصلاحية والمخزون حتى أعرف هل أحتاج أتصرف. | تظهر ألوان: أخضر طبيعي، أصفر قريب الانتهاء/منخفض، أحمر منتهي/نفد. |

***

## 2) نقطة البيع POS

دي feature التشغيل اليومي الحقيقي. الهدف منها إن البيع يتم بسرعة وبأقل نقرات، مع تحديث المخزون تلقائيًا بعد كل فاتورة. أنظمة POS الجيدة تركّز على تسجيل الطلبات بسرعة، تتبع العميل، وإخراج فاتورة دقيقة، وهي من الركائز الأساسية في أنظمة البيع الحديثة. [eprints.utar.edu](http://eprints.utar.edu.my/2455/1/IB-2017-1304051.pdf)

### لماذا هذه الـ feature مهمة؟
- تقصر زمن البيع.
- تمنع أخطاء التسعير أو الخصم اليدوي.
- تربط البيع بالمخزون مباشرة.
- تفتح الباب للبيع الآجل والمتابعة المالية.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-POS-01 | ككاشير، أريد البحث عن منتج بسرعة من شاشة البيع حتى أضيفه للسلة. | البحث بالاسم أو الكود، والنتائج تظهر أثناء الكتابة. |
| US-POS-02 | ككاشير، أريد إضافة المنتج للسلة بنقرة واحدة حتى أجهز الفاتورة بسرعة. | النقر على المنتج يضيفه فورًا للسلة. |
| US-POS-03 | ككاشير، أريد زيادة أو تقليل الكمية داخل السلة حتى أصحح الفاتورة قبل الدفع. | أزرار + و - تعمل فورًا، ولا تسمح بالكمية السالبة. |
| US-POS-04 | ككاشير، أريد رؤية الإجمالي والباقي لحظيًا حتى أعرف قيمة الفاتورة. | الإجمالي يتحدث تلقائيًا مع أي تعديل. |
| US-POS-05 | ككاشير، أريد أن أمنع بيع منتج نفد أو غير متاح حتى لا أسبب خطأ في المخزون. | النظام يمنع الإضافة أو يظهر تحذير واضح لو الكمية غير كافية. |
| US-POS-06 | ككاشير، أريد إتمام البيع كاش أو آجل حتى أتعامل مع كل الحالات. | عند الكاش يُحسب المدفوع والباقي، وعند الآجل يُربط البيع بعميل. |
| US-POS-07 | ككاشير، أريد اختصارات لوحة مفاتيح حتى أسرّع الشغل على Windows. | F1 للبحث، F2 للدفع، Esc لمسح السلة تعمل بشكل ثابت. |

***

## 3) الفواتير

الفاتورة هي المستند الرسمي للعميل، وهي أيضًا مرجع داخلي لأي مراجعة أو استرجاع. في MVP، الفاتورة PDF تكفي جدًا، مع ترقيم تسلسلي وبيانات المحل والمنتجات والإجماليات. أنظمة POS الاحترافية تعتمد على تقارير وفواتير واضحة لتسهيل التتبع والمراجعة. [antamedia](https://www.antamedia.com/download/pos-manual.pdf)

### لماذا هذه الـ feature مهمة؟
- توثّق البيع.
- تسهّل المشاركة على واتساب أو الطباعة.
- تربط بين البيع والمحاسبة.
- تقلل النزاعات مع العملاء.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-INV-01 | كصاحب محل، أريد إنشاء فاتورة تلقائيًا بعد كل عملية بيع. | تُنشأ الفاتورة مباشرة بعد الدفع وتحتوي على رقم فريد. |
| US-INV-02 | كصاحب محل، أريد عرض معاينة للفاتورة قبل حفظها أو مشاركتها. | تظهر معاينة واضحة لكل العناصر قبل الإجراء النهائي. |
| US-INV-03 | كصاحب محل، أريد مشاركة الفاتورة PDF على واتساب حتى أرسلها للعميل. | زر المشاركة يفتح مشاركة النظام ويحمل الملف مباشرة. |
| US-INV-04 | كصاحب محل، أريد إعادة طباعة فاتورة سابقة حتى أتعامل مع طلبات الرجوع. | يمكن فتح أي فاتورة سابقة وإعادة تصديرها. |
| US-INV-05 | كصاحب محل، أريد أن يظهر اسم المحل “السليماني” في أعلى الفاتورة. | الهيدر يحتوي الاسم والشعار والعنوان لاحقًا. |

***

## 4) العملاء والديون

الميزة دي أساسية لو عندك بيع آجل أو عملاء دائمين. سجل العملاء يسهّل متابعة الرصيد، المشتريات، والسداد. إدارة بيانات العميل وتاريخه الشرائي من أهم وظائف أنظمة البيع الحديثة لأنها تحسن المتابعة المالية والولاء. [scribd](https://www.scribd.com/document/699760092/EM-S-PHARMACY-INVENTORY-MANAGEMENT-SYSTEM)

### لماذا هذه الـ feature مهمة؟
- تتابع الدين بدقة.
- تعرف العميل المدين بسرعة.
- تسهل تسجيل السداد الجزئي والكامل.
- تعطيك صورة عن العملاء المتكررين.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-CUS-01 | كصاحب محل، أريد إضافة عميل باسم ورقم هاتف حتى أربط المبيعات الآجلة به. | الحقول الأساسية تُحفظ وتظهر في القائمة. |
| US-CUS-02 | كصاحب محل، أريد رؤية رصيد الدين لكل عميل حتى أعرف المبالغ المستحقة. | يظهر الرصيد بشكل واضح ومحدّث بعد كل عملية بيع/سداد. |
| US-CUS-03 | كصاحب محل، أريد تسجيل دفعة من عميل حتى أخفض رصيده. | عند تسجيل الدفع يقل الدين مباشرة ويظهر في السجل. |
| US-CUS-04 | كصاحب محل، أريد رؤية سجل مشتريات العميل حتى أراجع تعاملاته. | تظهر آخر الفواتير وتواريخها وقيمها. |
| US-CUS-05 | كصاحب محل، أريد البحث عن العميل بسرعة حتى أستخدمه أثناء البيع الآجل. | البحث بالاسم أو الهاتف يعمل سريعًا. |

***

## 5) التنبيهات

دي feature مهمة جدًا في مشروعك لأنك تتعامل مع منتجات ذات حساسية زمنية: أدوية ومبيدات. التنبيه المبكر على الصلاحية والمخزون المنخفض يساعد في تقليل الخسائر وتحسين السلامة التشغيلية، وهو من أهم وظائف أنظمة المخزون الصيدلانية. [langate](https://langate.com/news-and-blog/10-main-features-of-a-pharmacy-inventory-management-system/)

### لماذا هذه الـ feature مهمة؟
- تمنع بيع منتهٍ.
- تنبّهك قبل الخسارة.
- تساعد في ترتيب الأولويات.
- تحسن إدارة المخزون بشكل يومي.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-ALT-01 | كصاحب محل، أريد معرفة المنتجات المنتهية حتى أوقف بيعها فورًا. | تظهر المنتجات المنتهية باللون الأحمر في شاشة التنبيهات. |
| US-ALT-02 | كصاحب محل، أريد معرفة المنتجات القريبة من الانتهاء حتى أتصرف قبل الخسارة. | المنتجات التي تبقى لها أقل من 30 يوم تظهر باللون الأصفر. |
| US-ALT-03 | كصاحب محل، أريد معرفة المنتجات منخفضة المخزون حتى أعيد الطلب. | أي منتج تحت الحد الأدنى يظهر في قسم المخزون المنخفض. |
| US-ALT-04 | كصاحب محل، أريد عداد تنبيهات في الواجهة حتى أعرف الحالة العامة بسرعة. | يظهر Badge بعدد التنبيهات في الـ Sidebar أو TopBar. |
| US-ALT-05 | كصاحب محل، أريد فتح المنتج من شاشة التنبيهات لتعديله مباشرة. | زر “تعديل” ينقلني لبيانات المنتج أو الحوار المناسب. |

***

## 6) Dashboard

الـ Dashboard هو شاشة الملخص. هو مش مكان تنفيذ عميق، لكنه المكان اللي يديك صورة فورية عن صحة المحل: المبيعات، المخزون، الديون، والتنبيهات. الملخصات والتقارير المرئية تُستخدم كثيرًا في أنظمة البيع والمخزون لأنها تساعد في اتخاذ القرار السريع. [eprints.utar.edu](http://eprints.utar.edu.my/2455/1/IB-2017-1304051.pdf)

### لماذا هذه الـ feature مهمة؟
- تعرف وضع المحل في ثواني.
- تتابع الاتجاهات اليومية.
- تكشف المشاكل مبكرًا.
- توصل للتنبيهات المهمة بدون بحث.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-DB-01 | كصاحب محل، أريد رؤية مبيعات اليوم حتى أعرف أداء المحل. | تظهر قيمة واضحة ومحدثة. |
| US-DB-02 | كصاحب محل، أريد رؤية عدد أصناف المخزون حتى أعرف حجم العمل. | يظهر العدد الإجمالي للمنتجات. |
| US-DB-03 | كصاحب محل، أريد رؤية عدد التنبيهات حتى أقرر أولوياتي. | يظهر العدد في كارت مستقل ومشروح. |
| US-DB-04 | كصاحب محل، أريد رؤية ديون العملاء حتى أتابع التحصيل. | يظهر إجمالي الدين الحالي. |
| US-DB-05 | كصاحب محل، أريد رؤية مبيعات آخر 7 أيام حتى أراقب الاتجاه. | يظهر Chart واضح وسهل القراءة. |
| US-DB-06 | كصاحب محل، أريد رؤية آخر الفواتير حتى أراجع نشاط اليوم بسرعة. | قائمة مختصرة بأحدث الفواتير. |

***

## 7) التقارير

التقارير هنا تكون MVP بسيطة لكن مفيدة: مبيعات اليوم، عدد الفواتير، أكثر المنتجات مبيعًا، وجدول الفواتير. هذا النوع من التقارير يُستخدم عادةً لدعم القرار وتحليل الحركة البيعية. [antamedia](https://www.antamedia.com/download/pos-manual.pdf)

### لماذا هذه الـ feature مهمة؟
- تساعدك تفهم الربح والحركة.
- تكشف المنتجات الرائجة.
- تعطيك أداة مراجعة للأيام السابقة.
- تبني أساس قوي للتوسع لاحقًا.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-RPT-01 | كصاحب محل، أريد تقرير مبيعات اليوم حتى أعرف إجمالي اليوم. | يظهر الإجمالي وعدد الفواتير ومتوسط الفاتورة. |
| US-RPT-02 | كصاحب محل، أريد فلترة التقرير حسب اليوم أو الأسبوع أو الشهر حتى أقارن فترات مختلفة. | التغيير في الفلتر يحدث النتائج فورًا. |
| US-RPT-03 | كصاحب محل، أريد رؤية جدول الفواتير حتى أراجع كل فاتورة بالتفصيل. | يظهر رقم الفاتورة والعميل والقيمة والتاريخ والحالة. |
| US-RPT-04 | كصاحب محل، أريد معرفة أكثر 5 منتجات مبيعًا حتى أعيد التخطيط للمخزون. | تظهر المنتجات مرتبة بالأعلى مبيعًا. |
| US-RPT-05 | كصاحب محل، أريد تصدير التقرير لاحقًا حتى أشاركه أو أراجعه خارج التطبيق. | التصدير يكون CSV أو Excel في Phase لاحقة. |

***

## 8) الإعدادات وبيانات المحل

الميزة دي صغيرة لكنها مهمة جدًا لأنها تربط هوية المحل بكل شيء: الفواتير، العنوان، رقم الهاتف، والشعار. في الـ MVP، تكفي بيانات أساسية تتعرض في الفاتورة والـ header، وبعدها يمكن توسيعها. [chisellabs](https://chisellabs.com/blog/product-requirement-document-prd-templates/)

### لماذا هذه الـ feature مهمة؟
- توحّد اسم وهوية المحل.
- تستخدم في الفواتير والتقارير.
- تسهّل التخصيص لاحقًا.

### User Stories
| ID | User Story | Acceptance Criteria |
|---|---|---|
| US-SET-01 | كصاحب محل، أريد حفظ اسم المحل حتى يظهر في كل الفواتير. | الاسم يظهر في الهيدر والـ invoices. |
| US-SET-02 | كصاحب محل، أريد حفظ العنوان ورقم الهاتف حتى تظهر في الفاتورة. | البيانات تظهر بشكل صحيح في PDF. |
| US-SET-03 | كصاحب محل، أريد تغيير هذه البيانات لاحقًا دون إعادة تثبيت التطبيق. | التعديل يظهر فورًا في كل الأماكن التي تعتمد عليها. |

***

## 9) القواعد العامة لكل User Story

كل feature لازم يكون لها صياغة ثابتة علشان التطوير والاختبار يبقوا واضحين. user stories الجيدة تكون مرتبطة بهدف المستخدم، ويكون لها acceptance criteria قابلة للاختبار بدل العبارات العامة. [aakashg](https://www.aakashg.com/examples-of-user-stories-with-acceptance-criteria/)

### الشكل المثالي
- **As a**: مين المستخدم.
- **I want**: إيه اللي يريده.
- **So that**: ليه ده مهم.
- **Acceptance Criteria**: إمتى نعتبره ناجح.

### مثال كامل
**User Story:**  
كصاحب محل، أريد إضافة منتج جديد حتى أتمكن من بيعه وتتبع مخزونه.

**Acceptance Criteria:**
- الحقول الأساسية مطلوبة.
- المنتج يظهر فورًا بعد الحفظ.
- لو الصلاحية منتهية يظهر تحذير.
- لو الكود مكرر يظهر خطأ.

***

## 10) ترتيب التنفيذ المقترح

لو هتنفذهم صح، ده الترتيب الأفضل:
1. إدارة المنتجات.
2. POS.
3. الفواتير.
4. العملاء.
5. التنبيهات.
6. Dashboard.
7. التقارير.
8. الإعدادات.

ده الترتيب الأنسب لأن الـ POS يعتمد على المنتجات، والفواتير تعتمد على الـ POS، والعملاء يعتمدون على البيع الآجل، والتنبيهات والتقارير تعتمد على البيانات المتولدة من كل ده. [scribd](https://www.scribd.com/document/699760092/EM-S-PHARMACY-INVENTORY-MANAGEMENT-SYSTEM)

## 11) الخلاصة العملية

في الـ MVP، أهم 4 features فعلًا هم:
- المنتجات.
- البيع POS.
- الفواتير.
- التنبيهات.

والباقي يبقى داعم ليهم. لو بنيتهم بالترتيب ده، هتقدر تطلع نسخة أولى قوية جدًا وتفتح باب التوسع لاحقًا بدون إعادة بناء. [langate](https://langate.com/news-and-blog/10-main-features-of-a-pharmacy-inventory-management-system/)

أكيد. هشرح لك **صيغة user story كاملة ومفصلة** لكل feature، بحيث تقدر تستخدمها مباشرة في الـ PRD أو الـ backlog أو حتى في Jira. user stories الجيدة لازم تكون واضحة، قابلة للاختبار، ومقسّمة بشكل يجعل كل story صغيرة بما يكفي للتنفيذ في sprint واحد. [scribd](https://www.scribd.com/document/907305888/User-Story-Writing-Guide-2025)

## شكل الـ User Story

الهيكل الأفضل:
- **As a**: من هو المستخدم.
- **I want**: ما الذي يريده.
- **So that**: لماذا يريد ذلك.
- **Acceptance Criteria**: متى نعتبرها مكتملة.
- **Priority**: Must / Should / Could.
- **Dependencies**: ما الذي تعتمد عليه.

مثال:
- As a shop owner, I want to add a new product, so that I can sell it and track its stock.
- Acceptance Criteria: الحقول الإلزامية مكتملة، المنتج يظهر في القائمة، ويتم حفظه في قاعدة البيانات، وتظهر رسالة نجاح. [meegle](https://www.meegle.com/en_us/topics/user-story/user-story-acceptance-criteria-template)

## 1) Product Management

هذه الـ feature هي أساس النظام كله. من غيرها لا يوجد بيع، ولا تقارير، ولا تنبيهات دقيقة. في نظام صيدلية/مبيدات، إدارة المنتج لا تقتصر على الاسم والسعر فقط، بل تشمل النوع، الصلاحية، الكمية، والحد الأدنى، لأن إدارة المخزون الصيدلي تعتمد على تتبع التواريخ والدفعات والحدود الدنيا. [langate](https://langate.com/news-and-blog/10-main-features-of-a-pharmacy-inventory-management-system/)

### Story PM-01
**As a** shop owner, **I want** to add a new product with all required details, **so that** I can sell it and track its inventory.

Acceptance Criteria:
- يمكن إدخال الاسم، الكود، النوع، سعر الشراء، سعر البيع، الكمية، الحد الأدنى، وتاريخ الصلاحية.
- لا يمكن الحفظ إذا كانت الحقول الأساسية فارغة.
- يظهر المنتج فورًا في قائمة المنتجات بعد الحفظ.
- يتم حفظ البيانات محليًا بشكل دائم.
- إذا كان تاريخ الصلاحية في الماضي، يظهر تحذير قبل الحفظ.

### Story PM-02
**As a** shop owner, **I want** to edit an existing product, **so that** I can correct prices, quantities, or expiry dates.

Acceptance Criteria:
- يتم فتح نموذج التعديل بالبيانات الحالية.
- التعديل لا يضيع أي حقول أخرى غير المعدلة.
- بعد الحفظ، تظهر التغييرات في الجدول وداخل POS.
- يتم تحديث التنبيهات المرتبطة بالمنتج تلقائيًا.

### Story PM-03
**As a** shop owner, **I want** to delete a product, **so that** I can remove items I no longer sell.

Acceptance Criteria:
- يظهر Confirm dialog قبل الحذف.
- إذا كان المنتج مرتبطًا بمبيعات، يتم منعه أو تنبيه المستخدم حسب السياسة.
- بعد الحذف، يختفي من القائمة ومن البحث.
- لا يحدث crash أو فقد بيانات أخرى.

### Story PM-04
**As a** shop owner, **I want** to search products by name or code, **so that** I can find items quickly.

Acceptance Criteria:
- البحث يعمل أثناء الكتابة.
- يعرض النتائج المطابقة فقط.
- البحث لا يبطئ الواجهة.
- إذا لم توجد نتائج، تظهر رسالة مناسبة.

### Story PM-05
**As a** shop owner, **I want** to filter products by type, **so that** I can separate medicines from pesticides.

Acceptance Criteria:
- يوجد فلتر: الكل / أدوية / مبيدات.
- الفلتر يحدّث القائمة فورًا.
- يمكن دمجه مع البحث النصي.
- الفلتر لا يؤثر على البيانات الأصلية.

## 2) Inventory and Expiry

هذه feature مهمة جدًا لأن المنتجات حساسة زمنيًا. في الصيدليات ومحلات المبيدات، الصلاحية والمخزون المنخفض مش مجرد معلومات إضافية، بل هي جزء من السلامة وتقليل الخسارة. [hashmicro](https://www.hashmicro.com/ph/blog/pharmacy-inventory-management-system/)

### Story INV-01
**As a** shop owner, **I want** to see stock quantity and minimum threshold, **so that** I know when to reorder.

Acceptance Criteria:
- تظهر الكمية الحالية لكل منتج.
- يظهر الحد الأدنى لكل منتج.
- إذا وصلت الكمية للحد الأدنى أو أقل، يظهر تنبيه.
- التنبيه يظهر في شاشة التنبيهات وداخل الجدول.

### Story INV-02
**As a** shop owner, **I want** to see expiry status, **so that** I can avoid selling expired items.

Acceptance Criteria:
- يظهر تاريخ الصلاحية بصيغة واضحة.
- المنتج المنتهي يظهر باللون الأحمر.
- المنتج القريب من الانتهاء يظهر باللون الأصفر.
- الحساب يتم تلقائيًا بناءً على تاريخ اليوم.

### Story INV-03
**As a** shop owner, **I want** to get low-stock alerts, **so that** I can replenish items in time.

Acceptance Criteria:
- أي منتج qty <= minQty يظهر في alerts.
- العدد الإجمالي للتنبيهات يتحدث تلقائيًا.
- يمكن فتح المنتج مباشرة من التنبيه.

### Story INV-04
**As a** shop owner, **I want** to view expired products list, **so that** I can stop selling them.

Acceptance Criteria:
- يوجد قسم منفصل للمنتهية.
- المنتجات مرتبة حسب الأقدم انتهاءً.
- يتم تمييزها بصريًا بوضوح.
- لا تظهر المنتجات المنتهية كمتاحة في POS.

## 3) POS

هذه هي قلب التشغيل اليومي. الـ POS يجب أن يكون سريعًا وبسيطًا للغاية، لأنه المكان الذي ستتم فيه معظم العمليات. أنظمة البيع الفعالة تركّز على تقليل النقرات، التحديث الفوري، ومنع الأخطاء في الكمية أو المخزون. [eprints.utar.edu](http://eprints.utar.edu.my/2455/1/IB-2017-1304051.pdf)

### Story POS-01
**As a** cashier, **I want** to search products from the sales screen, **so that** I can add them to the bill quickly.

Acceptance Criteria:
- البحث بالاسم أو الكود.
- النتائج تظهر أثناء الكتابة.
- يمكن استخدام الكيبورد بالكامل.
- لا يتم البحث في شاشة منفصلة.

### Story POS-02
**As a** cashier, **I want** to add a product to the cart with one click, **so that** I can speed up checkout.

Acceptance Criteria:
- النقر يضيف المنتج مباشرة للسلة.
- إذا كان المنتج مكررًا، تزيد الكمية بدل إضافة سطر جديد.
- المنتجات غير المتوفرة لا يمكن إضافتها.
- السلة تتحدث لحظيًا.

### Story POS-03
**As a** cashier, **I want** to increase or decrease item quantity in the cart, **so that** I can correct the bill before payment.

Acceptance Criteria:
- يوجد + و - لكل عنصر.
- الكمية لا تقل عن 1 داخل السلة.
- لو أصبحت الكمية أكبر من المتاح، يظهر تحذير.
- الإجمالي يتحدث فورًا.

### Story POS-04
**As a** cashier, **I want** to remove an item from the cart, **so that** I can correct mistakes.

Acceptance Criteria:
- زر حذف واضح لكل عنصر.
- عند الحذف، يختفي العنصر فورًا.
- المجموع يتحدث تلقائيًا.
- لا يفقد باقي عناصر السلة.

### Story POS-05
**As a** cashier, **I want** to see the total amount and change instantly, **so that** I can complete the sale accurately.

Acceptance Criteria:
- الإجمالي والصافي يظهران دائمًا.
- عند الدفع النقدي يظهر الباقي تلقائيًا.
- أي تغيير في السلة ينعكس فورًا.
- لا يحدث تأخير في الواجهة.

### Story POS-06
**As a** cashier, **I want** to complete a cash sale, **so that** I can finalize the transaction.

Acceptance Criteria:
- يمكن إدخال المبلغ المدفوع.
- يتم حساب الباقي تلقائيًا.
- لا يمكن الإتمام إذا كان المدفوع أقل من الإجمالي إلا لو مسموح.
- بعد الإتمام يتم إنشاء فاتورة وتحديث المخزون.

### Story POS-07
**As a** cashier, **I want** to complete a credit sale, **so that** I can sell to customers on account.

Acceptance Criteria:
- يمكن اختيار عميل من القائمة.
- يتم ربط الفاتورة بملف العميل.
- الدين يزيد بنفس قيمة الفاتورة أو الجزء غير المدفوع.
- يظهر العميل في قائمة المدينين.

### Story POS-08
**As a** cashier, **I want** keyboard shortcuts, **so that** I can work faster on Windows.

Acceptance Criteria:
- F1 يضع المؤشر في البحث.
- F2 يفتح نافذة الدفع.
- Esc يمسح السلة أو يغلق النوافذ.
- الاختصارات تعمل في كل مرة بشكل ثابت.

## 4) Invoice Generation

الفاتورة هي سجل رسمي. مهمتها التوثيق والمشاركة والطباعة. وجود PDF منظم يجعل النظام أكثر احترافية ويقلل الاعتماد على الورق اليدوي. [antamedia](https://www.antamedia.com/download/pos-manual.pdf)

### Story INVF-01
**As a** shop owner, **I want** to generate a PDF invoice after each sale, **so that** I can keep a record and share it with the customer.

Acceptance Criteria:
- الفاتورة تُنشأ فور إتمام البيع.
- تحتوي على رقم فريد وتاريخ ووقت.
- تعرض اسم المحل والمنتجات والإجمالي.
- يمكن حفظها محليًا أو مشاركتها.

### Story INVF-02
**As a** shop owner, **I want** to preview the invoice before sharing, **so that** I can verify its content.

Acceptance Criteria:
- تظهر معاينة قبل الحفظ أو المشاركة.
- تظهر البيانات بشكل مقروء.
- يمكن الرجوع بدون مشاركة.

### Story INVF-03
**As a** shop owner, **I want** to share the invoice via WhatsApp, **so that** I can send it to the customer easily.

Acceptance Criteria:
- زر مشاركة واضح.
- الملف يُرسل كـ PDF.
- المشاركة لا تكسر تنسيق الفاتورة.

## 5) Customers and Debts

سجل العملاء مهم جدًا في البيع الآجل. الهدف هنا ليس CRM ضخم، بل نظام بسيط وآمن لتتبع الأرصدة والمدفوعات.

### Story CUS-01
**As a** shop owner, **I want** to add a customer with name and phone, **so that** I can link credit sales to them.

Acceptance Criteria:
- الاسم ورقم الهاتف يُحفظان.
- العميل يظهر في القائمة.
- يمكن استخدامه في البيع الآجل.

### Story CUS-02
**As a** shop owner, **I want** to see each customer’s balance, **so that** I know how much they owe.

Acceptance Criteria:
- يظهر الرصيد الحالي بوضوح.
- يتحدث بعد كل بيع أو سداد.
- إذا لا يوجد دين يظهر 0 أو no debt.

### Story CUS-03
**As a** shop owner, **I want** to record a payment from a customer, **so that** I can reduce the outstanding debt.

Acceptance Criteria:
- يمكن إدخال مبلغ السداد.
- الرصيد ينخفض مباشرة.
- يظهر تاريخ الحركة في سجل العميل.
- لا يمكن تسجيل سداد أكبر من الدين إلا لو مسموح.

### Story CUS-04
**As a** shop owner, **I want** to view a customer’s purchase history, **so that** I can review their transactions.

Acceptance Criteria:
- تظهر الفواتير السابقة.
- يمكن فتح أي فاتورة قديمة.
- التاريخ والترتيب يكونان واضحين.

## 6) Alerts

هذه feature أساسية جدًا لمشروعك لأن المنتجات لها صلاحية ومخزون. التنبيهات المبكرة تقلل الخسائر وتساعد في التشغيل اليومي. [langate](https://langate.com/news-and-blog/10-main-features-of-a-pharmacy-inventory-management-system/)

### Story ALT-01
**As a** shop owner, **I want** to see expired products, **so that** I stop selling them.

Acceptance Criteria:
- كل منتج منتهي يظهر في قسم مستقل.
- اللون أحمر.
- يمكن فتح المنتج للتعديل.

### Story ALT-02
**As a** shop owner, **I want** to see products expiring soon, **so that** I can act before they expire.

Acceptance Criteria:
- المنتجات التي تبقى لها أقل من 30 يوم تظهر.
- اللون أصفر أو برتقالي.
- الترتيب يبدأ بالأقرب انتهاءً.

### Story ALT-03
**As a** shop owner, **I want** to see low stock products, **so that** I can reorder them.

Acceptance Criteria:
- يظهر كل منتج تحت الحد الأدنى.
- العدد المعروض يكون دقيقًا.
- يمكن الانتقال للمنتج من التنبيه.

### Story ALT-04
**As a** shop owner, **I want** a badge showing alert count, **so that** I can know system status quickly.

Acceptance Criteria:
- الرقم يتحدث تلقائيًا.
- إذا لا يوجد تنبيهات، يختفي أو يظهر 0 حسب التصميم.
- الرقم يعكس مجموع كل التنبيهات.

## 7) Dashboard

الـ Dashboard هو ملخص الإدارة السريع. لا ينفذ عمليات، لكنه يسهّل اتخاذ القرار. وهو عادةً مبني على بيانات المخزون والمبيعات والتنبيهات. [eprints.utar.edu](http://eprints.utar.edu.my/2455/1/IB-2017-1304051.pdf)

### Story DB-01
**As a** shop owner, **I want** to see today’s sales total, **so that** I can know daily performance.

Acceptance Criteria:
- الرقم يظهر بوضوح.
- يتحدث مع أي عملية بيع.
- لا يحتاج فتح تقرير منفصل.

### Story DB-02
**As a** shop owner, **I want** to see the number of products in stock, **so that** I can understand inventory size.

Acceptance Criteria:
- يظهر العدد الكلي للأصناف.
- الرقم يشمل كل المنتجات الحالية.
- يتحدث مع إضافة أو حذف منتج.

### Story DB-03
**As a** shop owner, **I want** to see debt total, **so that** I can follow collections.

Acceptance Criteria:
- الإجمالي يجمع كل ديون العملاء.
- يتغير مع كل سداد أو بيع آجل.
- يظهر بشكل واضح وغير ملتبس.

### Story DB-04
**As a** shop owner, **I want** to see recent sales, **so that** I can review recent activity.

Acceptance Criteria:
- يظهر آخر 5 أو 10 فواتير.
- يعرض الوقت والقيمة والعميل.
- يمكن فتح الفاتورة من السجل.

### Story DB-05
**As a** shop owner, **I want** to see a sales chart for the last 7 days, **so that** I can understand trends.

Acceptance Criteria:
- الرسم واضح ومقروء.
- القيم تمثل الأيام بشكل صحيح.
- البيانات تتحدث يوميًا أو عند البيع.

## 8) Reports

التقارير تساعدك بعد التشغيل في التحليل. في الـ MVP ستكون بسيطة، لكنها مهمة جدًا لمعرفة أفضل المنتجات والمبيعات اليومية.

### Story RPT-01
**As a** shop owner, **I want** a daily sales report, **so that** I can review performance.

Acceptance Criteria:
- يعرض إجمالي المبيعات.
- يعرض عدد الفواتير.
- يعرض متوسط الفاتورة.

### Story RPT-02
**As a** shop owner, **I want** to filter reports by period, **so that** I can compare time ranges.

Acceptance Criteria:
- يوجد اليوم / الأسبوع / الشهر / مخصص.
- البيانات تتغير حسب الفلتر.
- الفلتر لا يغير البيانات الأصلية.

### Story RPT-03
**As a** shop owner, **I want** a list of top-selling products, **so that** I know what to reorder.

Acceptance Criteria:
- المنتجات مرتبة تنازليًا.
- يظهر عدد الوحدات أو قيمة المبيعات.
- يمكن استخدام النتائج في التخطيط.

### Story RPT-04
**As a** shop owner, **I want** an invoice table, **so that** I can inspect transactions.

Acceptance Criteria:
- تعرض رقم الفاتورة والعميل والمبلغ والتاريخ.
- يمكن فتح أي صف.
- الجدول يدعم الفرز أو الفلترة لاحقًا.

## 9) Settings and Store Info

هذه feature صغيرة لكنها مهمة لهوية النظام والفواتير.

### Story SET-01
**As a** shop owner, **I want** to store the shop name, **so that** it appears on invoices and headers.

Acceptance Criteria:
- الاسم يظهر في الفاتورة والواجهة.
- يمكن تعديله لاحقًا.
- لا يتسبب في كسر التصميم.

### Story SET-02
**As a** shop owner, **I want** to store address and phone, **so that** customers can contact the shop.

Acceptance Criteria:
- يظهر العنوان في الفاتورة.
- يظهر الهاتف في الهيدر أو الفوتر.
- يمكن التعديل بسهولة.

## 10) Best practice في كتابة كل story

عشان تكتب أي user story صح:
- خليها **واحدة فقط** لكل هدف.
- اكتبها من منظور المستخدم.
- حط acceptance criteria قابلة للقياس.
- لا تخلط عدة features في story واحدة.
- لو story كبيرة، قسمها إلى stories أصغر. [altexsoft](https://www.altexsoft.com/blog/acceptance-criteria-purposes-formats-and-best-practices/)

## 11) ترتيب الأولوية

لو هنبدأ صح، الأولويات تكون:
1. Product Management.
2. POS.
3. Invoice Generation.
4. Customers & Debts.
5. Alerts.
6. Dashboard.
7. Reports.
8. Settings.

ده الترتيب الأكثر منطقية لأنه يضمن إن النظام يشتغل من أول أسبوع تشغيل فعلي. [hashmicro](https://www.hashmicro.com/ph/blog/pharmacy-inventory-management-system/)

تمام يا Mohamed — خلينا نجمع كل ده في **Backlog جاهز للتنفيذ** بصيغة منظمة تقدر تنسخها في Notion / Jira / Excel.

***

### ✅ Product Backlog — صيدلية السليماني

#### **Epic 1: Product Management**

| Story ID | User Story | AC (Acceptance Criteria) | Priority |
|---------|-----------|-------------------------|----------|
| EP1-01 | As a shop owner, I want to add a new product with all details so that I can sell it. | -  ٧ حقول مطلوبة (الاسم، الكود، النوع، سعر شراء، بيع، كمية، حد أدنى، صلاحية) -  لا يحفظ لو حقل أساسي فارغ -  المنتج يظهر فوراً في القائمة -  حفظ محلي دائم -  تنبيه لو الصلاحية منتهية | Must Have |
| EP1-02 | As a shop owner, I want to edit a product so that I can correct data. | -  نموذج مفتوح بالبيانات الحالية -  لا يفقد باقي الحقول -  التغيير يظهر في الجدول وPOS | Must Have |
| EP1-03 | As a shop owner, I want to delete a product so that I can clean the list. | -  Confirm قبل الحذف -  لو مرتبط بالمبيعات: يظهر تحذير أو منع -  يختفي من القائمة -  لا يحدث crash | Must Have |
| EP1-04 | As a shop owner, I want to search products by name/code so that I can find them fast. | -  البحث أثناء الكتابة -  نتائج مطابقة -  لو مش موجود، رسالة "لا توجد نتائج" -  لا بطء في الواجهة | Must Have |
| EP1-05 | As a shop owner, I want to filter by type (medicine/pesticide) so that I can separate categories. | -  فلتر: الكل / أدوية / مبيدات -  التحديث فوري -  يدعم دمج مع البحث | Must Have |

***

#### **Epic 2: Inventory & Expiry**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP2-01 | As a shop owner, I want to see stock and minimum so that I know when to reorder. | -  كمية وحد أدنى لكل منتج -  لو <= حد أدنى: تنبيه لون / أيقونة | Must Have |
| EP2-02 | As a shop owner, I want to see expiry status so that I avoid expired items. | -  تاريخ واضح -  منتهي: أحمر -  قريب الانتهاء: أصفر -  حساب تلقائي اليومي | Must Have |
| EP2-03 | As a shop owner, I want to see low-stock alerts so that I can reorder on time. | -  قسم "مخزون منخفض" -  يظهر عدد التنبيهات -  يمكن فتح المنتج مباشرة | Must Have |
| EP2-04 | As a shop owner, I want to see expired products list so that I stop selling them. | -  قسم "منتهية الصلاحية" -  مرتب تاريخيًا -  تمييز واضح | Must Have |

***

#### **Epic 3: POS**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP3-01 | As a cashier, I want to search products from POS so that I can add them quickly. | -  بحث باسم/كود -  نتائج حية -  لا حاجة لشاشة منفصلة | Must Have |
| EP3-02 | As a cashier, I want to add product to cart in one click so that I speed checkout. | -  نقرة → سلة -  إذا تكرر، تزيد الكمية -  المنتجات غير المتوفرة: منع/تحذير | Must Have |
| EP3-03 | As a cashier, I want to change quantity in cart so that I correct the bill. | -  أزرار + و - -  الحد الأدنى = 1 -  لو > المتوفر: تحذير -  الإجمالي يتحدث | Must Have |
| EP3-04 | As a cashier, I want to remove item from cart so that I fix errors. | -  زر حذف لكل سطر -  سطر يختفي فوراً -  الإجمالي يتحديث | Must Have |
| EP3-05 | As a cashier, I want to see total/change instantly so that I complete sale accurately. | -  إجمالي/صافي/باقي ظاهرين دائمًا -  يتحدث مع أي تغيير -  لا تأخير | Must Have |
| EP3-06 | As a cashier, I want to complete cash sale so that I finalize transaction. | -  إدخال مبلغ مدفوع -  حساب الباقي -  لو < الإجمالي: منع (أو سماح حسب السياسة) -  فاتورة + تحديث مخزون | Must Have |
| EP3-07 | As a cashier, I want to complete credit sale so that I sell on account. | -  اختيار عميل -  ربط الفاتورة بملف العميل -  الدين يزيد نفس القيمة | Must Have |
| EP3-08 | As a cashier, I want keyboard shortcuts so that I work faster. | -  F1: بحث -  F2: دفع -  Esc: مسح السلة/إغلاق نافذة -  تعمل دومًا | Must Have |

***

#### **Epic 4: Invoice Generation**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP4-01 | As a shop owner, I want to generate PDF invoice after sale so that I keep record and share it. | -  فاتورة فور الإتمام -  رقم فريد، تاريخ، وقت -  تفاصيل المحل والمنتجات والإجمالي -  حفظ/مشاركة محلي | Must Have |
| EP4-02 | As a shop owner, I want invoice preview so that I verify content. | -  معاينة قبل حفظ/مشاركة -  بيانات واضحة -  يمكن الرجوع بدون مشاركة | Must Have |
| EP4-03 | As a shop owner, I want to share invoice via WhatsApp so that I send it easily. | -  زر مشاركة -  ملف PDF صحيح التنسيق -  مشاركة بدون تقطيع | Must Have |

***

#### **Epic 5: Customers & Debts**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP5-01 | As a shop owner, I want to add customer (name/phone) so that I link credit sales. | -  الحفظ -  يظهر في القائمة -  يمكن استخدامه في بيع آجل | Must Have |
| EP5-02 | As a shop owner, I want to see each customer balance so that I know what they owe. | -  رصيد واضح -  يتحدث مع بيع/سداد -  صفر أو "no debt" غير مديون | Must Have |
| EP5-03 | As a shop owner, I want to record payment from customer so that I reduce debt. | -  إدخال مبلغ سداد -  الدين يقل -  سجل تحرّك في ملف العميل -  لا > الدين إلا لو سماح | Must Have |
| EP5-04 | As a shop owner, I want to view purchase history so that I review transactions. | -  فواتير سابقة -  يمكن فتح أي فاتورة -  تواريخ وقيم واضحة | Must Have |

***

#### **Epic 6: Alerts**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP6-01 | As a shop owner, I want to see expired products so that I stop selling them. | -  قسم "منتهية" -  أحمر -  مرتب تاريخًا | Must Have |
| EP6-02 | As a shop owner, I want to see soon-to-expire so that I act before loss. | -  أقل 30 يوم -  أصفر -  الأقرب أولًا | Must Have |
| EP6-03 | As a shop owner, I want to see low-stock products so that I reorder. | -  قسم "مخزون منخفض" -  العدد دقيق -  منتج + زر "تعديل" | Must Have |
| EP6-04 | As a shop owner, I want alert badge so that I know status quickly. | -  رقم في Sidebar/TopBar -  يتحدث مع كل تنبيه | Must Have |

***

#### **Epic 7: Dashboard**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP7-01 | As a shop owner, I want to see today sales total so that I know performance. | -  رقم واضح -  يتحدث مع كل بيع -  لا يحتاج فتح تقرير | Must Have |
| EP7-02 | As a shop owner, I want to see product count so that I know inventory size. | -  عدد الأصناف -  يتغير مع إضافة/حذف | Must Have |
| EP7-03 | As a shop owner, I want to see debt total so that I follow collections. | -  إجمالي ديون -  يتغير مع كل سداد/بيع آجل | Must Have |
| EP7-04 | As a shop owner, I want to see recent sales so that I review activity. | -  5–10 فواتير الأخيرة -  وقت/قيمة/عميل -  فتح فاتورة ممكن | Must Have |
| EP7-05 | As a shop owner, I want to see 7-day sales chart so that I understand trends. | -  Chart واضح -  أيام/قيم صحيحة | Should Have |

***

#### **Epic 8: Reports**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP8-01 | As a shop owner, I want daily sales report so that I review daily. | -  إجمالي، عدد فواتير، متوسط | Must Have |
| EP8-02 | As a shop owner, I want period filter (day/week/month) so that I compare. | -  فلترات -  تغيير يعكس البيانات فورًا | Must Have |
| EP8-03 | As a shop owner, I want top-selling products list so that I reorder. | -  5 منتجات -  مرتب مبيعًا -  عدد/قيمة | Should Have |
| EP8-04 | As a shop owner, I want invoice table so that I inspect transactions. | -  جدول فواتير -  يمكن فتح أي سطر | Must Have |

***

#### **Epic 9: Settings & Store Info**

| Story ID | User Story | AC | Priority |
|---------|-----------|-----|----------|
| EP9-01 | As a shop owner, I want to store shop name so that it appears on invoices/headers. | -  يظهر في الهيدر/فاتورة -  يمكن تعديله -  لا يكسر التصميم | Must Have |
| EP9-02 | As a shop owner, I want to store address/phone so that customers can contact. | -  يظهر في فاتورة/هيدر -  يمكن تعديله بسهولة | Must Have |

***