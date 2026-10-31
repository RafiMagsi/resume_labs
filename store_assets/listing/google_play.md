# Google Play Console — Listing Metadata (ASO-optimized)

Paste-ready copy for Play Console → **Main store listing** + **Store presence**.
Package: `com.nextfiction.resumelabs.ai` · Version: `1.0.2` (versionCode `13`)

> Package name and on-device label (`ResumePace`) are unchanged. Only the
> **store listing** changed, for search ranking.

---

## Main store listing

| Field | Value | Chars / Limit |
|---|---|---|
| App name | `ResumePace: AI Resume Builder` | 29 / 30 |
| Short description | `AI resume builder & CV maker with 14 ATS-friendly templates and PDF export.` | 75 / 80 |
| Full description | see below | <4000 |
| App icon | `store_assets/app_icon_512.png` | 512×512 PNG |
| Feature graphic | `store_assets/google_play_feature_graphic_1024x500.png` | 1024×500 |
| App category | Productivity | — |
| Tags | Productivity, Career, Business (pick what Play offers) | — |
| Contact email | `support@nextfictiongames.com` | — |
| Contact website | `https://nextfictiongames.com/` | — |
| Privacy policy URL | `https://nextfictiongames.com/resume-labs-privacy-policy/` | — |

### ASO rationale

Play indexes title, short description **and the full description**. Title and
short description carry the head terms ("resume builder", "AI", "CV maker",
"ATS", "templates", "PDF"); the full description repeats the head terms 4–5
times naturally and covers long-tail phrases (resume optimizer, CV writer, job
application, career-specific templates). No emoji spam, no "best/#1/free"
claims, no unrelated keywords (Play metadata policy).

### Full description

```
Build a professional, ATS-friendly resume in minutes. ResumePace is the AI resume builder and CV maker that turns your experience into a polished, interview-ready resume — no formatting fights, no blank pages.

WHY RESUMEPACE
• 14 professionally designed resume templates for tech, business, sales, marketing, finance, healthcare, academic, creative and startup careers
• AI resume optimization that rewrites your summary and experience bullets into clear, achievement-focused language
• Live resume preview, so you see exactly what recruiters will see
• One-tap PDF export, ready to share or attach to any job application
• Photo or no photo — every template supports both

OPTIMIZE YOUR RESUME WITH AI
Paste or upload your current resume and tap Optimize. ResumePace analyzes it the way modern applicant tracking systems (ATS) read it, then suggests a sharper professional summary, stronger bullet points and relevant skills — while keeping your own voice. A faster way to write a resume that gets noticed.

A RESUME BUILDER THAT STAYS OUT OF YOUR WAY
• Personal details, summary, work experience, education, skills, projects, achievements, languages, interests and references
• Add custom sections for certifications, volunteering or publications
• Create multiple CVs — one tailored to every job you apply for
• Edit anytime, then switch resume templates without retyping a word
• Cloud sync keeps your resumes safe and available across devices

TEMPLATES FOR EVERY CAREER
Classic, Modern, Modern Clean, Sidebar, Minimal, Executive, Data Science, Sales, Marketing, Finance, Creative, Academic, Healthcare and Startup. Clean typography, clear hierarchy and ATS-aware layouts keep your CV easy to scan for both recruiters and software.

SIMPLE PRICING
Create and export resumes with no subscription. AI optimizations are sold as an optional credit pack, so you only pay when you want an extra polish. The app contains ads.

PRIVACY FIRST
Your resume belongs to you. ResumePace never sells your data, and your resume content is used only to provide the features you ask for.

Whether you are writing your first CV, changing careers or applying for a promotion, download ResumePace — the AI CV maker and resume generator — and build a resume you are proud to send.

Support: support@nextfictiongames.com
```

---

## Assets to upload (paths in this repo)

| Slot | File | Spec |
|---|---|---|
| App icon | `store_assets/app_icon_512.png` | 512×512 |
| Feature graphic | `store_assets/google_play_feature_graphic_1024x500.png` | 1024×500 |
| Phone screenshots (5) | `store_assets/marketing/android_phone/*.png` | 1080×2400 |

Order: Hero → AI optimizer → Templates → Live preview → Guided builder.

---

## Declarations checklist

- **Contains ads:** Yes — AdMob banner.
- **In-app purchases:** Yes.
- **In-app product to create** (Monetise → Products → In-app products):

  | Field | Value |
  |---|---|
  | Product ID | `resume_labs_credits_10` |
  | Type | **Managed / consumable** |
  | Name | `10 AI Resume Optimizations` |
  | Price | USD 5.99 |
  | Status | Activate for internal testing first |

- **Data safety form:** mirror `listing/app_store_connect.md` → App Privacy.
- **Content rating questionnaire:** Everyone · contains ads · in-app purchases.
- **Target audience:** 18+ / 13+ (productivity tool; not designed for children).
- **App signing:** Play App Signing; upload key `android/upload-keystore.jks`.

---

## Release path

1. `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`
2. Play Console → **Testing → Internal testing** → create release → upload `.aab`
3. Validate IAP on a real tester account
4. **Production → Create new release** → roll out (or staged 10/50/100%)
