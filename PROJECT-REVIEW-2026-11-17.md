# مراجعة ENote الشاملة — 17 نوفمبر 2026

**القرار: غير جاهز للنشر أو تسليم بيانات مستخدمين حقيقية.** الويب يُبنى ويعمل في الحالات العادية، لكن سلامة البيانات وهوية ملف Android وحدود خدمة AI واختبارات الإصدار بها مشاكل مؤكدة. نجاح التصميم أو البناء لا يثبت جاهزية التطبيق للإنتاج.

المراجعة على commit `ba73ea82326f66e6c46b7832c57db95f0cfcb3ea`، وتشمل Flutter تحت `lib/`، تطبيق React عند `/app`، الـ landing page، API، Android، الاختبارات وGitHub Actions. لم تُعدّل وظائف المنتج أثناء هذه المراجعة. التغييرات هي أدوات فحص محلية وتوثيق النتائج وتصحيح حالة التقرير القديم.

## الأدلة وحدودها

| الفحص | النتيجة الفعلية |
|---|---|
| `pnpm build` | نجح. الحزمة الرئيسية 320.47 kB / gzip 111.08 kB، وحزمة الرسوم المحملة بشكل منفصل 427.05 kB / gzip 115.27 kB. ليس قياسًا لأداء جهاز حقيقي. |
| `node --experimental-strip-types --test test/ui-utils.test.mjs` | 4 اختبارات نجحت. |
| `dart --enable-asserts test/native_validators_smoke.dart` | 10 فحوصات نجحت، باستخدام Dart 3.13.7. |
| `dart --enable-asserts test/run_all_tests.dart` | **فشل** عند `test/ai_assistant_test.dart:201`. لم يصل إلى نهاية كل المجموعات. |
| `python scripts/check_dart_syntax.py` | 92 ملف Dart في `lib/` والاختبارات: لا أخطاء صياغة. هذا ليس `flutter analyze`. |
| الويب: 11 شاشة × لغتين × مظهرين × عرضين | 88 حالة عرض عند 390 و1440px، دون تمدد أفقي أو أزرار ظاهرة بلا أسماء حسب الفحص المستخدم. بيانات اصطناعية في سياق متصفح مستقل. |
| الـ landing: لغتان × 4 عروض | 8 حالات عند 320 و390 و820 و1440px، دون تمدد أفقي. |
| معاينة الـ landing | نجح حفظ الملاحظة داخل المعاينة، إضافة وإكمال مهمة، بدء وإعادة المؤقت، وظهور المحتوى مع تقليل الحركة. لا يثبت ذلك دقة كل وظائف Flutter. |
| axe: الويب | 11 فحصًا في English/light/1440؛ مخالفات في 5 شاشات: الرئيسية، المؤقت، المكتبة، المساعد، المكافآت. |
| axe: الـ landing | مخالفة `aria-prohibited-attr` في اللغتين. الفحص الآلي لا يثبت المطابقة الكاملة للوصول. |
| `scripts/check-web.cjs` | نجح تدفقا التحقق من المهمة والحذف/التراجع، ثم توقف بسبب selector يطابق عنوان المؤقت المخفي وعنوان المخطط. هذا خلل في الاختبار، وليس دليلًا على ظهور شاشتين للمستخدم. |
| `pnpm audit --prod --json` | صفر advisories معروفة في 47 dependency مفحوصة وقت المراجعة. لا يشمل ذلك أمن المنطق أو Flutter أو dependencies التطوير. |
| API باختبار upstream وهمي | طلب بلا مصادقة، ثم طلب ببيانات دور غير صالح وحوالي 300 kB، وصلا للـ upstream الوهمي وأعادا 200. **لم تُرسل مدخلات إلى خدمة خارجية.** |
| هوية APK باستخدام `aapt dump badging` | `com.simplemobiletools.notes.pro`، الاسم Notes، الإصدار 6.5.4/code 75، target SDK 29. لا ملفات Flutter في الأرشيف. |

**لم يتم التحقق:** `flutter pub get` أو `flutter analyze` أو widget/integration tests أو بناء ENote Android/iOS أو تثبيت APK أو أداء وهزاز وصوت وتنبيهات على جهاز حقيقي. Flutter غير موجود في PATH؛ المسار `C:/Users/Zaro/develop/flutter` يحتوي `.git` فقط، وليس SDK صالحًا. لا يوجد `pubspec.lock` في checkout. لا توجد مشاريع iOS/Windows/macOS هنا. لا توجد موافقة إصدار أو درجة جودة رقمية للنسخة الأصلية.

الـ APK لم يُشغّل أثناء المراجعة. لم تُنشر الصفحة، ولم تُعدّل إعدادات الخدمات أو بيانات مستخدم حقيقية. لقطات المتصفح تخص React فقط.

## المشاكل حسب الأولوية

22 نتيجة: **2 حرجة P0، 11 عالية P1، 9 متوسطة P2**. P0 يمنع التوزيع/إدخال بيانات حقيقية؛ P1 يمنع إصدارًا عامًا موثوقًا؛ P2 مطلوب للجودة واكتمال المتطلبات. أحكام الأداء أو الوصول الأصلية المبنية على الكود موضحة باعتبارها تحتاج تحققًا على الجهاز.

### A01 — P0: زر تنزيل ENote يوزّع تطبيقًا آخر

**الدليل:** `Landing.tsx:797` يربط `public/downloads/ENote-v1.0.0.apk`. فحص `aapt` أكد حزمة `com.simplemobiletools.notes.pro` واسم Notes وإصدار 6.5.4. الملفان `ENote.apk` و`ENote-v1.0.0.apk` متطابقان: 6,040,651 بايت؛ SHA-256:

`c8bd7b0fb85c2084e861ebd2542fcf28c7a66f68f57f005fbd973fd6bf854981`

كذلك `scripts/package-release-apk.py:1` يكتب manifest نصيًا وDEX/موارد تجريبية داخل ZIP ويسميه release APK؛ هذا ليس بديلًا لبناء Flutter. لا يوجد دليل أن الملفات الموجودة حاليًا نتجت من هذا السكربت؛ الملفات الحالية تنتمي لتطبيق مختلف، وهي مشكلة منفصلة مؤكدة.

**الأثر:** المستخدم يحصل على منتج آخر مع وعد أنه ENote. **الإصلاح:** إيقاف رابط التحميل حتى يتوفر بناء من هذا المصدر، ثم التحقق من package ID واسم التطبيق والإصدار والتوقيع ووجود محرك/أصول Flutter وإرفاق hash ومصدر commit. لا يكفي فحص وجود الملف أو امتداده. هذه المراجعة لم تحذف الملفات أو تعطّل الروابط.

### A02 — P0: التخزين الأصلي ليس SQLite/Drift دائمًا

**الدليل:** `lib/data/local/database/app_database.dart:67` يعرّف `AppDatabase implements IAppDatabase` مع Lists/Maps عند السطر 73 وما بعده، وmigration بلا تنفيذ SQL عند 91. لا يُفتح ملف قاعدة بيانات ولا اتصال Drift. provider الحقيقي يستخدم هذا الكلاس في `lib/features/common/providers/study_flow_state_provider.dart:23`. اسم `DriftStudyFlowRepository` لا يضيف persistence. إعدادات المؤقت والدقائق أيضًا حقول ذاكرة في `lib/data/repositories/drift_study_flow_repository.dart:15`. المكتبة والمكافآت state في الذاكرة مع بيانات جاهزة في `materials_provider.dart:35` و`rewards_provider.dart:12`.

**الأثر:** فقد الملاحظات والمهام والملف والأهداف والتقدم بعد موت العملية، مع بقاء onboarding flag في SharedPreferences في حالات النجاح. قد يدخل مستخدم عائد إلى التطبيق من دون ملفه أو محتواه. **الإصلاح:** قاعدة بيانات فعلية، migrations واختبارات إعادة فتح الملف/العملية، مع حفظ كل حالة غير قابلة لإعادة البناء. فصل بيانات العرض عن الحالة الحقيقية.

### A03 — P1: AI proxy بلا حدود تطبيقية واضحة أو حماية إساءة الاستخدام

**الدليل:** `api/ai.ts:18` و`:39` و`:53`: CORS عام، تمرير messages/model من العميل بلا schema أو حد حجم أو rate limit أو سياسة سماح واضحة، وfetch بلا timeout. الاختبار المحلي قبل 300,074 بايت ودور `unknown` بلا authentication. `aiService.ts:100` و`:131` و`:154` ينقل prompt/system إلى URL في fallback GET. لا توجد واجهة خصوصية مرتبطة هنا تشرح هذه النقلات.

**الأثر:** إساءة استخدام endpoint، عمل غير محدود داخل حدود المنصة، واحتمال ظهور محتوى الملاحظات في سجلات URLs. CORS ليس مصادقة ولا يمنع عملاء الخادم. **الإصلاح:** schema وأحجام وعدد رسائل/models مسموحة، مهلة وإلغاء، quota/rate limit وسياسة وصول مناسبة للمنتج، POST فقط للمحتوى، وإفصاح واضح قبل إرسال المحتوى الخارجي. حدود منصة الاستضافة الفعلية لم تُفحص.

### A04 — P1: بيانات محلية غير سليمة تنتج صفحة ويب بيضاء

**الدليل:** `studyflow.tsx:110` يقبل JSON ويدمجه سطحيًا دون تحقق أنواع. اختُبر fixture مستقل `{profile:{...}, tasks:null}`: ثلاثة أخطاء `Cannot read properties of null (reading 'filter')` ومحتوى body فارغ.

**الإصلاح:** decode/schema version وvalidation/migration لكل collection، الاحتفاظ بالنسخة المتضررة قبل الاستعادة، وواجهة recovery/export بدل استبدالها بصمت أو انهيار الصفحة. يحتاج اختبارًا لبيانات قديمة وحقول غائبة وأنواع خاطئة.

### A05 — P1: التنبيهات الأصلية لا تطلب إذن النظام ولا تُجدول في OS

**الدليل:** `lib/features/notifications/services/notification_service.dart:222` يمنح granted افتراضيًا خارج الويب. `:347` يستخدم Dart Timer، و`:251` ينشئ الإشعار داخليًا؛ إرسال النظام موجود فقط للويب. singleton يبدأ بـ `InMemoryNotificationStorage` عند `:80`، وprovider لا يربط التخزين الدائم/initialization. Manifest permission وحده ليس طلب إذن أو جدولة.

**الأثر:** قد تظهر الإعدادات كأن الإذن مُنح لكن المستخدم لا يتلقى تنبيهًا أصليًا، وتتوقف مؤقتات Dart عند إنهاء العملية. **الإصلاح:** Gateway لنظام التنبيهات، طلب الإذن الحقيقي، حفظ reminder intent، reconcile عند العودة/التشغيل وجدولة أصلية، واختبار الخلفية وإعادة التشغيل على Android حقيقي.

### A06 — P1: الإنجليزية المطلوبة غير منفذة في Flutter

**الدليل:** `lib/main.dart:66` يثبت `Locale('ar')`. وجود en في `supportedLocales` يترجم عناصر Material القياسية فقط؛ نصوص الشاشات عربية مباشرة ولا ملفات ARB/gen-l10n أو اختيار لغة فعلي.

**الإصلاح:** ARB وAppLocalizations ومزود locale محفوظ، استبدال نصوص الشاشات/الأخطاء/التنبيهات، وفحص LTR/RTL دون ترجمة محتوى المستخدم. دعم صفحة الويب للغتين لا يثبت دعم Flutter.

### A07 — P1: release build موقّع بمفتاح debug

**الدليل:** `android/app/build.gradle:53` يستخدم `signingConfig signingConfigs.debug` في release. هذا إعداد توزيع تجريبي، وليس إعداد تسليم متجر موثوقًا.

**الإصلاح:** إعداد upload/release signing بأسرار خارج المستودع، Play App Signing حيث ينطبق، وفحص بصمة الشهادة من artifact النهائي. [دليل Flutter الرسمي](https://docs.flutter.dev/deployment/android)، [توقيع Android](https://developer.android.com/studio/publish/app-signing).

### A08 — P1: target SDK لا يحقق متطلبات Google Play الحالية

**الدليل:** `android/app/build.gradle:46` يستهدف API 34. للهواتف، Google Play يطلب API 36 للتطبيقات الجديدة والتحديثات منذ 31 أغسطس 2026؛ مهلة التمديد المذكورة انتهت 1 نوفمبر 2026. هذه نتيجة تخص النشر على Play، لا صلاحية sideload تلقائيًا. الملف الغريب الذي يُوزَّع حاليًا يستهدف 29 أصلًا، كما في A01.

**الإصلاح:** ترقية Flutter/Gradle/AGP وcompile/target ضمن مجموعة متوافقة، وفحص سلوك Android الحديث وحجم صفحات الذاكرة والمكتبات الأصلية فعليًا. [متطلبات Google Play الرسمية](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en).

### A09 — P1: بوابات الاختبار والإصدار لا تثبت الادعاءات الحالية

**الدليل:** `test/run_all_tests.dart:25` يتوقف عند assertion فاشل في `test/ai_assistant_test.dart:201`. اختبارات persistence/schema تستخدم كلاسات بديلة داخل الاختبارات (`test/profile_persistence_test.dart:4`، `test/database_migration_test.dart:8`) فلا تختبر تخزين التطبيق أو migration حقيقيًا. `test/flip_clock_widget_test.dart:3` يختبر حسابات معاد تعريفها، وليس widget rendering. runner يطبع ادعاء النجاح في النهاية ولا يستدعي اختبارات Flutter الجديدة. `scripts/check-web.cjs:63` يطابق heading مخفيًا وظاهرًا. `.github/workflows/ci.yml:42` يتحقق من وجود APK فقط؛ `build-apk.yml:49` يبني دون gates لـ analyze/tests/codegen. checkout يفرض main عند `:24`. لا `pubspec.lock`، وFlutter CI مثبت على عائلة `3.22.x` لا إصدار patch محدد.

**الإصلاح:** اختبارات على المصدر الحقيقي، assertion-enabled للـ standalone وتسجيل آلي في flutter_test، إصلاح selectors للعنصر الظاهر، format/analyze/codegen/tests قبل الإصدار، artifact identity/signature gate، SDK/lock واضحان ومصدر commit مضبوط. لا تعتمد على تقرير نجاح مكتوب يدويًا. تقرير 16 نوفمبر تم وسمه superseded.

### A10 — P1: عمليات تغيير الحالة تتجاهل فشل الحفظ ومهام async تتجاوز دورة الحياة

**الدليل:** `study_flow_state_provider.dart:87` و`:129` و`:172` و`:217` تستدعي كتابة المستودع دون await داخل map ثم تنشر النجاح. constructors تطلق `_load()` دون حالة تحميل/فشل. `pomodoro_screen.dart:159` ينتظر alarm ثم يستخدم ref عند `:162` قبل mounted guard عند `:166`. المساعد في `ai_assistant_provider.dart:87` وما بعده ينتظر ثم يكتب state بلا حراسة dispose أو معالجة فشل.

**الأثر:** UI ناجحة مع كتابة فاشلة عند توصيل قاعدة فعلية، سباقات تحميل/تعديل، أو وصول لكائن انتهت حياته. **الإصلاح:** persist-before-publish ومسار أخطاء واضح، حراسة بعد await قبل ref/context، ملكية وإلغاء للعمليات، واختبارات فشل/تأخير/dispose. لا يلزم تغيير Riverpod major لمجرد الامتثال لاسم skill؛ عالج الخلل ضمن الإصدارات المختارة أو خطط ترقية مختبرة.

### A11 — P1: «مسح جميع البيانات» لا يمسح كل الحالة

**الدليل:** `lib/features/settings/screens/settings_screen.dart:47` يمسح repository/preferences ويعيد مجموعة providers فقط. لا يعيد materials/rewards/AI chat ولا يمسح singleton الخاص بالتنبيهات أو يلغي جدولته. `materials_provider.dart:146` و`rewards_provider.dart:75` يملكان state مستقلًا.

**الأثر:** بعد reset قد يبقى محتوى أو رصيد أو تنبيه للحساب/الجلسة السابقة داخل نفس العملية. **الإصلاح:** reset منسق لكل الملاك والمخازن والمؤقتات، مع اختبار يملأ كل ميزة ثم يعيد التهيئة ويفحص عدم التسريب إلى مستخدم جديد.

### A12 — P1: metadata تعرض تقييمات ومنصات مدعومة دون دليل

**الدليل:** `index.html:80` يعلن AggregateRating = 4.9 وعدد 1250 مراجعة؛ لا مصدر مراجعات مربوط بالمشروع. `:69` يعلن Android/Web/iOS/Windows/macOS بينما لا مشاريع المنصات الثلاث الأخيرة أو دليل بناء لها هنا. downloadUrl عند `:87` يشير إلى ملف A01.

**الإصلاح:** حذف/تصحيح الادعاءات غير المثبتة وربط التقييمات بمصدر فعلي عندما توجد، وحصر المنصات والإصدارات وفق ما جرى بناؤه واختباره. لا تنقل بيانات تجريبية إلى structured data كحقائق.

### A13 — P2: الصفحة تتجاوز الـ hero تلقائيًا عند أول فتح

**الدليل:** `Landing.tsx:665` ينفذ `activeTab.scrollIntoView({behavior:'smooth',...})` في effect أول scene أيضًا. في سياق جديد عند 1440px، scrollY أصبح **3975** بعد التحميل؛ مع reduced motion **3988**. العودة لأعلى أظهرت hero سليمًا؛ ليست المشكلة غياب محتواه.

**الإصلاح:** لا تمرر الصفحة إلى tablist عند mount؛ حرّك الشريط أفقيًا بعد تفاعل المستخدم فقط، واحترم reduced motion. اختبر أن أول زيارة تبدأ بالعنوان والدعوة الرئيسية دون قفز.

### A14 — P2: تباين نصوص غير كافٍ في الويب

**الدليل:** axe في English/light/1440: المكتبة 2.06–2.53:1 لنصوص الاكتمال، المساعد 3.52:1 لبعض badges، والمكافآت وصولًا إلى 1.7:1 للنقاط. أمثلة المصدر `redesign.css:366`، `:523` و`studyflow.tsx` ضمن المواد/المساعد/المكافآت. الشفافية على البطاقة المقفولة تقلل تباين النص أيضًا.

**الإصلاح:** ألوان دلالية محسوبة على الخلفية المركبة، 4.5:1 للنص الصغير، وعدم تعتيم النص كاملًا للتمييز بين حالة مقفولة ومكتملة. إعادة الفحص في كل themes. هذه ratios آلية من الحالات المفحوصة وليست شهادة لكل الشاشات.

### A15 — P2: أخطاء ARIA في الـ landing والمؤقت والرسوم

**الدليل:** `Landing.tsx:879` يضع aria-label على div عام دون role يدعم التسمية. `FlipClock.tsx:239` و`:255` تكرر نفس المشكلة. `StatisticsCharts.tsx:14` يخفي chart بـ aria-hidden مع وجود محتوى قابل للتركيز أنشأته مكتبة الرسوم. المخالفات ظهرت فعليًا في axe.

**الإصلاح:** native semantics أو role ملائم، timer واحد باسم وقيمة مفهومين مع إخفاء زخارف الأرقام، وإما جعل الرسم غير تفاعلي بالكامل/غير قابل للتركيز مع بديله النصي، أو إظهاره للـ accessibility tree بصورة صحيحة. اختبر لوحة المفاتيح وقارئ الشاشة.

### A16 — P2: اختيارات onboarding لا تؤثر بعد إنهائه

**الدليل:** `onboarding_screen.dart:30`–`:32` يخزن الهدف اليومي والتوقيت المفضل والتذكير في widget state فقط. `_handleFinish` عند `:116` يحفظ UserProfile(name, grade) وflag؛ لا يحفظ الاختيارات الأخرى ولا ينشئ تذكيرًا.

**الإصلاح:** حفظ اختيارات حقيقية وربطها بالهدف والتذكير والتفضيلات، أو عدم عرض إعدادات غير فعالة. اختبار أن تغيير كل خيار يبقى بعد إعادة التشغيل ويغيّر السلوك المقصود.

### A17 — P2: ثغرات أصلية في تقليل الحركة ودلالات الاختيار وتكبير النص

**الدليل من المصدر:** `flip_clock_widget.dart:376` و`:385` يكرران animation بلا قراءة reduced-motion هنا؛ digit flip كذلك يبدأ عند كل رقم متغير. `grade_card_selector.dart:55` يفرض عمودين ونسبة أبعاد ثابتة، و`:65` يستخدم GestureDetector دون button/selected semantics. grid النصوص عند أكبر تكبير يحتاج إثباتًا على الجهاز؛ لم يُشاهد overflow أصلي فعلي في هذه الجولة.

**الإصلاح:** end-state فوري/هادئ لتقليل الحركة، إيقاف ticks/animations خارج المشهد، Semantics للاختيار، وخلايا تنمو مع النص مع فحص 320px و200% وأكبر إعداد نظام. لا تدّع دعم TalkBack أو WCAG من قراءة الكود وحدها.

### A18 — P1: المساعد الأصلي قوالب وقواعد كلمات وليس خدمة LLM، وتصنيف النية به خطأ مثبت

**الدليل:** `lib/features/ai_assistant/services/ai_assistant_service.dart:303` يصنف النص بكلمات ويرجع قوالب/بنوك أسئلة ثابتة، ولا يوجد network adapter لهذا المسار. قد يكون مساعدًا محليًا مقصودًا، لكنه لا يطابق وعد «ذكاء اصطناعي حقيقي» المنشور. كلمة `امتحان` في فرع quiz عند `:329` تلتقط `قلق الامتحانات` قبل فرع القلق عند `:410`؛ لهذا فشل الاختبار `ai_assistant_test.dart:201`.

**الإصلاح:** قرار منتج واضح بين مساعد محلي معلَن وخدمة توليد حقيقية عبر boundary آمنة، أولوية نوايا أكثر تحديدًا قبل الكلمات العامة، اختبارات غموض اللغة، وحالات فشل/fallback معلَنة. وجود API الويب لا يوصله تلقائيًا بـ Flutter.

### A19 — P2: Preferences تبلغ عن نجاح حفظ لم يحدث

**الدليل:** `preferences_service.dart:46` و`:77` يحدّثان cache ثم catch صامتة و`return true` حتى عند غياب plugin أو فشل الكتابة. `clearPreferences` يمتص الخطأ أيضًا. في `main.dart:31` أخطاء async تُطبع في debug فقط؛ release لا يملك crash sink محليًا موثقًا.

**الإصلاح:** نتيجة صريحة من durable write، عرض فشل قابل للاستعادة، وعدم اعتبار fallback الذاكرة نجاحًا دائمًا. احتفظ بخطأ منقح من البيانات الشخصية في sink محلي bounded؛ لا تضف telemetry خارجية دون حاجة/قرار منتج.

### A20 — P2: قراءة العادات تستبدل history التي عُدلت

**الدليل:** `lib/features/common/providers/study_flow_state_provider.dart:210` يرسل history محدثة إلى `updateHabit`. في `lib/data/local/database/app_database.dart:220` تقرأ `getHabits` من `_habitCompletions` وتستبدل history، بينما `updateHabit` عند `:240` يغير `_habits` فقط. `toggleHabitCompletion` الذي يغيّر الخريطة لا يستخدمه هذا المسار.

**الإصلاح:** مصدر واحد للتكملة اليومية، ومسار كتابة وقراءة متفقان، واختبار toggle → إعادة جلب المستودع → نفس النتيجة. هذه نتيجة مسار كود، غير معروضة كتجربة Flutter runtime.

### A21 — P2: التحقق من النماذج مرتبط بنص label ولا يقبل الأرقام العربية

**الدليل:** `lib/core/widgets/app_text_field.dart:28` يقرر validation بمقارنة كلمات عربية في label. تغيير الترجمة أو عنوان الحقل يسقط القاعدة. `lib/core/utils/app_validators.dart:6` و`:13` يقرآن int/HH:mm دون normalize لأرقام مثل ١٢ و٠٩:٣٠. بعض حقول المواد الجديدة لها labels غير موجودة في هذه الخريطة.

**الإصلاح:** validators صريحة مرتبطة بنوع الحقل، رسائل localized، وتطبيع الأرقام والفواصل قبل parse مع تخزين قيم canonical. اختبارات عربية/لاتينية وحدود وتواريخ غير صالحة.

### A22 — P2: رابط اللغة الإنجليزية المعلن في SEO لا يفتح الإنجليزية

**الدليل:** `index.html:16` يعلن `?lang=en`. initial state في `Landing.tsx:196` يقرأ localStorage فقط. في سياق جديد، زيارة `/?lang=en` أعادت `html.lang=ar`. metadata الخاصة بـ OG/description تبقى عربية أيضًا.

**الإصلاح:** URL حقيقي لكل لغة أو query مدعوم ومختبَر، ثم تفضيل صريح URL → اختيار محفوظ → fallback، وتحديث العنوان/metadata/hreflang بما يطابق المحتوى الفعلي. لا يعتمد crawler أو رابط المشاركة على localStorage.

## التقييم البصري والتقني

- الهوية الكحلية/الزرقاء/البرتقالية متسقة مع الأيقونة، وعرض المنتج واضح عند العودة لأعلى الصفحة. ازدحام أزرار الـ hero بالعربي وتزاحم strip بعد إضافة مزايا كثيرة يستحقان تبسيطًا بعد حل A01/A13. الصورة الأولى الملتقطة قبل اكتمال/إعادة مزامنة الحركة لم تُستخدم لإثبات غياب hero؛ لقطة `landing-desktop-top.png` هي المرجع الصحيح.
- Workspace حافظ على تنقل واضح وتخطيط متكيف، و88 حالة عرض نجحت في قياس عرض الصفحة. هذا لا يغطي كل modal/long-content/200% text أو إيماءات لمس فعلية.
- lazy loading للتطبيق والرسوم مفيد. محتوى الـ landing أصبح ملفًا كبيرًا يجمع التسويق والتجارب والـ AI والحركة؛ تقسيمه لحدود واضحة سيقلل مخاطر التعديل ويجعل المراجعة أسهل، وليس سببًا لإعادة كتابة المنتج.
- GSAP يستخدم scoped useGSAP وmatchMedia وتنظيف event listeners، وهي نقاط جيدة. لكن `Landing.tsx:391`–`:430` يكرر floating animations بلا pause صريح عند خروجها من viewport، و`:580`/`:604` ينشئ tweens في mousemove بدل quickTo. تحسينات محتملة تحتاج profiling؛ **لم نقس FPS أو نحكم بوجود memory leak**. handler المعاينة الثاني عند `:654` يحتاج احترام reduced motion أيضًا؛ وجود media guard في الحركة الرئيسية لا يغطي كل animation تلقائيًا.
- Flutter فيه SafeArea، Material buttons، branch state retention، validation وUndo، لكن غياب تشغيله يمنع إصدار حكم بصري أو أداء نهائي. خط Cairo يأتي من google_fonts ولم يُضف font asset إلى pubspec؛ يُراجع أول تشغيل دون إنترنت بدل افتراض جاهزية الخط offline.

## ترتيب الإصلاح المقترح

1. **حماية الثقة والبيانات:** وقف تنزيل الملف غير المطابق، إزالة وعود الإصدار والتقييمات غير المثبتة، ثم تخزين دائم حقيقي مع اختبارات قتل/إعادة فتح العملية واستعادة البيانات.
2. **بناء قابل للتحقق:** SDK/lock، اختبارات على المصدر الحقيقي، CI gates، target/signing، artifact identity/checksum/provenance. لا نشر قبل نجاح هذه المجموعة.
3. **اكتمال الوظائف:** الإشعارات الأصلية، reset شامل، await/error paths، onboarding، مسار المساعد وحدود خصوصيته، ثم الإنجليزية الأصلية.
4. **مراجعة الوصول والحركة:** إصلاح تباين وARIA الويب، قفزة أول الصفحة، RTL وdeep links، ثم matrix أصلية للخط الكبير والـ themes وقارئ الشاشة وتقليل الحركة.
5. **Sign-off على جهاز فعلي:** صوت/هزاز، lifecycle/background، تنبيهات، فشل تخزين، تحديث فوق إصدار قديم. النتيجة المطلوبة دليل مُعاد إنتاجه لكل blocker، لا نسبة نجاح عامة.

## أدوات وأدلة إعادة الفحص

- `scripts/audit-project.cjs`: layouts ومعاينات landing وaxe؛ التقرير `screenshots/audit-2026-11-17/browser-report.json`. لقطة onboarding الأولية سجلت التحميل المبكر؛ فحص workspace المنفصل أدناه هو الدليل الحالي عليه.
- `scripts/audit-workspace.cjs`: 88 حالة عرض، 11 axe scan، وتجربة localStorage غير السليم؛ `workspace-report.json` في نفس المجلد.
- `scripts/audit-motion.cjs`: أول scroll، query locale وتقليل الحركة؛ `motion-report.json` ولقطات hero.
- `scripts/audit-ai-proxy.cjs`: handler الحقيقي مع upstream وهمي بلا نقل شبكة.
- `scripts/check-web.cjs`: الاختبار السابق محفوظ كما هو، وفشله موثق دون تغيير التوقعات لإخفائه.
- الأدوات تعتمد على Playwright وChromium الموجودين محليًا؛ ليست CI محمولة جاهزة. مجلد screenshots مستبعد في Git؛ الأدلة متاحة في هذا workspace.

## الـ skills المستخدمة وحدود تطبيقها

استُخدم `flutter-production-audit` لتصنيف مخاطر الإصدار، و`building-flutter-apps` و`flutter-conventions-index` كمرجع معماري، مع مبادئ persistence-drift، async-safety، app-startup-and-bootstrap، local-notifications-scheduler، i18n-rtl-l10n، accessibility-as-code، adaptive-layout، forms-and-input، motion-and-haptics، flutter-performance، dependency-hygiene، error-handling-typed-results، ci-pipeline-and-gates، design-review-workflow. استُخدم Impeccable audit للويب وnative كلٌّ في نطاقه، وUI UX Pro Max، وWeb Interface Guidelines، وVercel React Best Practices، وGSAP React/Performance للحركة.

هذه مراجع فحص وليست شهادة أن كل scanner تابع لها شُغّل أو أن كل قواعدها متحققة. عند تعارض تفضيلات framework/storage بين skills، يُحكَم باحتياج المنتج والمصدر الحالي؛ لم تُعتبر ترقية Riverpod أو استبدال Drift بـ Hive إصلاحًا تلقائيًا. لم تُستخدم skills المستندات والعروض وPets والجداول أو installers لعدم انطباقها على مهمة مراجعة الكود. لا ادعاء باستخدام كل skill المتاحة شكليًا.

مرجع إرشادات الويب الذي جرى التحقق منه: [Web Interface Guidelines](https://github.com/vercel-labs/web-interface-guidelines/blob/main/command.md). مرجع persistence: [Drift](https://drift.simonbinder.eu/). صلاحية النشر النهائي على متجر أو الامتثال الكامل للوصول **غير موقّع عليها** في هذه الجولة.
