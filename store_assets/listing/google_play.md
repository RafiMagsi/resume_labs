# Google Play Console — Listing Metadata

Paste-ready copy for Play Console → **Main store listing** + **Store presence**.
Package: `com.nextfiction.resumelabs.ai` · Version: `1.0.2` (versionCode `13`)

> URLs and contact email are filled in. Publish `store_assets/PRIVACY_POLICY.md`
> first, then use the URL below in the Play data-safety and store listing forms.

---

## Main store listing

| Field | Value | Limit |
|---|---|---|
| App name | `ResumePace: AI Resume Builder` (29 chars) | 30 |
| Short description | `Build ATS-friendly resumes with AI. Pro templates, PDF export & CV optimization.` (80 chars) | 80 |
| Full description | see below | 4000 |
| App icon | `store_assets/app_icon_512.png` (or `android/app/src/main/res/playstore-icon.png`) | 512×512 PNG |
| Feature graphic | `store_assets/google_play_feature_graphic_1024x500.png` | 1024×500 |
| App category | Productivity | — |
| Contact email | `support@nextfictiongames.com` | — |
| Contact website | `https://nextfictiongames.com/` | — |
| Contact phone | optional | — |
| Privacy policy URL | `https://nextfictiongames.com/resume-labs-privacy-policy/` | — |

### Full description (max 4000 chars)

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

## Assets to upload (paths in this repo)

| Asset | File | Spec |
|---|---|---|
| Phone screenshots (5) | `store_assets/screenshots/android_phone/*.png` | ≥1080 px shortest side |
| Feature graphic | `store_assets/google_play_feature_graphic_1024x500.png` | 1024×500 |
| High-res icon | `store_assets/app_icon_1024.png` | 512×512 required, 1024 available |
| Tablet screenshots (optional) | `store_assets/screenshots/android_tablet/` | — |
| Header / promo banner | `store_assets/hero_header_1200x630.png`, `store_assets/store_banner_1500x500.png` | not an upload slot — use for the promo URL, Play badges, social |

---

## Declarations checklist

- **Contains ads:** Yes — AdMob banner. (Until real unit IDs are wired, release
  builds request no ads; keep the declaration as "contains ads" anyway, since
  the capability ships.)
- **In-app purchases:** Yes.
- **In-app product to create** (Monetise → Products → In-app products):

  | Field | Value |
  |---|---|
  | Product ID | `resume_labs_credits_10` |
  | Type | **Managed / consumable** (grant 10 credits on purchase) |
  | Price | USD 5.99 |
  | Status | Activate for the internal testing track first |

  Same ID as App Store Connect — the app queries one constant.

- **Data safety form:** mirror `store_assets/listing/app_store_connect.md`
  → App Privacy table: email (collected, linked), resume content (collected,
  linked), device identifiers for ads (collected, not linked), crash logs.
- **Content rating questionnaire:** Everyone · no violence, no mature content,
  **yes to "contains ads"**, **yes to "in-app purchases"**.
- **Target audience:** 13+ (or all ages) — product is a productivity tool.
- **App signing:** Play App Signing recommended; upload key is generated at
  `android/upload-keystore.jks` (see `android/key.properties`).

---

## Release path

1. Build: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`
2. Play Console → **Testing → Internal testing** → create release → upload `.aab`
3. Add tester emails → share the opt-in link → validate IAP on a real account
4. After QA: **Production → Create new release** → roll out (or staged 10/50/100%)
