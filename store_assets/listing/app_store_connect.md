# App Store Connect — Listing Metadata

Paste-ready copy for App Store Connect → **App Store → App Information / Version page**.
Bundle ID: `com.nextfiction.resumelabs.ai` · Team: `XF5237ER2B` · Version: `1.0.2` (build `13`)

> URLs are filled in: publish `store_assets/PRIVACY_POLICY.md` first, then use
> https://nextfictiongames.com/resume-labs-privacy-policy/ as the Privacy Policy URL.

---

## Core metadata

| Field | Value | Limit |
|---|---|---|
| App Name | `ResumePace` | 30 |
| Subtitle | `AI Resume Builder & CV Maker` | 30 |
| Promotional Text | see below | 170 |
| Keywords | see below | 100 |
| Category (primary) | Productivity | — |
| Category (secondary) | Education | — |
| Content Rating | 4+ (no objectionable content, no restricted material) | — |
| Support URL | `https://nextfictiongames.com/` | — |
| Marketing URL | optional — omit for now (no landing page yet) | — |
| Privacy Policy URL | `https://nextfictiongames.com/resume-labs-privacy-policy/` | — |

### Promotional Text (170 chars)

```
New in 1.0.2: refreshed ResumePace design, faster AI optimization, and a smoother export flow.
```

### Keywords (100 chars)

```
resume builder,cv maker,ai resume,ats resume,cover letter,job application,curriculum vitae,cv writer
```

### What's New in 1.0.2

```
- Fresh ResumePace look across the app
- Smarter, faster AI resume optimization
- Stability and performance improvements
```

---

## Description (App Store, max 4000 chars)

```
ResumePace is the AI resume builder that turns your experience into a polished,
ATS-friendly resume in minutes — no formatting fights, no blank pages.

BUILD A RESUME THAT GETS READ
Choose from professionally designed templates built to pass applicant tracking
systems. Every template is typeset by real designers, so your resume looks
polished on screen and on paper.

AI THAT WRITES WITH YOU
ResumePace drafts your professional summary, strengthens your bullet points, and
suggests skills recruiters search for. The AI optimization analyzes your resume
against the way modern hiring software reads it, then rewrites weak sections
into clear, measurable achievements.

OPTIMIZE WITH ONE TAP
Short on time? Run "Optimize with AI" and get a rewritten summary, sharper
experience bullets, and skill suggestions — while keeping your own voice.

WORKS THE WAY YOU DO
- Edit every section with a fast, focused builder
- Live PDF preview with pixel-accurate formatting
- Multiple resumes for every role you apply to
- Cloud sync, so your work follows you across devices
- Export a clean, shareable PDF in seconds

PRIVACY FIRST
Your resumes belong to you. ResumePace never sells your data, and your resume
content is used only to provide the features you ask for.

Download ResumePace and ship a resume you are proud to send.
```

---

## App Privacy (App Store Connect → App Privacy)

Declare as **data collected**, matching the Play data-safety declaration:

| Data type | Linked to identity | Used for tracking |
|---|---|---|
| Contact Info — email address (sign-in) | Yes | No |
| User Content — resumes, CV content | Yes | No |
| Identifiers — device identifier (AdMob) | No | Yes |
| Usage Data — ad interaction / crash diagnostics | Not linked | Yes |
| Diagnostics — crash logs (Firebase Crashlytics, if enabled) | Not linked | No |

"Data not collected" for everything else (location, health, financial, purchases
beyond the store transaction, searches, contacts, photos).

---

## In-App Purchase

| Field | Value |
|---|---|
| Product ID | `resume_labs_credits_10` |
| Type | **Consumable** |
| Price | USD 5.99 (tier 6 equivalent) |
| Locales | All |
| Status | Already configured in App Store Connect (verified during review 1.0 (3)) |

Do **not** rename the product ID — the app queries `resume_labs_credits_10`
(`lib/core/constants/app_strings.dart`) and existing customers' flows depend on it.

---

## Review notes (paste into "App Review Notes")

```
Demo account: [DEMO_EMAIL] / [DEMO_PASSWORD]

1. Sign in with the demo account.
2. Open a resume from History → tap "Optimize with AI" (costs 1 credit).
   - If credits run out, the paywall appears; "Buy 10 Optimizations" opens the
     store purchase sheet for the consumable product `resume_labs_credits_10`.
   - Note: consumables are not restorable by design; credits live in the
     user's account and survive reinstalls.
3. PDF export requires network access (Cloud Function) — test over Wi-Fi.

Ads: the build ships with AdMob configured but no live ad units are wired yet,
so reviewers will not see ads. UMP consent is requested on first launch.
```

Related working docs: `claude/docs/APP_STORE_REVIEW_GUIDE.md`,
`claude/docs/APPLE_REVIEW_RESPONSE.md`.

---

## Upload steps (this machine → Organizer)

```bash
# 1. Build an archive with the release AdMob darts-defines once IDs exist
flutter build ipa --release \
  --dart-define=ADMOB_USE_TEST_ADS=false \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-XXX/YYY

# 2. Open Xcode → Window → Organizer → the produced archive → Distribute App
#    → App Store Connect → Upload (automatic signing, team XF5237ER2B)
```

`flutter build ipa` writes the `.xcarchive` + `.ipa` under `build/ios/archive/`
and `build/ios/ipa/`.
