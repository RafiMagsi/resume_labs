# Resume Labs AI (AI Resume Builder)

Flutter (iOS + Android) app for building resumes, saving to Firebase, and exporting PDFs.

## Prerequisites
- Flutter SDK: `>=3.19.0` (Dart `>=3.3.0`)
- Firebase project (Auth + Firestore + Storage)
- OpenAI API key (for AI suggestions)

## Setup
1. Install dependencies:
   - `flutter pub get`
2. Create `.env` (this file is gitignored):
   - `OPENAI_API_KEY=your_key_here`
   - `FIREBASE_PROJECT_ID=your_firebase_project_id`
3. Add Firebase config files (gitignored):
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Run codegen when needed:
   - `flutter pub run build_runner build --delete-conflicting-outputs`

## Run
- `flutter run`

## Tests
- Unit/widget tests: `flutter test`
- Provider tests only: `flutter test test/presentation/providers`
- Coverage: `flutter test --coverage` (outputs `coverage/lcov.info`)

## API integrations
### OpenAI
- API key is loaded from `.env` via `flutter_dotenv`.
- AI calls are implemented in `lib/data/datasources/remote/openai_datasource_impl.dart`.

### Firebase
- Auth + Firestore are used for user accounts and resume storage.
- Firestore rules live in `firebase/firestore.rules`.
- Composite indexes live in `firebase/firestore.indexes.json` (wired in `firebase.json`).

## Build & release
### Android (release)
1. Create a keystore (keep it private) and configure signing in `android/app/build.gradle`.
2. Ensure Firebase config matches your Android application id:
   - Current `applicationId`: `com.nextfiction.resume-labs` (see `android/app/build.gradle.kts`)
   - If you change it, regenerate `android/app/google-services.json` from Firebase Console.
3. Build:
   - `flutter build apk --release`
   - (or) `flutter build appbundle --release`

### iOS (release)
- Configure signing/provisioning in Xcode, then:
  - `flutter build ipa --release`

## Security
- Firestore rules enforce that users can only read/write their own resumes.

## Code quality
- Analyze:
  - `flutter analyze`
  - `dart analyze`
- Format:
  - `dart format lib/ test/ integration_test/`
- Autofix:
  - `dart fix --apply`
