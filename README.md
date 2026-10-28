# Strongly (native Android, Java)

Native Android port of the Strongly Flutter app. Java 17, no Kotlin, no Compose, no ads.

- `applicationId`: `com.strongly.strongly`; `compileSdk`/`targetSdk` 36; `minSdk` 26.
- Backend base URL: `app/src/main/java/com/strongly/strongly/net/ApiConstants.java`.
- Premium: Google Play Billing (`billing/PremiumService.java`).

## Building

```
./gradlew assembleDebug          # debug APK
./gradlew bundleRelease          # signed release AAB (needs signing files below)
./gradlew assembleRelease        # signed release APK
```

## Release signing

Signing files are intentionally **not** committed. Place them locally:

- `app/upload-keystore.jks`
- `key.properties` in the repo root with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`

Both are listed in `.gitignore`.
