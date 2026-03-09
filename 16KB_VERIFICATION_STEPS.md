# خطوات التحقق من إصلاح 16 KB Page Size

دليل خطوة بخطوة للتحقق أن مشكلة "This app isn't 16 KB compatible" تم حلها.

---

## الطريقة 1: التحقق عبر Emulator (الأبسط)

### الخطوة 1: إنشاء Emulator يدعم 16 KB

1. افتح **Android Studio**
2. من القائمة: **Tools** → **Device Manager**
3. اضغط **Create Device**
4. اختر جهاز (مثل Pixel 7 أو Pixel 8) → **Next**
5. اختر System Image:
   - **API 35 (Android 15)** أو **API 36**
   - المعمارية: **arm64-v8a**
   - إذا لم يكن مثبتاً، اضغط **Download** بجانب الـ image
6. اضغط **Next** ثم **Finish**

### الخطوة 2: تنظيف وبناء المشروع

1. افتح Terminal في مجلد المشروع
2. نفّذ:
   ```
   flutter clean
   ```
3. ثم:
   ```
   flutter build apk --release
   ```

### الخطوة 3: تشغيل التطبيق على Emulator

1. شغّل الـ Emulator من Device Manager (زر Play بجانب الجهاز)
2. انتظر حتى يكتمل الإقلاع
3. في Terminal نفّذ:
   ```
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```
4. أو استخدم مباشرة:
   ```
   flutter run --release
   ```
   (سيختار الجهاز/Emulator المتصل تلقائياً)

### الخطوة 4: التحقق

- افتح التطبيق **Islamsk Mojammaa** على الـ Emulator
- **إذا نجح الإصلاح:** التطبيق يفتح بدون أي رسالة تحذير
- **إذا لم ينجح:** ستظهر رسالة "This app isn't 16 KB compatible. ELF alignment check failed"

---

## الطريقة 2: التحقق على جهاز حقيقي

### الخطوة 1: بناء APK

1. في Terminal:
   ```
   flutter clean
   flutter build apk --release
   ```

### الخطوة 2: نقل التطبيق للهاتف

1. الملف جاهز في:  
   `build\app\outputs\flutter-apk\app-release.apk`
2. انقله للهاتف عبر:
   - USB (اسحب وأفلت للمجلد Downloads)
   - أو بريد إلكتروني / تطبيق مراسلة
   - أو Google Drive

### الخطوة 3: التثبيت والتحقق

1. على الهاتف افتح الملف `app-release.apk`
2. سمح بالتثبيت من مصادر غير معروفة إن طُلب
3. ثبّت التطبيق
4. شغّل التطبيق
5. **إذا نجح الإصلاح:** لا تظهر رسالة 16 KB
6. **ملاحظة:** التحذير يظهر فقط على أجهزة Android 15+ أو أجهزة تدعم 16 KB page size

---

## الطريقة 3: التحقق الفني (فحص ملفات .so)

للتحقق أن ملفات `.so` في الـ APK متوافقة مع 16 KB.

### الخطوة 1: فك ضغط الـ APK

1. نسّخ مسار الـ APK:  
   `build\app\outputs\flutter-apk\app-release.apk`
2. أعد تسمية الملف من `.apk` إلى `.zip` أو استخدم أداة فك ضغط
3. فك الضغط في مجلد (مثلاً `apk_extracted`)

### الخطوة 2: البحث عن ملفات .so

1. اذهب للمجلد:  
   `apk_extracted\lib\arm64-v8a\`
2. ستجد ملفات مثل:  
   `libflutter.so`, `libapp.so`, وغيرها

### الخطوة 3: فحص Alignment بـ readelf

1. تحتاج `llvm-readelf` من Android NDK  
   المسار النموذجي:  
   `C:\Users\hp\AppData\Local\Android\sdk\ndk\27.0.12077973\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-readelf.exe`
2. نفّذ (مع تعديل المسارات حسب جهازك):
   ```
   llvm-readelf -l apk_extracted\lib\arm64-v8a\libflutter.so
   ```
3. ابحث عن `LOAD` في الـ output، وتأكد أن عمود `Align` = `0x4000` أو أكبر (16384)
4. **لو كان أي ملف .so لديه Align أقل من 0x4000:** التطبيق غير متوافق مع 16 KB

---

## الطريقة 4: التحقق بالسكربت (check_elf_alignment.sh)

سكربت رسمي من Android للتحقق من ELF alignment. يعرض كل ملف `.so` كـ **ALIGNED** أو **UNALIGNED**.

### المتطلبات على Windows

1. **Git Bash** — من [Git for Windows](https://git-scm.com/download/win)
2. **objdump** — موجود ضمن Git for Windows في `C:\Program Files\Git\usr\bin\`
3. **zipalign** (اختياري) — للتحقق من zip alignment، يتطلب Android SDK build-tools 35.0.0-rc3+
4. **unzip** — موجود في Git Bash

### الخطوة 1: بناء APK

```
flutter clean
flutter build apk --release
```

### الخطوة 2: فتح Git Bash

1. انتقل لمجلد المشروع:  
   `c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama`
2. انقر بالزر الأيمن واختر **Git Bash Here**

### الخطوة 3: تشغيل السكربت

```
bash scripts/check_elf_alignment.sh build/app/outputs/flutter-apk/app-release.apk
```

### الخطوة 4: تفسير النتيجة

- **كل الملفات ALIGNED (أخضر):** الإصلاح ناجح، التطبيق متوافق مع 16 KB
- **وجود ملف UNALIGNED (أحمر):** هذا الملف يسبب رسالة التحذير
- **ELF Verification Successful:** تحقق ناجح

إذا كان `zipalign` مثبتاً (build-tools 35.0.0-rc3+)، السكربت يعرض أيضاً نتيجة zip alignment.

---

## ملخص الإصلاح المطبق

تم إضافة في `android/gradle.properties`:

```
dev.steenbakker.mobile_scanner.useUnbundled=true
```

هذا يجعل `mobile_scanner` يستخدم Google Play Services بدلاً من تضمين ML Kit في الـ APK، وبالتالي إزالة ملفات `.so` غير المتوافقة مع 16 KB.

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| `adb` غير معروف | أضف مسار Android SDK platform-tools إلى الـ PATH |
| Emulator بطيء | استخدم معمارية x86_64 للكمبيوتر (ولكن 16 KB قد لا يظهر) |
| التحذير ما زال يظهر | تأكد أنك نفذت `flutter clean` قبل البناء |
| التطبيق لا يفتح | تأكد أن الهاتف/Emulator فيه Google Play Services (للمسح الضوئي) |
| `objdump: command not found` (السكربت) | أضف `C:\Program Files\Git\usr\bin` إلى الـ PATH أو شغّل Git Bash |
| `unzip: command not found` (السكربت) | استخدم Git Bash؛ unzip مدمج في Git for Windows |
| Zip alignment NOTICE | اختياري؛ لتثبيته: `sdkmanager "build-tools;35.0.0-rc3"` |
