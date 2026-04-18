# ResumeAI — Software Requirements Specification (SRS)

**Version:** 1.0  
**Status:** MVP  
**Last Updated:** April 2026  
**Architecture:** Clean Architecture (Domain → Data → Presentation)

---

## 1. Executive Summary

**ResumeAI** is a Flutter mobile application that generates, edits, and exports professional resumes using OpenAI's GPT-4o. Users input career details through an intuitive form, receive AI-powered suggestions and content generation, and export polished PDFs in three template styles.

**Target Users:** Job seekers, career changers, students, professionals updating resumes  
**Platforms:** iOS (14+), Android (API 21+)  
**Core Technologies:** Flutter 3.19+, Riverpod, OpenAI GPT-4o, Firebase (Auth + Firestore), PDF generation

---

## 2. Functional Requirements

### 2.1 Authentication
- **FR-1:** Users must sign up with email + password
- **FR-2:** Users must sign in with email + password
- **FR-3:** Password reset via email link
- **FR-4:** User session persists across app launches (auto sign-in)
- **FR-5:** Users can sign out — session clears

### 2.2 Resume Building
- **FR-6:** Users create a new resume via multi-step form
- **FR-7:** Resume form includes:
  - Personal info (name, email, phone, location, summary)
  - Work experience (company, role, dates, bullet points)
  - Education (school, degree, field, graduation date)
  - Skills (list of skill tags)
- **FR-8:** Users can edit existing resume fields
- **FR-9:** Users receive AI-powered suggestions:
  - Auto-generate professional summary from work history
  - Improve bullet points (tone, clarity, impact)
  - Suggest relevant skills based on job description input
- **FR-10:** Live preview updates as user edits
- **FR-11:** Users save resume to Firestore (tied to their user account)

### 2.3 Template Selection
- **FR-12:** Three resume templates available: Classic, Modern, Minimal
- **FR-13:** Users preview each template before exporting
- **FR-14:** Users select one template at export time

### 2.4 PDF Export
- **FR-15:** Users export resume as PDF with selected template
- **FR-16:** PDF is generated on-device (no server-side rendering)
- **FR-17:** PDF file is downloadable to device storage
- **FR-18:** iOS: share PDF via AirDrop, Mail, Messages
- **FR-19:** Android: share PDF via Gmail, WhatsApp, Drive

### 2.5 Resume History
- **FR-20:** Users view list of all saved resumes (title, date created, date modified)
- **FR-21:** Users can load an existing resume to edit
- **FR-22:** Users can delete a resume (with confirmation)
- **FR-23:** Resumes sync in real-time from Firestore

---

## 3. Non-Functional Requirements

### 3.1 Performance
- **NFR-1:** App loads in <2 seconds cold start
- **NFR-2:** Form navigation between steps: <300ms
- **NFR-3:** AI suggestion requests timeout after 15 seconds
- **NFR-4:** PDF generation completes within 5 seconds

### 3.2 Reliability
- **NFR-5:** Firestore offline support enabled — cached resumes load without internet
- **NFR-6:** Network errors display user-friendly messages
- **NFR-7:** App does not crash on network failure
- **NFR-8:** OpenAI API failures map to clear error messages

### 3.3 Security
- **NFR-9:** API key (`OPENAI_API_KEY`) never stored in source code — loaded from `.env`
- **NFR-10:** Firebase Auth enforces password rules (min 8 chars)
- **NFR-11:** Firestore security rules: users can only read/write their own resumes
- **NFR-12:** HTTPS enforced for all external API calls

### 3.4 Usability
- **NFR-13:** UI responsive on phones (portrait) and tablets (landscape)
- **NFR-14:** Keyboard always hidden after text input
- **NFR-15:** All text visible without squinting (min 12px font)
- **NFR-16:** Color contrast ratio ≥4.5:1 for WCAG AA compliance

### 3.5 Scalability
- **NFR-17:** App supports up to 50 resumes per user without lag
- **NFR-18:** Firestore queries indexed for fast retrieval

---

## 4. User Workflows

### Workflow A: Create Resume from Scratch
1. User signs in
2. Taps "New Resume"
3. Fills form: personal info → work exp → education → skills (4 steps)
4. At each step, taps "Get AI Suggestion" for that section (optional)
5. Taps "Save Resume" — syncs to Firestore
6. Taps "Export" → selects template → downloads PDF

### Workflow B: Edit Existing Resume
1. User signs in
2. Views "History" — list of saved resumes
3. Taps a resume → loads into editor
4. Edits fields
5. AI suggestions available at any step
6. Taps "Save" → updates Firestore
7. Taps "Export" for new PDF

### Workflow C: Generate AI Suggestions
1. User in form, has written some content
2. Taps "Improve this" button on a field
3. App sends field content + context to OpenAI
4. AI response appears in a suggestion box
5. User can accept (replace text) or dismiss
6. User continues editing

---

## 5. Data Models

### Resume Entity (domain/entities/resume.dart)
```
Resume {
  String id (Firestore doc ID)
  String userId (Firebase Auth UID)
  String title
  String personalSummary
  List<WorkExperience> workExperiences
  List<Education> educations
  List<Skill> skills
  DateTime createdAt
  DateTime updatedAt
}
```

### WorkExperience
```
WorkExperience {
  String company
  String role
  String location
  DateTime startDate
  DateTime endDate (nullable)
  List<String> bulletPoints
  bool isCurrentRole
}
```

### Education
```
Education {
  String school
  String degree
  String field
  DateTime graduationDate
  String gpa (optional)
}
```

### Skill
```
Skill {
  String name
  String category (e.g., "Technical", "Language", "Soft")
}
```

### ResumeTemplate (enum)
```
enum ResumeTemplate {
  classic,  // Traditional, centered, serif fonts
  modern,   // Two-column, sidebar for skills
  minimal   // Clean, sans-serif, maximalist whitespace
}
```

---

## 6. API Integrations

### 6.1 OpenAI API (`/v1/chat/completions`)

**Endpoint:** `POST https://api.openai.com/v1/chat/completions`  
**Model:** `gpt-4o`  
**Max Tokens:** `1500`

**Use Cases:**

1. **Generate Professional Summary**
   - Input: Work history (list of roles + descriptions)
   - Output: 2-3 sentence professional summary (JSON)

2. **Improve Bullet Point**
   - Input: Existing bullet point text
   - Output: 2-3 improved versions (JSON array)

3. **Suggest Skills**
   - Input: Job description text (optional)
   - Output: List of 10 suggested skills (JSON array)

**Error Handling:**
- 401: Invalid API key → show "API key not configured"
- 429: Rate limit → show "Too many requests, try again in 1 minute"
- 500: Server error → show "OpenAI service unavailable"
- Network timeout (15s) → show "Request took too long"

### 6.2 Firebase Auth

- Sign up: `createUserWithEmailAndPassword(email, password)`
- Sign in: `signInWithEmailAndPassword(email, password)`
- Password reset: `sendPasswordResetEmail(email)`
- Sign out: `signOut()`
- Current user: `onAuthStateChanged` stream

### 6.3 Firestore

**Collection:** `users/{userId}/resumes/{resumeId}`

**Operations:**
- Create: `add(resumeModel)`
- Read: `doc(resumeId).get()` or `collection().where('userId', ==, uid)`
- Update: `doc(resumeId).update()`
- Delete: `doc(resumeId).delete()`
- Real-time sync: `.snapshots()` stream

**Security Rules:**
```
match /users/{userId}/resumes/{resumeId} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 7. Screen Specifications

### 7.1 Splash/Auth Screens

**LoginScreen**
- Email + password text fields
- "Sign In" button
- "Don't have an account?" link → RegisterScreen
- "Forgot password?" link → PasswordResetScreen

**RegisterScreen**
- Email + password + confirm password fields
- "Create Account" button
- "Already have an account?" link → LoginScreen

### 7.2 Builder Screens

**BuilderScreen (Multi-step form)**
- Step 1: Personal Info (name, email, phone, location, summary)
- Step 2: Work Experience (add/edit/remove entries)
- Step 3: Education (add/edit/remove entries)
- Step 4: Skills (add/remove skill tags)
- Each step: "Get AI Suggestion" button (optional)
- Bottom nav: "Back" | "Next" | "Save Resume"
- Live preview pane on right (desktop) or bottom (mobile)

**PreviewScreen**
- Full resume preview as it appears in PDF
- Template selector (Classic | Modern | Minimal)
- "Export PDF" button
- "Back to Edit" button

### 7.3 History Screen

**HistoryScreen**
- List of user's resumes (title, created date, modified date)
- Swipe to delete or long-press menu (Edit | Delete | Export)
- "New Resume" FAB button
- Pull-to-refresh syncs Firestore

### 7.4 Supporting Screens

**LoadingOverlay** (global)
- Shown during: API calls, Firestore sync, PDF generation
- Dismiss-able with back button or completion
- Progress indicator + status message

**ErrorDialog**
- Shows on API/Firestore failures
- "Retry" + "Dismiss" buttons
- Clear error message from mapped `Failure`

---

## 8. PDF Template Specifications

All templates: A4 (210 × 297mm), margins 40pt (except Modern = 28pt)

### Classic Template
- Single column, centered header
- Serif fonts (e.g., Lora for headings, Crimson Text for body)
- Section headers: bold, 12pt, all caps
- Content: 10pt, left-aligned
- Work experience bullet points indented 0.25in

### Modern Template
- Two-column layout: left sidebar (30%) + right content (70%)
- Sidebar: skills, contact info (small font)
- Right: resume sections
- Header with colored accent bar
- Sans-serif throughout (e.g., Roboto)
- Subtle gray backgrounds on section headers

### Minimal Template
- Single column, maximalist whitespace (100pt margins)
- Font: 11pt sans-serif (Jost or similar)
- Headers: 14pt, bold, no background
- Lots of vertical breathing room
- No decorative elements
- Print-friendly (no colors except black/gray)

---

## 9. User Stories (MVP Scope)

| ID | Title | Story | Acceptance Criteria |
|---|---|---|---|
| US-1 | Sign up | As a new user, I want to create an account with email/password | Email valid, password ≥8 chars, account created in Firebase |
| US-2 | Sign in | As a user, I want to log in to my account | Email/password matched, session persists across app restart |
| US-3 | Create resume | As a user, I want to create a resume by filling a form | Form saves to Firestore with all 4 sections, ID auto-generated |
| US-4 | Edit resume | As a user, I want to edit an existing resume | Changes persist in Firestore, timestamp updates |
| US-5 | AI summary | As a user, I want AI to generate a professional summary from my work history | OpenAI call succeeds, summary appears in <5 sec |
| US-6 | Improve bullet | As a user, I want AI to improve my work experience bullet points | OpenAI returns 2-3 suggestions, user can accept or reject |
| US-7 | Suggest skills | As a user, I want AI to suggest relevant skills | OpenAI returns 10 skills, user can add to resume |
| US-8 | Live preview | As a user, I want to see my resume update in real-time as I edit | Preview refreshes on every field change |
| US-9 | Export PDF | As a user, I want to export my resume as a PDF | PDF generated in <5 sec, downloads to device storage |
| US-10 | Choose template | As a user, I want to choose from 3 resume templates | User selects template before export, PDF reflects choice |
| US-11 | View history | As a user, I want to see all my saved resumes | List populated from Firestore, sorted by modified date desc |
| US-12 | Delete resume | As a user, I want to delete a resume I no longer need | Deleted from Firestore with confirmation, list updates |
| US-13 | Share PDF | As a user, I want to share my resume PDF via email/messaging | iOS: AirDrop/Mail, Android: Gmail/Drive native share |
| US-14 | Offline support | As a user, I want to view my cached resumes without internet | Firestore offline persistence loads cached resumes |

---

## 10. Out of Scope (MVP)

- In-app payments / subscription tiers
- Cover letters
- LinkedIn sync / import
- Real-time collaboration
- Custom template creation
- Font customization
- Video resume
- Job application tracking
- Web version
- Desktop native app

---

## 11. Technical Stack Summary

| Layer | Technology |
|-------|------------|
| **Presentation** | Flutter 3.19+, Riverpod (state), GoRouter (navigation) |
| **Domain** | Pure Dart (no dependencies) |
| **Data** | Freezed (models), json_serializable, Mappers |
| **Remote** | Firebase Auth, Firestore, OpenAI REST API |
| **Local** | Hive (resume cache for offline) |
| **PDF** | `pdf` package (generation), `printing` package (share) |
| **Other** | flutter_dotenv (.env loading), fpdart (Either/Failure) |

---

## 12. Development Phases

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| **1. Setup** | 1–2 days | Firebase + Riverpod boilerplate, project structure |
| **2. Domain Layer** | 2–3 days | Entities, repositories (abstract), use cases |
| **3. Auth** | 2–3 days | Firebase Auth integration, sign up/sign in screens |
| **4. Resume Form UI** | 2–4 days | Multi-step form, live preview widget |
| **5. OpenAI Integration** | 3–4 days | Datasource, repository impl, providers for AI calls |
| **6. PDF Export** | 3–5 days | PDF service, three templates, export provider |
| **7. Firestore Sync** | 2–3 days | Save/load/delete resumes, history screen |
| **8. Polish & Testing** | 2–4 days | Error handling, edge cases, unit tests, responsive UI |
| **9. Deploy** | 1 day | TestFlight (iOS), Internal Testing (Android) |
| **Total** | **14–22 days** | Production-ready MVP |

---

## 13. Success Metrics

- Users can complete a full resume creation → export cycle in <10 minutes
- API call success rate >95%
- <5% crash rate on any workflow
- PDF export on first try for all templates
- Firestore sync latency <2 seconds
- User can view history without internet (cached)

---

## 14. Deployment Targets

**iOS:** App Store (requires TestFlight approval)  
**Android:** Google Play Store (requires Play Console approval)  
**Minimum Versions:**
- iOS 14+
- Android 5.1+ (API 21+)

---

## 15. Environment Variables (.env)

```
OPENAI_API_KEY=sk-...
FIREBASE_PROJECT_ID=your-project-id
```

Assert non-null at startup — crash with clear error if missing.

---

## Appendix: API Request/Response Examples

### OpenAI: Generate Summary

**Request:**
```json
{
  "model": "gpt-4o",
  "max_tokens": 1500,
  "temperature": 0.7,
  "messages": [
    {
      "role": "system",
      "content": "You are a professional resume writer. Respond ONLY with valid JSON."
    },
    {
      "role": "user",
      "content": "Generate a professional summary from this work history: [work history text]. Return JSON: {\"summary\": \"...\"}."
    }
  ]
}
```

**Response:**
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "gpt-4o",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "{\"summary\": \"Results-driven software engineer with 5+ years of experience in mobile and backend development. Proven track record of delivering scalable solutions and leading cross-functional teams.\"}"
      }
    }
  ]
}
```

---

**End of SRS**
