# عالم العلوم | Science World – V12

إصدار تحديث بصري وتجربة استخدام أولية. راجع `RELEASE_NOTES_V12_AR.md` و`docs/design/DESIGN_SYSTEM_AR.md` لمعرفة ما تغير وما يحتاج إلى اختبار.

# عالم العلوم | Science World

تطبيق Flutter (Android) تعليمي لطلاب المنهاج السوري.

## الميزات
- منصة تعليمية شاملة: مكتبة، بنك أسئلة، امتحانات، تقييمات.
- دعم RTL ونطاقين (عربي/إنجليزي).
- اتصال بـ Supabase للمحتوى السحابي.
- نظام اشتراكي مميز مع تفعيل أكواد ودعم شام كاش يدويًا.
- مؤثرات صوتية وتخزين محلي للعمل offline.
- مساعد ذكاء اصطناعي تعليمي (الصفوف التاسع والعاشر الحادي عشر العلمي والبكالوريا العلمي).

## المحتوى
1. [المتطلبات](#المتطلبات)
2. [installs Flutter](#تثبيت-flutter)
3. [Supabase Setup](#إعداد-supabase)
4. [ال Functions](# deploying-supabase-functions)
5. [ال_supplies](#ال依赖项)
6. [Run](#run)
7. [Tests](#Tests)
8. [APK Build](#APK-Build)
9. [Codemagic](#Codemagic)
10. [الIssue](#open-issues)

## المتطلبات
- Flutter SDK ≥ 3.3.0
- Dart SDK ≥ 3.3.0
- Android SDK ≥ 34
- حساب Supabase
- مفتاح OpenAI (لمساعد الذكاء الاصطناعي)

## تثبيت Flutter
1. حمّل Flutter SDK من [flutter.dev](https://flutter.dev).
2. أضف Flutter إلى PATH.
3. شغّل `flutter doctor` للتأكد.

## إعداد Supabase
1. أنشئ Supabase Project.
2. نفّذ السكربتات التالية في SQL Editor:
   - `supabase/schema.sql`
   - `supabase/questions_schema.sql`
   - `supabase/subscriptions_schema.sql`
3. نفّذ Functions:
   - `supabase/functions/activate_subscription.sql`
   - `supabase/functions/get_questions.sql`
   - `supabase/functions/ai-chat/index.js`
4. أضف Secrets: `OPENAI_API_KEY`

## deploying Supabase Functions
استخدم Supabase CLI:
```bash
supabase functions deploy ai-chat
supabase functions deploy activate_subscription
supabase functions deploy get_questions
```

## Dependencies
```bash
flutter pub get
```

## Run
```bash
flutter run
```

## Tests
```bash
flutter test
```

## APK Build
```bash
# Debug
flutter build apk --debug

# Release (يتطلب signing config)
flutter build apk --release
```

## Codemagic
1. ربط المستودع بـ Codemagic.
2. يستخدم الملف `codemagic.yaml` للبناء التلقائي.
3. APK الناتج يُخزن في `build/app/outputs/flutter-apk/`.

## open issues
- الدفع عبر شام كاش يدوي حاليًا.
- أكواد التفعيل تُissued من Supabase.
- مفتاح OpenAI مخزّن في Supabase Secrets.
- لا توجد مفاتيح سرية في الكود.
- لا يُستخدم `service_role` في Flutter.