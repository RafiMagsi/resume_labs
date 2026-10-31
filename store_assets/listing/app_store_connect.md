# App Store Connect — Listing Metadata (ASO-optimized)

Paste-ready copy for App Store Connect → **App Store → App Information / Version page**.
Bundle ID: `com.nextfiction.resumelabs.ai` · Team: `XF5237ER2B` · Version: `1.0.2` (build `13`)

> Bundle ID, SKU and the on-device name (`ResumePace`) are unchanged. Only the
> **store listing** name/subtitle/keywords changed, for search ranking.

---

## Core metadata

| Field | Value | Chars / Limit |
|---|---|---|
| App Name | `ResumePace: AI Resume Builder` | 29 / 30 |
| Subtitle | `CV Maker, ATS Templates & PDF` | 29 / 30 |
| Promotional Text | see below | 141 / 170 |
| Keywords | see below | 99 / 100 |
| Category (primary) | Productivity | — |
| Category (secondary) | Business | — |
| Content Rating | 4+ | — |
| Support URL | `https://nextfictiongames.com/` | — |
| Marketing URL | omit (no landing page yet) | — |
| Privacy Policy URL | `https://nextfictiongames.com/resume-labs-privacy-policy/` | — |

### ASO rationale

Apple indexes **Name + Subtitle + Keywords** and ignores the description for
search. Words are never repeated across the three fields (Apple dedupes them),
so every character is spent on a distinct term:

| Field | Terms covered |
|---|---|
| Name | resume, builder, AI, ResumePace (brand) |
| Subtitle | CV, maker, ATS, templates, PDF |
| Keywords | curriculum vitae, cover letter, job application, career, interview, hiring, professional, optimizer, writer |

Apple combines words across fields, so this ranks for "resume builder", "ai resume",
"cv maker", "ats templates", "resume pdf", "resume optimizer", "cv writer",
"job application", "curriculum vitae" and combinations. No competitor or
trademark terms, no price words ("free"), no "best/#1" claims (Guideline 2.3).
Secondary category moved from Education to **Business**, where job-search
tools are browsed.

### Promotional Text (170 chars max, editable without a new build)

```
Build an ATS-friendly resume in minutes. Choose from 14 templates, optimize with AI, and export a polished PDF for your next job application.
```

### Keywords (100 chars max)

```
curriculum vitae,cover letter,job application,career,interview,hiring,professional,optimizer,writer
```

### What's New in 1.0.2

```
- Refreshed ResumePace design across the app
- Smarter, faster AI resume optimization
- 14 professional templates, one tap to switch
- Stability and performance improvements
```

---

## Description (App Store, max 4000 chars)

```
Build a professional, ATS-friendly resume in minutes. ResumePace is the AI resume builder and CV maker that turns your experience into a polished, interview-ready document — no formatting fights, no blank pages.

WHY RESUMEPACE
• 14 professionally designed resume templates for tech, business, sales, marketing, finance, healthcare, academic, creative and startup careers
• AI resume optimization that rewrites your summary and experience bullets into clear, achievement-focused language
• Live preview, so you see exactly what recruiters will see
• One-tap PDF export, ready to email or upload to any job application
• Photo or no photo — every template supports both

OPTIMIZE YOUR RESUME WITH AI
Paste or upload your current resume and tap Optimize. ResumePace analyzes it the way modern applicant tracking systems (ATS) read it, then suggests a sharper professional summary, stronger bullet points and relevant skills — while keeping your own voice.

A BUILDER THAT STAYS OUT OF YOUR WAY
• Personal details, summary, work experience, education, skills, projects, achievements, languages, interests and references
• Add custom sections for certifications, volunteering or publications
• Create multiple resumes — one tailored to every role you apply for
• Edit anytime, then switch templates without retyping a word
• Cloud sync keeps your resumes safe and available across devices

TEMPLATES FOR EVERY CAREER
Classic, Modern, Modern Clean, Sidebar, Minimal, Executive, Data Science, Sales, Marketing, Finance, Creative, Academic, Healthcare and Startup. Clean typography, clear hierarchy and ATS-aware layouts keep your CV easy to scan.

SIMPLE PRICING
Create and export resumes with no subscription. AI optimizations are sold as an optional credit pack, so you only pay when you want an extra polish.

PRIVACY FIRST
Your resume belongs to you. ResumePace never sells your data, and your resume content is used only to provide the features you ask for.

Whether you are writing your first CV, changing careers or applying for a promotion, download ResumePace and build a resume you are proud to send.

Support: support@nextfictiongames.com
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
| Display name (suggested) | `10 AI Resume Optimizations` |
| Description (suggested) | `Adds 10 AI resume optimizations to your account.` |
| Price | USD 5.99 |
| Status | Already configured in App Store Connect (verified during review 1.0 (3)) |

Do **not** rename the product ID — the app queries `resume_labs_credits_10`
(`lib/core/constants/app_strings.dart`).

---

## Screenshots to upload

Captioned marketing screenshots are in `store_assets/marketing/`. Raw captures
remain in `store_assets/screenshots/`.

| Device slot | Folder | Size |
|---|---|---|
| iPhone 6.9" | `marketing/ios_iphone_6_9/` | 1320×2868 |
| iPhone 6.3" | `marketing/ios_iphone_6_3/` | 1206×2622 |
| iPad 13" | `marketing/ios_ipad_13/` | 2064×2752 |

Order (first three show in search results): Hero → AI optimizer → Templates →
Live preview → Guided builder.

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

## Upload steps

```bash
flutter build ipa --release
# Output: build/ios/ipa/ResumePace.ipa → Xcode Organizer or `xcrun altool` / Transporter
```
