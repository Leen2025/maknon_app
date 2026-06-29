#!/usr/bin/env bash
# إعداد بناء iOS لتطبيق مَكنون — شغّليه على جهاز Mac من جذر مشروع maknoon:
#   bash ios_setup.sh
set -e

echo "▶ flutter clean"
flutter clean

echo "▶ flutter pub get"
flutter pub get

echo "▶ pod install (داخل مجلد ios)"
cd ios
# يثبّت CocoaPods تلقائيًا لو لم يكن موجودًا
if ! command -v pod >/dev/null 2>&1; then
  echo "✗ CocoaPods غير مثبّت. ثبّتيه أولًا: sudo gem install cocoapods"
  exit 1
fi
pod install --repo-update
cd ..

echo ""
echo "✅ تم. افتحي الآن: ios/Runner.xcworkspace  (وليس .xcodeproj)"
