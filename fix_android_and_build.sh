#!/usr/bin/env bash
# سكريبت تهيئة وبناء تطبيق الأندرويد (APK) وتثبيته مباشرة بدون أخطاء
set -e
echo "[1/3] توليد ملفات المنصات المتوافقة مع إصدار Flutter لديك..."
flutter create --platforms=android,ios,web .
echo "[2/3] جلب الحزم البرمجية..."
flutter pub get
echo "[3/3] بناء ملف التثبيت للأندرويد (APK)..."
flutter build apk --release
echo "✅ تم بناء ملف الأندرويد بنجاح في المسار: build/app/outputs/flutter-apk/app-release.apk"
