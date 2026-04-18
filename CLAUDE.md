# CLAUDE.md — AI Resume Builder

> Instructions for Claude (Claude Code / Anthropic agent) working on this project.
> Read this file fully before making any changes to the codebase.

---

## Project Overview

**App Name:** AI Resume Builder
**Platform:** Flutter (iOS + Android — mobile only)
**Language:** Dart 3.3+
**Architecture:** Clean Architecture (Domain → Data → Presentation)
**State Management:** Riverpod with code generation (`@riverpod`)
**AI Backend:** OpenAI GPT-4o (`/v1/chat/completions`)
**Cloud:** Firebase (Auth + Firestore + Storage)
**PDF Export:** `pdf` + `printing` packages
**Min Flutter SDK:** 3.19.0
**Dart SDK:** >=3.3.0 <4.0.0

---

## Clean Architecture — Dependency Rule

This is the single most important rule in this codebase:

```
Presentation → Domain ← Data
```

- `domain/` has ZERO dependencies on Flutter, Firebase, OpenAI, or any external package.
- `data/` depends on `domain/` (implements its interfaces).
- `presentation/` depends on `domain/` (calls use cases — never services or datasources directly).
- Dependencies always point inward — never outward.
- If you find yourself importing a Firebase or OpenAI class inside `domain/`, stop immediately. You are violating the architecture.

---

## Full Folder Structure

```
lib/
├── main.dart                                   # Entry point — loads .env, initializes Firebase
├── app/
│   └── app.dart                                # Root: ProviderScope > MaterialApp + GoRouter
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_sizes.dart
│   ├── errors/
│   │   ├── failure.dart                        # Sealed class: ServerFailure | NetworkFailure | CacheFailure | PdfFailure | AuthFailure
│   │   └── app_exception.dart                  # Raw exception wrapper before mapping to Failure
│   ├── extensions/
│   │   ├── string_extensions.dart
│   │   └── list_extensions.dart
│   ├── network/
│   │   └── network_info.dart                   # Abstract interface + ConnectivityImpl
│   └── utils/
│       ├── input_validators.dart
│       └── date_formatter.dart
│
├── domain/                                     # PURE DART — zero Flutter/Firebase/OpenAI imports
│   ├── entities/                               # Plain Dart classes — no toJson, no framework code
│   │   ├── resume.dart
│   │   ├── work_experience.dart
│   │   ├── education.dart
│   │   ├── skill.dart
│   │   └── user_profile.dart
│   ├── repositories/                           # Abstract interfaces ONLY — no implementations
│   │   ├── resume_repository.dart
│   │   ├── auth_repository.dart
│   │   └── ai_repository.dart
│   └── usecases/                               # One class, one call() method per use case
│       ├── resume/
│       │   ├── create_resume_usecase.dart
│       │   ├── update_resume_usecase.dart
│       │   ├── delete_resume_usecase.dart
│       │   ├── get_resume_usecase.dart
│       │   └── get_all_resumes_usecase.dart
│       ├── ai/
│       │   ├── generate_summary_usecase.dart
│       │   ├── improve_bullet_usecase.dart
│       │   └── suggest_skills_usecase.dart
│       ├── auth/
│       │   ├── sign_in_usecase.dart
│       │   ├── sign_up_usecase.dart
│       │   └── sign_out_usecase.dart
│       └── pdf/
│           └── export_pdf_usecase.dart
│
├── data/                                       # Implements domain interfaces — knows about Firebase/OpenAI
│   ├── models/                                 # DTOs: Freezed + json_serializable
│   │   ├── resume_model.dart
│   │   ├── work_experience_model.dart
│   │   ├── education_model.dart
│   │   ├── skill_model.dart
│   │   └── user_profile_model.dart
│   ├── mappers/                                # Model ↔ Entity conversion — all mapping logic lives here
│   │   ├── resume_mapper.dart
│   │   ├── work_experience_mapper.dart
│   │   ├── education_mapper.dart
│   │   └── skill_mapper.dart
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── firebase_auth_datasource.dart
│   │   │   ├── firestore_resume_datasource.dart
│   │   │   └── openai_datasource.dart
│   │   └── local/
│   │       └── resume_local_datasource.dart    # Hive cache for offline support
│   └── repositories/                           # Concrete implementations of domain interfaces
│       ├── resume_repository_impl.dart
│       ├── auth_repository_impl.dart
│       └── ai_repository_impl.dart
│
├── presentation/                               # Flutter UI — screens, widgets, Riverpod providers
│   ├── providers/
│   │   ├── auth/
│   │   │   └── auth_provider.dart
│   │   ├── resume/
│   │   │   ├── resume_list_provider.dart
│   │   │   └── resume_form_provider.dart
│   │   ├── ai/
│   │   │   └── ai_suggestions_provider.dart
│   │   └── pdf/
│   │       └── pdf_export_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── resume_builder/
│   │   │   ├── builder_screen.dart
│   │   │   └── preview_screen.dart
│   │   ├── templates/
│   │   │   └── template_picker_screen.dart
│   │   └── history/
│   │       └── history_screen.dart
│   └── widgets/
│       ├── shared/
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   └── loading_overlay.dart
│       ├── resume/
│       │   ├── section_form.dart
│       │   └── resume_preview.dart
│       └── templates/
│           ├── classic_template.dart
│           ├── modern_template.dart
│           └── minimal_template.dart
│
└── injection/
    └── injection_container.dart                # All DI wiring — single source of truth
```

---

## Layer Responsibilities

### `domain/` — The Heart of the App

- **Pure Dart only.** No external package imports — not even `flutter/material.dart`.
- **Entities** are plain Dart classes with `==`, `hashCode`, and `copyWith`. No `toJson`/`fromJson`.
- **Repository interfaces** define *what* the app can do — not *how*. One abstract method per operation.
- **Use cases** contain all business logic. Each is a class with a single `call()` method that returns `Either<Failure, T>` via `fpdart`.

```dart
// domain/usecases/resume/create_resume_usecase.dart
class CreateResumeUseCase {
  final ResumeRepository _repository;
  const CreateResumeUseCase(this._repository);

  Future<Either<Failure, Resume>> call(Resume resume) =>
      _repository.createResume(resume);
}
```

---

### `data/` — External World Adapter

- **Models** are Freezed DTOs. They have `toJson`/`fromJson`. They are NEVER used in `domain/` or `presentation/`.
- **Mappers** convert `Model ↔ Entity`. All mapping is isolated here — never inline in repositories or datasources.
- **Datasources** are the ONLY classes allowed to call Firebase, OpenAI, or local storage directly.
- **Repository implementations** coordinate remote + local datasources, catch raw exceptions, and map to `Failure`.

```dart
// data/repositories/resume_repository_impl.dart
class ResumeRepositoryImpl implements ResumeRepository {
  final FirestoreResumeDatasource _remote;
  final ResumeLocalDatasource _local;
  final ResumeMapper _mapper;

  const ResumeRepositoryImpl({
    required FirestoreResumeDatasource remote,
    required ResumeLocalDatasource local,
    required ResumeMapper mapper,
  })  : _remote = remote,
        _local = local,
        _mapper = mapper;

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      final model = _mapper.toModel(resume);
      final saved = await _remote.create(model);
      await _local.cache(saved);
      return Right(_mapper.toEntity(saved));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } on SocketException {
      return Left(const NetworkFailure('No internet connection'));
    }
  }
}
```

---

### `presentation/` — UI Only

- **Providers** inject use cases — never repositories, datasources, or Firebase directly.
- **Screens** observe providers — they never call use cases directly.
- No business logic in widgets or providers. A provider's only job: call a use case and expose the result as `AsyncValue<T>`.

```dart
// presentation/providers/resume/resume_list_provider.dart
part 'resume_list_provider.g.dart';

@riverpod
Future<List<Resume>> resumeList(ResumeListRef ref) async {
  final useCase = ref.watch(getAllResumesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (resumes) => resumes,
  );
}
```

---

## Entities vs Models — Critical Distinction

| Concern          | Entity (`domain/`)       | Model (`data/`)               |
|------------------|--------------------------|-------------------------------|
| Location         | `domain/entities/`       | `data/models/`                |
| Purpose          | Business object          | Serialization / persistence   |
| Serialization    | None                     | `toJson` / `fromJson`         |
| Framework deps   | None                     | `freezed`, `json_serializable`|
| Used in          | Domain, Presentation     | Data layer only               |
| Passed to usecase| YES                      | NO — map first                |

**Never** pass a Model into a use case.
**Never** return a Model from a repository.
**Never** use an Entity in a datasource.

---

## Error Handling

Use `Either<Failure, T>` from `fpdart` for all use case return types.

`Failure` sealed class in `core/errors/failure.dart`:

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
final class PdfFailure extends Failure {
  const PdfFailure(super.message);
}
```

- Repository impls catch raw exceptions and return typed `Left(Failure)`.
- Use cases propagate the `Either` — they never catch exceptions themselves.
- Providers `fold` the `Either`: throw the failure so Riverpod exposes it as `AsyncError`.
- UI reads `AsyncValue.error` and shows user-friendly messages from `AppStrings`.

---

## Coding Rules

### General
- Never use `!` force-unwrap unless null is provably impossible — add a comment explaining why.
- Use `const` wherever the compiler allows.
- No `print()` — use `debugPrint()` in dev only.
- Every public class and method must have a `///` doc comment.
- Max line length: 100 characters.
- Run `dart fix --apply` and `dart format lib/ test/` after every change.

### Riverpod
- `@riverpod` annotation only — no manual `Provider()`, `StateNotifierProvider`, etc.
- Every provider file declares: `part 'filename.g.dart';`
- Use cases are provided from `injection/injection_container.dart` and watched inside feature providers.
- `keepAlive: true` for auth, repository, and use case providers. Default (auto-dispose) for UI state.

### OpenAI Datasource
- API key from `.env` via `flutter_dotenv` — never hardcoded.
- Default params: `model: gpt-4o`, `max_tokens: 1500`, `temperature: 0.7`.
- Structured output calls: `temperature: 0.2` + system message:
  ```
  Respond ONLY with a valid JSON object. No markdown, no backticks, no explanation.
  ```
- Parse with `jsonDecode()` in try/catch — throw `AppException` on parse failure.
- Handle HTTP errors explicitly: `400`, `401`, `429`, `500`, `503`.

### Firebase Datasources
- `FirebaseFirestore.instance` is called ONLY inside datasource files.
- Collection name constants in `AppStrings` — never hardcode `'resumes'` etc.
- Firestore offline persistence enabled — catch error code `unavailable`, return local cache.

### PDF (`ExportPdfUseCase` → calls `PdfService` in `data/`)
- `ResumeTemplate` enum lives in `domain/` — `{ classic, modern, minimal }`.
- Fonts loaded from `assets/fonts/` — never system fonts.
- iOS sharing: `Printing.sharePdf()` only.
- Always handle multi-page overflow — never assume A4 single-page fits.
- Test PDF output on a real device or simulator before marking done.

### UI
- No hardcoded colors, sizes, or strings — use `AppColors`, `AppSizes`, `AppStrings`.
- Loading states use `LoadingOverlay` widget only — no custom loaders per screen.
- All `Scaffold` screens: `resizeToAvoidBottomInset: true`.
- All `TextFormField`: `textInputAction` + `onEditingComplete` required.

---

## Dependency Injection

All wiring in `injection/injection_container.dart`. Providers follow this top-down order:

```
Datasources → Repositories → Use Cases → Feature Providers
```

```dart
// injection/injection_container.dart

@Riverpod(keepAlive: true)
FirestoreResumeDatasource firestoreResumeDatasource(FirestoreResumeDatasourceRef ref) =>
    FirestoreResumeDatasourceImpl();

@Riverpod(keepAlive: true)
ResumeRepository resumeRepository(ResumeRepositoryRef ref) =>
    ResumeRepositoryImpl(
      remote: ref.watch(firestoreResumeDatasourceProvider),
      local: ref.watch(resumeLocalDatasourceProvider),
      mapper: const ResumeMapper(),
    );

@Riverpod(keepAlive: true)
CreateResumeUseCase createResumeUseCase(CreateResumeUseCaseRef ref) =>
    CreateResumeUseCase(ref.watch(resumeRepositoryProvider));
```

---

## File Naming Conventions

| Type                  | Suffix                   | Example                             |
|-----------------------|--------------------------|-------------------------------------|
| Entity                | `*.dart`                 | `resume.dart`                       |
| Model (DTO)           | `*_model.dart`           | `resume_model.dart`                 |
| Mapper                | `*_mapper.dart`          | `resume_mapper.dart`                |
| Repository (abstract) | `*_repository.dart`      | `resume_repository.dart`            |
| Repository (impl)     | `*_repository_impl.dart` | `resume_repository_impl.dart`       |
| Datasource            | `*_datasource.dart`      | `firestore_resume_datasource.dart`  |
| Use Case              | `*_usecase.dart`         | `create_resume_usecase.dart`        |
| Provider              | `*_provider.dart`        | `resume_list_provider.dart`         |
| Screen                | `*_screen.dart`          | `builder_screen.dart`               |
| Widget                | `*_widget.dart`          | `app_button.dart`                   |

---

## Testing Strategy

| Layer        | What to test                              | Mocking tool |
|--------------|-------------------------------------------|--------------|
| Domain       | All use cases with mocked repositories    | `mocktail`   |
| Data         | Repository impls, mappers, datasources    | `mocktail`   |
| Presentation | Providers (with mocked use cases), screens| `mocktail` + `flutter_test` |

- Mappers must have 100% test coverage — they are silent failure points.
- Use case tests must cover both `Left` (failure) and `Right` (success) paths.
- Test files mirror `lib/` structure under `test/`.
- Run `flutter test --coverage` before every commit.

---

## Environment & Secrets

`.env` (gitignored) in project root:

```
OPENAI_API_KEY=sk-...
FIREBASE_PROJECT_ID=your-project-id
```

Assert non-null in `main.dart`. Crash fast with a clear error if missing.

---

## Gitignore Additions

```
.env
google-services.json
GoogleService-Info.plist
*.g.dart
*.freezed.dart
```

---

## Out of Scope — Do Not Implement

- Web or desktop Flutter targets
- Offline AI / local LLM
- Real-time collaboration
- Custom user font upload
- In-app purchases or payment flows

---

## Quick Commands

```bash
# Dependencies
flutter pub get

# Code generation (Freezed + Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run

# Test with coverage
flutter test --coverage

# Analyze
flutter analyze

# Format
dart format lib/ test/
```
