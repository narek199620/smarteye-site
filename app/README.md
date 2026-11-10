# SmartEye Price Manager — Android app

The app is the same Price Manager as `tools/calc-app` (smarteye.am/calc), packaged with Capacitor.

The APK is built by GitHub Actions (`.github/workflows/android-apk.yml`) on every change to
`tools/calc-app/` or `app/`, and published as a GitHub Release.

Download the latest APK on the phone:
https://github.com/vardanyannarek00/smarteye-site/releases/latest/download/SmartEye-PriceManager.apk

Signing key: `app/release.jks.enc` (AES-256 encrypted keystore, alias `pricemanager`).
Its password is the repository secret `ANDROID_KEYSTORE_PASSWORD` — keep a copy of it:
without the same key, Android refuses to install updates over the installed app.
