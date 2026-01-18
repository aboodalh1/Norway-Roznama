# ملاحظات مهمة حول Firebase Configuration

## ⚠️ تحذير: يجب تحديث Firebase Configuration بعد تغيير Package Name

بعد تغيير Package Name من `com.example.norway_roznama_new_project` إلى `com.islamskmojammaa.roznama`، يجب تحديث إعدادات Firebase.

## الخطوات المطلوبة:

### 1. إضافة تطبيق Android جديد في Firebase Console

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر المشروع: `norway-roznama`
3. اضغط على إعدادات المشروع (⚙️) > Project settings
4. في قسم "Your apps"، اضغط على "Add app" > Android
5. أدخل Package name الجديد: `com.islamskmojammaa.roznama`
6. (اختياري) أدخل App nickname و Debug signing certificate SHA-1
7. اضغط "Register app"

### 2. تحميل google-services.json الجديد

1. بعد إضافة التطبيق، سيظهر ملف `google-services.json` للتحميل
2. حمّل الملف واستبدل الملف الموجود في: `android/app/google-services.json`
3. تأكد من أن الملف يحتوي على `package_name` الجديد: `com.islamskmojammaa.roznama`

### 3. التحقق من التحديث

افتح `android/app/google-services.json` وتأكد من أن:
- `package_name` في `android_client_info` هو `com.islamskmojammaa.roznama`
- الملف يحتوي على جميع الإعدادات المطلوبة (API keys, project info, etc.)

### 4. اختبار Firebase بعد التحديث

بعد تحديث `google-services.json`:
1. قم ببناء التطبيق: `flutter build appbundle --release`
2. اختبر أن Firebase يعمل بشكل صحيح (Cloud Messaging, Analytics, etc.)

## ملاحظة

- **لا تحذف التطبيق القديم** من Firebase Console حتى تتأكد من أن التطبيق الجديد يعمل بشكل صحيح
- يمكنك الاحتفاظ بكلا التطبيقين في Firebase إذا لزم الأمر
- تأكد من تحديث أي إعدادات أخرى في Firebase Console (Cloud Messaging, Remote Config, etc.) إذا كانت مرتبطة بـ package name

