# تعليمات إعداد التطبيق للرفع على Google Play

## ✅ التعديلات المكتملة

تم إكمال جميع التعديلات التالية:

1. ✅ تغيير Package Name من `com.example.norway_roznama_new_project` إلى `com.islamskmojammaa.roznama`
2. ✅ إنشاء ملف `android/key.properties` لإعدادات Keystore
3. ✅ إعداد Release Signing Configuration في `build.gradle`
4. ✅ نقل وتحديث جميع ملفات Kotlin
5. ✅ تحديث MethodChannel names
6. ✅ تحديث Action names في AndroidManifest
7. ✅ تحديث ProGuard rules

## 📋 الخطوات التالية (يجب عليك إكمالها)

### 1. إنشاء Keystore

قم بتشغيل الأمر التالي في terminal (في مجلد المشروع):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**مهم جداً:**
- احفظ كلمات المرور في مكان آمن
- لا تشارك ملف `.jks` مع أحد
- أضف `upload-keystore.jks` إلى `.gitignore` إذا لم يكن موجوداً

### 2. تحديث key.properties

افتح `android/key.properties` وحدّث القيم:

```properties
storePassword=YOUR_ACTUAL_STORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. تحديث Firebase Configuration

**مهم جداً:** اتبع التعليمات في ملف `FIREBASE_SETUP_NOTES.md`

1. أضف تطبيق Android جديد في Firebase Console
2. استخدم Package Name: `com.islamskmojammaa.roznama`
3. حمّل `google-services.json` الجديد واستبدل الملف القديم

### 4. بناء App Bundle

بعد إكمال الخطوات أعلاه، قم ببناء التطبيق:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

الملف سيكون في: `build/app/outputs/bundle/release/app-release.aab`

### 5. اختبار التطبيق

قبل الرفع على Google Play:
- ✅ اختبر بناء التطبيق
- ✅ اختبر عمل الأذان والإشعارات
- ✅ اختبر عمل Firebase (Cloud Messaging, Analytics)
- ✅ اختبر على أجهزة مختلفة

## 📝 ملاحظات إضافية

### ملفات مهمة تم تحديثها:

- `android/app/build.gradle` - Package name و Signing config
- `android/app/src/main/AndroidManifest.xml` - Action names
- `android/app/src/main/kotlin/com/islamskmojammaa/roznama/*.kt` - جميع ملفات Kotlin
- `lib/core/audio/adhan_service.dart` - MethodChannel name
- `linux/CMakeLists.txt` - APPLICATION_ID
- `android/app/proguard-rules.pro` - ProGuard rules

### ملفات يجب تحديثها يدوياً:

- `android/app/google-services.json` - بعد إضافة التطبيق في Firebase Console
- `android/key.properties` - بعد إنشاء Keystore

## ⚠️ تحذيرات

1. **لا ترفع التطبيق على Google Play** حتى:
   - تنشئ Keystore وتحدّث key.properties
   - تحدّث Firebase Configuration
   - تختبر التطبيق بشكل كامل

2. **احفظ Keystore في مكان آمن** - إذا فقدته، لن تتمكن من تحديث التطبيق على Google Play

3. **تأكد من تحديث Firebase** - بدون تحديث google-services.json، لن يعمل Firebase بشكل صحيح

## 🎯 الخطوات النهائية للرفع على Google Play

بعد إكمال جميع الخطوات أعلاه:

1. سجّل حساب مطور Google Play (إذا لم يكن لديك)
2. أنشئ تطبيق جديد في Google Play Console
3. ارفع `app-release.aab`
4. أضف معلومات التطبيق (الوصف، الشعارات، لقطات الشاشة)
5. أضف Privacy Policy URL
6. أكمل Content Rating
7. أرسل للتقييم

---

**تم إعداد المشروع بنجاح! 🎉**

