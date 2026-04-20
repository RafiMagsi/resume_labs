# ResumeAI — Development Plan

**Project:** AI Resume Builder (Flutter)  
**Architecture:** Clean Architecture (Domain → Data → Presentation)  
**Timeline:** 14–22 days (MVP)  
**Last Updated:** April 18, 2026

---

## Phase 1: Project Setup & Infrastructure (1–2 days)

### 1.1 Environment & Dependencies
- [ ] Set up `.env` file with OPENAI_API_KEY and FIREBASE_PROJECT_ID placeholders
- [ ] Configure `pubspec.yaml` with all required dependencies (flutter_dotenv, firebase, riverpod, freezed, fpdart, pdf, printing, hive, connectivity_plus)
- [ ] Run `flutter pub get` and verify no version conflicts
- [ ] Set up `.gitignore` to exclude `.env`, `google-services.json`, `*.g.dart`, `*.freezed.dart`

### 1.2 Firebase Setup
- [ ] Create Firebase project in Firebase Console
- [ ] Enable Firebase Authentication (Email/Password provider)
- [ ] Create Firestore database (production mode with security rules)
- [ ] Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Copy to `android/app/` and `ios/Runner/` respectively
- [ ] Configure Firebase iOS pods in `ios/Podfile` (if needed)

### 1.3 Project Structure & Boilerplate
- [ ] Create folder structure:
  - `lib/core/constants/`
  - `lib/core/errors/`
  - `lib/core/extensions/`
  - `lib/core/network/`
  - `lib/core/utils/`
  - `lib/domain/`
  - `lib/data/`
  - `lib/presentation/`
  - `lib/injection/`
- [ ] Create modern theme foundation in `core/constants/`:
  - `app_colors.dart`
  - `app_strings.dart`
  - `app_sizes.dart`
- [ ] Create error primitives in `core/errors/`:
  - `failure.dart` (sealed failure hierarchy)
  - `app_exception.dart` (typed app exceptions)
- [ ] Create reusable extensions in `core/extensions/`:
  - `string_extensions.dart`
  - `list_extensions.dart`
- [ ] Create network contracts in `core/network/`:
  - `network_info.dart` (abstract)
  - `network_info_impl.dart`
- [ ] Create shared helpers in `core/utils/`:
  - `input_validators.dart`
  - `date_formatter.dart`
  - keep all helpers framework-agnostic where possible

### 1.4 Main App Boilerplate
- [ ] Create `app/app.dart` with ProviderScope > MaterialApp + GoRouter structure
- [ ] Create `main.dart` with `.env` loading and Firebase initialization
- [ ] Assert non-null for OPENAI_API_KEY and FIREBASE_PROJECT_ID
- [ ] Set up GoRouter with basic route structure (auth routes, builder routes, history)
- [ ] Verify app runs without errors (shows splash/login)

---

## Phase 2: Domain Layer (2–3 days)

### 2.1 Core Entities
- [ ] Create `domain/entities/resume.dart` (id, userId, title, personalSummary, workExperiences, educations, skills, createdAt, updatedAt)
- [ ] Create `domain/entities/work_experience.dart` (company, role, location, startDate, endDate, bulletPoints, isCurrentRole)
- [ ] Create `domain/entities/education.dart` (school, degree, field, graduationDate, gpa)
- [ ] Create `domain/entities/skill.dart` (name, category)
- [ ] Create `domain/entities/user_profile.dart` (uid, email, createdAt)
- [ ] Add `==`, `hashCode`, and `copyWith` to all entities

### 2.2 Repository Interfaces (Abstract)
- [ ] Create `domain/repositories/resume_repository.dart` (CRUD + list)
- [ ] Create `domain/repositories/auth_repository.dart` (sign up, sign in, sign out, reset password, get current user)
- [ ] Create `domain/repositories/ai_repository.dart` (generate summary, improve bullet, suggest skills)

### 2.3 Use Cases
- [ ] Create `domain/usecases/resume/create_resume_usecase.dart`
- [ ] Create `domain/usecases/resume/update_resume_usecase.dart`
- [ ] Create `domain/usecases/resume/delete_resume_usecase.dart`
- [ ] Create `domain/usecases/resume/get_resume_usecase.dart`
- [ ] Create `domain/usecases/resume/get_all_resumes_usecase.dart`
- [ ] Create `domain/usecases/auth/sign_up_usecase.dart`
- [ ] Create `domain/usecases/auth/sign_in_usecase.dart`
- [ ] Create `domain/usecases/auth/sign_out_usecase.dart`
- [ ] Create `domain/usecases/auth/get_current_user_usecase.dart`
- [ ] Create `domain/usecases/auth/reset_password_usecase.dart`
- [ ] Create `domain/usecases/ai/generate_summary_usecase.dart`
- [ ] Create `domain/usecases/ai/improve_bullet_usecase.dart`
- [ ] Create `domain/usecases/ai/suggest_skills_usecase.dart`
- [ ] Create `domain/usecases/pdf/export_pdf_usecase.dart`
- [ ] All use cases return `Future<Either<Failure, T>>`

---

## Phase 3: Data Layer — Models & Mappers (1–2 days)

### 3.1 Freezed Models (DTOs)
- [ ] Create `data/models/resume_model.dart` (with `@freezed`, `@JsonSerializable`)
- [ ] Create `data/models/work_experience_model.dart`
- [ ] Create `data/models/education_model.dart`
- [ ] Create `data/models/skill_model.dart`
- [ ] Create `data/models/user_profile_model.dart`
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### 3.2 Mappers (Model ↔ Entity)
- [ ] Create `data/mappers/resume_mapper.dart` (toModel, toEntity)
- [ ] Create `data/mappers/work_experience_mapper.dart`
- [ ] Create `data/mappers/education_mapper.dart`
- [ ] Create `data/mappers/skill_mapper.dart`
- [ ] Write comprehensive tests for all mappers (100% coverage)

---

## Phase 4: Authentication — Data Layer (2–3 days)

### 4.1 Firebase Auth Datasource
- [ ] Create `data/datasources/remote/firebase_auth_datasource.dart` (abstract)
- [ ] Implement sign up, sign in, sign out, reset password, get current user stream
- [ ] Handle FirebaseAuthException and map to typed AppException
- [ ] Validate email format and password strength (min 8 chars)

### 4.2 Auth Repository Implementation
- [ ] Create `data/repositories/auth_repository_impl.dart`
- [ ] Catch FirebaseAuthException → map to AuthFailure
- [ ] Implement stream-based current user check for auto sign-in
- [ ] Write unit tests with mocked datasource

### 4.3 Dependency Injection Setup
- [ ] Create `injection/injection_container.dart` with providers for:
  - FirebaseAuthDatasource
  - AuthRepository
  - SignUpUseCase, SignInUseCase, SignOutUseCase, GetCurrentUserUseCase, ResetPasswordUseCase

---

## Phase 5: Authentication — Presentation Layer (2–3 days)

### 5.1 Auth Providers (Riverpod)
- [ ] Create `presentation/providers/auth/auth_provider.dart` (watch current user stream, expose as AsyncValue)
- [ ] Create `presentation/providers/auth/sign_up_provider.dart` (notifier for async sign up)
- [ ] Create `presentation/providers/auth/sign_in_provider.dart` (notifier for async sign in)
- [ ] Create `presentation/providers/auth/sign_out_provider.dart` (notifier for sign out)
- [ ] Create `presentation/providers/auth/reset_password_provider.dart` (notifier)

### 5.2 Shared UI Widgets
- [ ] Create `presentation/widgets/shared/app_button.dart`
- [ ] Create `presentation/widgets/shared/app_text_field.dart` (with validation, textInputAction)
- [ ] Create `presentation/widgets/shared/loading_overlay.dart` (global loading indicator)

### 5.3 Auth Screens
- [ ] Create `presentation/screens/auth/login_screen.dart`
- [ ] Create `presentation/screens/auth/register_screen.dart`
- [ ] Create `presentation/screens/auth/password_reset_screen.dart` (optional, can be added later)
- [ ] Validate inputs before submission
- [ ] Show error dialogs on failure (map Failure → user-friendly message)
- [ ] Navigate to history screen on successful sign in

### 5.4 Routing & Auth Guard
- [ ] Update `GoRouter` to guard routes (redirect unauthenticated users to login)
- [ ] Implement auth redirect logic based on auth provider state

---

## Phase 6: Domain Layer — PDF & Resume (1 day)

### 6.1 PDF Template Enum
- [ ] Create `domain/entities/resume_template.dart` enum { classic, modern, minimal }

### 6.2 Resume Use Cases (if not already done)
- [ ] Verify all resume use cases are defined (CRUD + export)
- [ ] Verify all AI use cases are defined

---

## Phase 7: Data Layer — Firestore Resume Datasource (2–3 days)

### 7.1 Firestore Setup
- [ ] Configure Firestore security rules (users can only read/write their own resumes)
- [ ] Enable offline persistence in Firestore

### 7.2 Firestore Resume Datasource
- [ ] Create `data/datasources/remote/firestore_resume_datasource.dart` (abstract)
- [ ] Implement: create, read, update, delete, getAll (with userId filter)
- [ ] Handle FirebaseException → map to AppException
- [ ] Implement `.snapshots()` stream for real-time sync

### 7.3 Local Cache (Hive)
- [ ] Create `data/datasources/local/resume_local_datasource.dart` (abstract)
- [ ] Implement: cache write, cache read, cache clear
- [ ] Register Hive adapters for models
- [ ] Test offline load (Firestore unavailable → load from cache)

### 7.4 Resume Repository Implementation
- [ ] Create `data/repositories/resume_repository_impl.dart`
- [ ] Strategy: try remote first, fallback to cache on network error
- [ ] Catch FirebaseException → map to ServerFailure or NetworkFailure
- [ ] Cache all writes locally for offline support
- [ ] Write unit tests with mocked datasources

---

## Phase 8: Resume Data Layer — Dependency Injection (1 day)

### 8.1 Wire Up DI
- [ ] Add providers for:
  - FirestoreResumeDatasource
  - ResumeLocalDatasource
  - ResumeRepository
  - CreateResumeUseCase, UpdateResumeUseCase, DeleteResumeUseCase, GetResumeUseCase, GetAllResumesUseCase

---

## Phase 9: Resume Form — Presentation Layer (3–4 days)

### 9.1 Form Providers (Riverpod)
- [ ] Create `presentation/providers/resume/resume_form_provider.dart` (multi-step form state)
- [ ] Create `presentation/providers/resume/resume_list_provider.dart` (watch all resumes)
- [ ] Form state tracks: current step, form data, validation errors, loading state

### 9.2 Form Widgets
- [ ] Create `presentation/widgets/resume/section_form.dart` (reusable form section widget)
- [ ] Create `presentation/widgets/resume/resume_preview.dart` (live preview widget)
- [ ] Implement add/edit/remove logic for work experience, education, skills

### 9.3 Builder Screen (Multi-Step Form)
- [ ] Create `presentation/screens/resume_builder/builder_screen.dart`
- [ ] Implement 4 steps: Personal Info → Work Exp → Education → Skills
- [ ] Navigation: Back/Next buttons, Save Resume button
- [ ] Live preview updates on every field change
- [ ] Validate form before allowing Save
- [ ] On Save: call CreateResumeUseCase or UpdateResumeUseCase

### 9.4 Preview Screen
- [ ] Create `presentation/screens/resume_builder/preview_screen.dart`
- [ ] Display full resume as it appears in PDF
- [ ] Template selector dropdown (Classic | Modern | Minimal)
- [ ] "Export PDF" button, "Back to Edit" button

---

## Phase 10: OpenAI Integration — Data Layer (2–3 days)

### 10.1 OpenAI Datasource
- [ ] Create `data/datasources/remote/openai_datasource.dart` (abstract)
- [ ] Implement: generateSummary, improveBullet, suggestSkills
- [ ] Use `http` package for REST calls (or `dio` if already in pubspec)
- [ ] Load API key from `.env` via `flutter_dotenv`
- [ ] Set model: `gpt-4o`, max_tokens: `1500`, temperature: `0.7` (0.2 for structured output)
- [ ] Parse JSON responses with `jsonDecode()`, handle parse errors
- [ ] Handle HTTP errors: 401, 429, 500, 503 → throw AppException with message

### 10.2 AI Repository Implementation
- [ ] Create `data/repositories/ai_repository_impl.dart`
- [ ] Catch exceptions → map to ServerFailure or NetworkFailure
- [ ] Implement timeout logic (15 seconds max)
- [ ] Write unit tests with mocked HTTP responses

### 10.3 DI Setup
- [ ] Add providers for:
  - OpenaiDatasource
  - AiRepository
  - GenerateSummaryUseCase, ImproveBulletUseCase, SuggestSkillsUseCase

---

## Phase 11: AI Integration — Presentation Layer (1–2 days)

### 11.1 AI Providers (Riverpod)
- [ ] Create `presentation/providers/ai/ai_suggestions_provider.dart`
- [ ] Implement: generateSummary, improveBullet, suggestSkills as async providers with loading/error states

### 11.2 AI Suggestion Widgets
- [ ] Create suggestion popup/dialog widget to display AI results
- [ ] Accept/Dismiss buttons for suggestions
- [ ] Integrate into form steps (buttons next to fields that support suggestions)

### 11.3 Form Integration
- [ ] Add "Get AI Suggestion" buttons to:
  - Personal Info step (generate summary from work history)
  - Work Experience step (improve individual bullet points)
  - Skills step (suggest skills from job description input)

---

## Phase 12: PDF Export — Data Layer (2–3 days)

### 12.1 PDF Service (not a use case, helper in data layer)
- [ ] Create `data/services/pdf_service.dart` (or similar)
- [ ] Implement three template renderers: classic, modern, minimal
- [ ] Each template: A4 page, margins, fonts from assets, layout logic
- [ ] Handle multi-page overflow (sections that don't fit on one page)
- [ ] Test on real device or simulator before marking done

### 12.2 Export PDF Repository Implementation
- [ ] If needed, extend existing repository or create dedicated one
- [ ] Call PdfService to generate bytes
- [ ] Save to device storage (use `path_provider` and `permission_handler`)
- [ ] Return path or success indicator
- [ ] Catch exceptions → map to PdfFailure

---

## Phase 13: PDF Export — Presentation Layer (1–2 days)

### 13.1 PDF Export Provider
- [ ] Create `presentation/providers/pdf/pdf_export_provider.dart`
- [ ] Async provider that calls ExportPdfUseCase
- [ ] Track loading/success/error states

### 13.2 PDF Export UI
- [ ] Add "Export PDF" button to PreviewScreen
- [ ] On click: show template selector → call export provider
- [ ] Show loading overlay during export
- [ ] On success: trigger native share sheet (iOS: Printing.sharePdf, Android: share plugin)
- [ ] On error: show error dialog with retry option

---

## Phase 14: Resume History — Presentation Layer (1–2 days)

### 14.1 History Provider
- [ ] Create or update provider to watch ResumeList
- [ ] Sort by modified date (descending)

### 14.2 History Screen
- [ ] Create `presentation/screens/history/history_screen.dart`
- [ ] ListTile per resume: title, created date, modified date
- [ ] Long-press or swipe-to-delete with confirmation
- [ ] "Edit" action opens builder screen with selected resume
- [ ] "Export" action navigates to preview screen
- [ ] "New Resume" FAB button → builder screen (new)
- [ ] Pull-to-refresh syncs Firestore

### 14.3 Navigation
- [ ] Set HistoryScreen as default after login
- [ ] GoRouter: builder → preview → history (and back navigation)

---

## Phase 15: Error Handling & UX (1–2 days)

### 15.1 Error Dialog Widget
- [ ] Create `presentation/widgets/shared/error_dialog.dart`
- [ ] Display failure message + Retry/Dismiss buttons
- [ ] Map typed Failure to user-friendly AppStrings message

### 15.2 Global Error Handling
- [ ] Route provider `AsyncValue.error` states through shared `ErrorDialog` instead of ad-hoc dialogs/snackbars
- [ ] Network-related failures show Retry action that re-triggers the failed provider action or invalidates the provider
- [ ] Timeout failures show a clear user-facing message such as `Request timed out. Please try again.` and do not expose raw exception text

### 15.3 Input Validation - done
- [ ] Email validation in auth screens
- [ ] Password strength in auth screens (min 8 chars)
- [ ] Required fields in resume form (validate before Save)
- [ ] Disable buttons while loading

---

## Phase 16: Responsive Design & Polish (1–2 days)

### 16.1 Mobile Responsiveness - done
- [ ] Test all screens on portrait (phone) and landscape (tablet)
- [ ] Form steps: ensure keyboard auto-hides after input
- [ ] Preview pane: responsive on different screen sizes
- [ ] All fonts ≥12px for readability
- [ ] Color contrast ≥4.5:1 (WCAG AA)

### 16.2 Accessibility - done
- [ ] Semantic widgets, proper labels for form fields
- [ ] Keyboard navigation support
- [ ] Test with screen reader (iOS VoiceOver or Android TalkBack)

### 16.3 Polish - done
- [ ] Smooth transitions between screens
- [ ] Loading overlays with progress indicators
- [ ] Proper error messages
- [ ] Test all workflows end-to-end on device

---

## Phase 17: Unit & Widget Testing (2–3 days)

### 17.1 Domain Layer Tests - done
- [ ] All use cases: success and failure paths
- [ ] Mock repositories

### 17.2 Data Layer Tests - done
- [ ] All mappers: 100% coverage
- [ ] Repository impls: success, failure, cache fallback scenarios
- [ ] Mock datasources and external APIs

### 17.3 Presentation Layer Tests - done
- [ ] All providers: loading, success, error states
- [ ] Mock use cases
- [ ] Screens: basic rendering and navigation (if flutter_test supports)

### 17.4 Integration Tests - done
- [ ] Full flow: signup → create resume → save → export PDF
- [ ] Test on real emulator or device

### 17.5 Coverage - done
- [ ] Run `flutter test --coverage`
- [ ] Aim for >80% coverage overall, >95% on mappers

---

## Phase 18: Firebase Security Rules & Firestore Indexing (1 day)

### 18.1 Security Rules - done
- [ ] Apply rules: users can only read/write their own resumes
- [ ] Test with multiple user accounts

### 18.2 Firestore Indexes - done
- [ ] Create index on `userId` + `updatedAt` for fast retrieval
- [ ] Verify index is active in Firestore console

---

## Phase 19: Build & Deployment Prep (1–2 days) - done

### 19.1 Build Configuration
- [ ] Update app version in `pubspec.yaml`
- [ ] Configure app signing (Android keystore, iOS provisioning profiles)
- [ ] Build release APK/IPA locally and test on device

### 19.2 Code Quality
- [ ] Run `dart analyze` → fix all warnings/errors
- [ ] Run `dart format lib/ test/` → ensure consistent formatting
- [ ] Run `dart fix --apply` → apply recommended fixes

### 19.3 Documentation
- [ ] Update README with setup instructions
- [ ] Document API integrations (OpenAI, Firebase)
- [ ] Document how to run tests locally

---

## Phase 20: Beta Testing & Rollout (1–2 days)

### 20.1 TestFlight (iOS)
- [ ] Build and upload to TestFlight
- [ ] Create app listing in App Store Connect
- [ ] Add privacy policy and screenshots
- [ ] Submit for TestFlight review

### 20.2 Google Play Internal Testing (Android)
- [ ] Upload signed APK to Play Console
- [ ] Create app listing with screenshots
- [ ] Add privacy policy
- [ ] Submit for internal testing review

### 20.3 User Feedback
- [ ] Distribute links to testers
- [ ] Collect feedback on UX, crashes, API integration
- [ ] Fix critical bugs before public release

---

## Phase 21: Production Release (1 day)

### 21.1 App Store (iOS)
- [ ] Submit from TestFlight to App Store review
- [ ] Wait for approval (typically 24–48 hours)
- [ ] Release when approved

### 21.2 Google Play (Android)
- [ ] Promote from internal testing to staged rollout or full release
- [ ] Confirm all regions/devices supported
- [ ] Monitor for crashes in Play Console

---

## Key Dependencies & Sequencing

```
Phase 1 (Setup) 
  ↓
Phase 2 (Domain Layer)
  ↓
Phase 3 (Models & Mappers)
  ↓
Phase 4–5 (Auth — Data + Presentation)
  ↓
Phase 6–9 (Resume Form — Domain, Data, Presentation)
  ↓
Phase 10–11 (AI Integration — Data + Presentation)
  ↓
Phase 12–13 (PDF Export — Data + Presentation)
  ↓
Phase 14 (History & Navigation)
  ↓
Phase 15–16 (Error Handling, Polish, UX)
  ↓
Phase 17–18 (Testing, Security Rules)
  ↓
Phase 19–21 (Build, Testing, Deployment)
```

---

## Checklist Workflow

1. Create git branch for each phase
2. Check off tasks as completed
3. Run tests after each major component
4. Commit regularly with clear messages
5. Create PR when phase is complete
6. Merge after review

---

## Success Criteria

- [x] App runs on iOS 14+ and Android API 21+
- [x] Users can sign up, sign in, and persist session
- [x] Create, edit, delete, and list resumes (Firestore sync)
- [x] AI suggestions: summary, bullets, skills (OpenAI integration)
- [x] Export PDF in 3 templates (Classic, Modern, Minimal)
- [x] Share PDF via native share (iOS & Android)
- [x] Offline support: view cached resumes without internet
- [x] Error handling: user-friendly messages on all failures
- [x] Unit tests for domain + data layer (>80% coverage)
- [x] Responsive UI on phones and tablets
- [x] Accessibility: keyboard navigation, contrast, semantic widgets

### TASKS
# Replace all colors codes with Colors in the AppColors file, if color is missing in the file then add the colors in the file and use the new constant color name
# Extract all widgets from big files where you can
# Move all string constants or messages to AppStrings
# Update theme as Apple iOS style, use small border radius
# Aim for >80% coverage overall, >95% on mappers
# Create From LinkedIn (linked-in login)
# Create CV from existing docx or pdf