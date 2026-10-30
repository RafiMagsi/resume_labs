# ResumePace — Store Release Package

Everything needed to publish **ResumePace** (`com.nextfiction.resumelabs.ai`)
on the App Store and Google Play.

---

## 1. Creative assets

| Asset | File | Spec | Slot |
|---|---|---|---|
| App icon (master) | `app_icon_master_4096.png` | 4096×4096, RGB | source |
| App icon (Apple) | `app_icon_1024.png` | 1024×1024, RGB, **no alpha** | App Store Connect → App Icon |
| App icon (Play) | `app_icon_512.png` | 512×512, RGB | Play Console → Main store listing |
| Play feature graphic | `google_play_feature_graphic_1024x500.png` | 1024×500, RGB | Play → Feature graphic |
| Hero header | `hero_header_1200x630.png` | 1200×630, RGB | landing page / link preview / promo |
| Wide banner | `store_banner_1500x500.png` | 1500×500, RGB | promo banner, social header |

Regenerate all of them (icons are also written into `ios/Runner/.../AppIcon.appiconset`
and `android/app/src/main/res/`) with:

```bash
python3 tool/generate_brand_assets.py
```

> Apple accepts neither alpha channels nor transparency in screenshots or the
> app icon — every PNG in this folder is flattened to opaque RGB.

---

## 2. Screenshots

| Set | Path | Size | Status |
|---|---|---|---|
| iPhone 6.3" (Dynamic Island medium) — **required** | `screenshots/ios_iphone17pro/` | 1206×2622 | ✅ 5 shots |
| iPhone 6.9" (Dynamic Island large) | `screenshots/ios_iphone17promax/` | 1320×2868 | ✅ 5 shots |
| iPad 13" — **required (app runs on iPadOS)** | `screenshots/ios_ipad/` | 2064×2752 | ✅ 5 shots |
| Android phone (Play) | `screenshots/android_phone/` | 1080×2400 | ✅ 5 shots |

Each folder: `ios_history`, `ios_builder`, `ios_preview`, `ios_templates`,
`ios_optimizer` (PNG, RGB).

Regenerate with:

```bash
tool/capture_ios_screenshots.sh <simulator-udid> store_assets/screenshots/<set>
tool/capture_android_screenshots.sh <adb-serial>  store_assets/screenshots/android_phone
```

Both capture scripts flatten screenshots to RGB automatically. The iOS script
also overrides the status bar (9:41 / full battery / Wi-Fi) for a clean
presentation; the Android captures keep the device status bar.

---

## 3. Listing copy

- `listing/app_store_connect.md` — name, subtitle, keywords, description,
  what's new, app-privacy table, IAP config, review notes, upload steps.
- `listing/google_play.md` — title, short/full description, declarations
  checklist, data-safety mapping, IAP product, release path.
- `PRIVACY_POLICY.md` — publish this file, then put its URL in both listings.

Both listings' text length limits were verified programmatically
(name 10/30, subtitle 28/30, keywords 100/100, Play title 29/30,
short description 80/80).

---

## 4. In-app purchase

| | Value |
|---|---|
| Product ID | `resume_labs_credits_10` |
| Type | Consumable / managed |
| Price | USD 5.99 |
| Grants | 10 CV optimization credits (stored in Firestore per user) |

- **App Store Connect:** already configured (verified during review of 1.0 (3)).
  Do not rename — the app queries this exact ID.
- **Play Console:** still to create → *Monetise → In-app products → Add* with the
  same ID, price $5.99, status Active on the internal testing track.
- Restores intentionally return an error: consumables are not restorable, and
  credits live on the user's account so they survive reinstalls.

---

## 5. AdMob — production IDs still pending

Release builds are **ad-free by design** until all four IDs are filled in, so
Google's test units can never ship. Debug builds use Google's test units.

| # | What | Where to put it |
|---|---|---|
| 1 | Android app ID | `android/gradle.properties` → `admobAppId=ca-app-pub-xxxx~yyyy` (or `-PadmobAppId=`) |
| 2 | iOS app ID | `ios/Flutter/Release.xcconfig` → `ADMOB_APP_ID=ca-app-pub-xxxx~yyyy` |
| 3 | Android banner unit | `--dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-xxx/yyy` |
| 4 | iOS banner unit | `--dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-xxx/yyy` |

```bash
flutter build ipa --release \
  --dart-define=ADMOB_USE_TEST_ADS=false \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-XXX/YYY

flutter build appbundle --release   # same two dart-defines for Android
```

Config lives in `lib/core/ads/ad_config.dart` (`DISABLE_ADS=true` switches ads
off entirely). The banner renders on the History screen
(`lib/presentation/widgets/ads/ad_banner.dart`); UMP consent is collected on
first launch (`lib/core/ads/admob_service.dart`).

---

## 6. Builds for upload

**iOS (→ Xcode Organizer)**

```bash
flutter build ipa --release
# output: build/ios/ipa/*.ipa and build/ios/archive/*.xcarchive
# Xcode → Window → Organizer → Distribute App → App Store Connect → Upload
# Automatic signing, team XF5237ER2B
```

**Android (→ Play Console)**

```bash
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```

Release signing: `android/upload-keystore.jks` + `android/key.properties`
(both gitignored, mode 600, alias `resumepace`, RSA 2048, valid 10 000 days).
**Back the keystore up** — losing it means using Play's upload-key reset.
If Play Console already has this app registered with a different upload key,
use *Setup → App integrity → Request upload key reset* instead of this keystore.

---

## 7. Pre-flight checklist

- [ ] Privacy policy published at
      `https://nextfictiongames.com/resume-labs-privacy-policy/` (URL already
      pasted into both listing docs)
- [x] Contact / support / privacy placeholders replaced
      (`support@nextfictiongames.com`, `https://nextfictiongames.com/`)
- [ ] AdMob production IDs wired (§5) — or leave ads off for this release
- [ ] `resume_labs_credits_10` created in Play Console
- [x] Android phone screenshots captured (§2) — 1080×2400, 5 shots
- [ ] iOS archive uploaded via Organizer; build selected in TestFlight
- [ ] `.aab` uploaded to Play internal testing; IAP verified on a real account
- [ ] App Privacy (Apple) + Data safety (Play) forms match `listing/`
- [x] `flutter analyze` clean, `flutter test` green, `dart format` applied
