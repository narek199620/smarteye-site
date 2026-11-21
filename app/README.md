# SmartEye Price Manager — Android app

The app is the same Price Manager as `tools/calc-app` (smarteye.am/calc), packaged with Capacitor.

The Android APK and Windows installer are built by GitHub Actions (`.github/workflows/android-apk.yml`) when `app/VERSION` is changed on `main`, or when the workflow is started manually (`workflow_dispatch`). Changes to `tools/calc-app/` or other `app/` files alone do **not** trigger a release. Successful builds are published as a GitHub Release.

Download the latest APK on the phone:
https://github.com/narek199620/smarteye-site/releases/latest/download/SmartEye-PriceManager.apk

Signing key: `app/release.jks.enc` (AES-256 encrypted keystore, alias `pricemanager`).
Its password is the repository secret `ANDROID_KEYSTORE_PASSWORD` — keep a copy of it:
without the same key, Android refuses to install updates over the installed app.
