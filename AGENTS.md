# AGENTS.md — AI Resume Builder

> Instructions for OpenAI Codex and compatible coding agents working on this project.
> Read this entire file before writing or modifying any code.

---

## Project Overview

**App Name:** AI Resume Builder
**Platform:** Flutter (iOS + Android — mobile only)
**Language:** Dart 3.3+
**Architecture:** Clean Architecture (Domain → Data → Presentation)
**State Management:** Riverpod with code generation (`@riverpod`)
**AI Backend:** OpenAI GPT-4o (`/v1/chat/completions`)
**Cloud:** Firebase (Auth + Firestore + Storage)
**PDF Export:** `pdf` + `printing` Flutter packages
**Min Flutter SDK:** 3.19.0

---

## Architecture Overview

This project follows **Clean Architecture**. Before writing any code, understand the three layers and their strict rules:

```
Presentation  ──►  Domain  ◄──  Data
```

### Layer 1: `domain/` — Pure Business Logic
- Contains: **entities**, **repository interfaces**, **use cases**
- **Zero** external dependencies — no Flutter, no Firebase, no OpenAI, no Riverpod
- This layer never changes because of a Firebase update or an API change

### Layer 2: `data/` — External World Adapter
- Contains: **models (DTOs)**, **mappers**, **datasources**, **repository implementations**
- Knows about Firebase, OpenAI, Hive — but depends on `domain/` for interfaces
- Never imported by `presentation/`

### Layer 3: `presentation/` — UI Layer
- Contains: **Riverpod providers**, **screens**, **widgets**
- Depends on `domain/` only — never imports from `data/`
- Providers call use cases; screens observe providers

**The golden rule: dependencies always point inward. `domain/` never imports from `data/` or `presentation/`.**

---

## Full Project Structure

```
lib/
├── main.dart
├── app/
│   └── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_sizes.dart
│   ├── errors/
│   │   ├── failure.dart                        # Sealed Failure class
│   │   └── app_exception.dart
│   ├── extensions/
│   ├── network/
│   │   └── network_info.dart
│   └── utils/
│
├── domain/
│   ├── entities/
│   │   ├── resume.dart
│   │   ├── work_experience.dart
│   │   ├── education.dart
│   │   ├── skill.dart
│   │   └── user_profile.dart
│   ├── repositories/
│   │   ├── resume_repository.dart              # abstract interface
│   │   ├── auth_repository.dart                # abstract interface
│   │   └── ai_repository.dart                  # abstract interface
│   └── usecases/
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
├── data/
│   ├── models/
│   │   ├── resume_model.dart
│   │   ├── work_experience_model.dart
│   │   ├── education_model.dart
│   │   ├── skill_model.dart
│   │   └── user_profile_model.dart
│   ├── mappers/
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
│   │       └── resume_local_datasource.dart
│   └── repositories/
│       ├── resume_repository_impl.dart
│       ├── auth_repository_impl.dart
│       └── ai_repository_impl.dart
│
├── presentation/
│   ├── providers/
│   │   ├── auth/auth_provider.dart
│   │   ├── resume/
│   │   │   ├── resume_list_provider.dart
│   │   │   └── resume_form_provider.dart
│   │   ├── ai/ai_suggestions_provider.dart
│   │   └── pdf/pdf_export_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── resume_builder/
│   │   ├── templates/
│   │   └── history/
│   └── widgets/
│       ├── shared/
│       ├── resume/
│       └── templates/
│
└── injection/
    └── injection_container.dart
```

---

## Agent Rules — Before Writing Code

1. Identify which layer the task belongs to: `domain`, `data`, or `presentation`.
2. Check if an entity, model, use case, or widget for this feature already exists.
3. Never create a new file without first reading the existing file in that directory.
4. If touching a Freezed model, do not edit `*.freezed.dart` or `*.g.dart` — they are generated.
5. If the task spans multiple layers, start from `domain/` and work outward.
6. Do not generate any Documents until asked to do, and if asked to make a document then make it ./openai/docs/module/(here)
7. Always use sub agents where you can and sub agents should work in the background
8. You have permission to create and update files, for commands ask for permission if changing something critical

---

## Domain Layer Rules

### Entities
- Plain Dart classes only. No imports from any external package.
- Must implement `==`, `hashCode`, and `copyWith` manually (or use `equatable`).
- No `toJson` / `fromJson` — serialization belongs in `data/models/`.

```dart
// domain/entities/resume.dart
class Resume {
  final String id;
  final String userId;
  final String title;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<Skill> skills;
  final String summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    required this.workExperience,
    required this.education,
    required this.skills,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  Resume copyWith({ ... }) { ... }

  @override
  bool operator ==(Object other) => other is Resume && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

### Repository Interfaces
- Abstract classes only. No implementation logic.
- Return `Future<Either<Failure, T>>` for all operations.

```dart
// domain/repositories/resume_repository.dart
abstract interface class ResumeRepository {
  Future<Either<Failure, Resume>> createResume(Resume resume);
  Future<Either<Failure, Resume>> updateResume(Resume resume);
  Future<Either<Failure, void>> deleteResume(String id);
  Future<Either<Failure, Resume>> getResume(String id);
  Future<Either<Failure, List<Resume>>> getAllResumes(String userId);
}
```

### Use Cases
- One class, one `call()` method.
- Accept entities as input parameters, return `Either<Failure, T>`.
- Delegate to the repository — no business logic beyond orchestration.

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

## Data Layer Rules

### Models (DTOs)
- Use `@freezed` with `@JsonSerializable()`.
- Have `toJson()` / `fromJson()` for Firestore serialization.
- NEVER imported in `domain/` or `presentation/`.

### Mappers
- One mapper per entity/model pair.
- Two methods: `toEntity(Model) → Entity` and `toModel(Entity) → Model`.
- All mapping logic lives here — never inline anywhere else.

```dart
// data/mappers/resume_mapper.dart
class ResumeMapper {
  const ResumeMapper();

  Resume toEntity(ResumeModel model) => Resume(
        id: model.id,
        userId: model.userId,
        title: model.title,
        workExperience: model.workExperience
            .map(const WorkExperienceMapper().toEntity)
            .toList(),
        // ...
      );

  ResumeModel toModel(Resume entity) => ResumeModel(
        id: entity.id,
        userId: entity.userId,
        title: entity.title,
        // ...
      );
}
```

### Datasources
- `FirebaseFirestore.instance` is called ONLY here — never outside datasources.
- Throw `AppException` on failure — let repository impl catch and map to `Failure`.
- Collection names from `AppStrings` — never hardcode `'resumes'`.

### Repository Implementations
- Implement the domain interface.
- Coordinate between remote datasource and local cache.
- Catch raw exceptions and return `Left(Failure)` — never rethrow raw exceptions.

---

## Presentation Layer Rules

### Providers
- Use `@riverpod` annotation only — no manual `Provider()`.
- Every provider file declares `part 'filename.g.dart';`
- Inject use cases from `injection_container.dart` via `ref.watch`.
- Fold `Either` results: throw `Failure` on left so Riverpod exposes it as `AsyncError`.

```dart
// presentation/providers/resume/resume_list_provider.dart
part 'resume_list_provider.g.dart';

@riverpod
Future<List<Resume>> resumeList(ResumeListRef ref) async {
  final useCase = ref.watch(getAllResumesUseCaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await useCase(userId);
  return result.fold(
    (failure) => throw failure,
    (resumes) => resumes,
  );
}
```

### Screens
- Observe providers with `ref.watch` — never call use cases directly.
- Always handle `AsyncValue.loading`, `AsyncValue.error`, `AsyncValue.data`.
- All `Scaffold` widgets: `resizeToAvoidBottomInset: true`.
- Use `AppColors`, `AppStrings`, `AppSizes` — never hardcode.

### Widgets
- No logic — pure rendering based on input parameters.
- Loading states: `LoadingOverlay` widget only.
- All `TextFormField`: requires `textInputAction` + `onEditingComplete`.

---

## Error Handling

`Failure` sealed class (`core/errors/failure.dart`):

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class ServerFailure extends Failure { const ServerFailure(super.message); }
final class NetworkFailure extends Failure { const NetworkFailure(super.message); }
final class CacheFailure extends Failure { const CacheFailure(super.message); }
final class AuthFailure extends Failure { const AuthFailure(super.message); }
final class PdfFailure extends Failure { const PdfFailure(super.message); }
```

Flow: `AppException` (raw) → caught in repository impl → mapped to `Failure` → returned as `Left` → folded in provider → thrown as `AsyncError` → displayed in UI.

---

## OpenAI Datasource Rules

- API key from `.env` via `flutter_dotenv` — never in source code.
- Every call: `model: gpt-4o`, `max_tokens: 1500`.
- For structured JSON output: `temperature: 0.2` + system message:
  ```
  You are a professional resume writer.
  Respond ONLY with a valid JSON object.
  Do not include markdown, backticks, or any explanation.
  Return raw JSON only.
  ```
- Parse with `jsonDecode()` in try/catch — throw `AppException` on failure.
- Handle HTTP errors: `400`, `401`, `429`, `500`, `503` — map each to correct `Failure` type.

---

## PDF Rules

- `ResumeTemplate` enum in `domain/`: `{ classic, modern, minimal }`.
- PDF logic in `data/services/pdf_service.dart` — called only by `ExportPdfUseCase`.
- Fonts from `assets/fonts/` — never system fonts.
- Page size A4, handle multi-page overflow — never assume single page.
- iOS sharing: `Printing.sharePdf()` — do not use `path_provider` + `Share` for PDFs on iOS.
- PDF failures map to `PdfFailure`.

---

## Dependency Injection

All wiring in `injection/injection_container.dart`. Build order:

```
Datasources → Mappers → Repositories → UseCases → Feature Providers
```

```dart
// injection/injection_container.dart
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

| Type                  | Suffix                   | Example                              |
|-----------------------|--------------------------|--------------------------------------|
| Entity                | `*.dart`                 | `resume.dart`                        |
| Model                 | `*_model.dart`           | `resume_model.dart`                  |
| Mapper                | `*_mapper.dart`          | `resume_mapper.dart`                 |
| Repository (abstract) | `*_repository.dart`      | `resume_repository.dart`             |
| Repository (impl)     | `*_repository_impl.dart` | `resume_repository_impl.dart`        |
| Datasource            | `*_datasource.dart`      | `firestore_resume_datasource.dart`   |
| Use Case              | `*_usecase.dart`         | `create_resume_usecase.dart`         |
| Provider              | `*_provider.dart`        | `resume_list_provider.dart`          |
| Screen                | `*_screen.dart`          | `builder_screen.dart`                |
| Widget                | `*_widget.dart`          | `app_button.dart`                    |

---

## Commit Message Format

```
type(scope): short description

Types: feat | fix | refactor | test | chore | docs
Scopes: domain | data | presentation | injection | core | auth | resume | ai | pdf

Examples:
  feat(domain): add GenerateSummaryUseCase
  feat(data): implement OpenAI datasource
  fix(pdf): handle overflow on classic template
  refactor(presentation): split resume form into sub-providers
  test(domain): add unit tests for CreateResumeUseCase
```

---

## Testing Requirements

| Layer        | What to test                                     | Tool      |
|--------------|--------------------------------------------------|-----------|
| Domain       | All use cases — mock repository, both Left/Right | `mocktail`|
| Data         | Repository impls, all mappers, datasources       | `mocktail`|
| Presentation | Providers with mocked use cases, key screens     | `mocktail` + `flutter_test` |

- Mappers require 100% branch coverage — they are silent failure points.
- Use case tests must cover both success and failure paths.
- Test file mirrors `lib/` path under `test/`:
  - `lib/domain/usecases/resume/create_resume_usecase.dart`
  - → `test/domain/usecases/resume/create_resume_usecase_test.dart`

---

## Agent Submission Checklist

Before submitting any changes, verify:

- [ ] `flutter analyze` — zero errors or warnings
- [ ] `dart format lib/ test/` — applied
- [ ] `domain/` has zero imports from `data/`, `presentation/`, Firebase, or OpenAI
- [ ] `presentation/` has zero imports from `data/`
- [ ] All new use cases return `Either<Failure, T>`
- [ ] All new models use `@freezed` + `@JsonSerializable`
- [ ] All new entities have no serialization code
- [ ] Mappers written and tested for new model/entity pairs
- [ ] New DI wiring added to `injection_container.dart`
- [ ] No hardcoded colors, sizes, strings, or API keys anywhere
- [ ] Unit tests written for new use cases and mappers
- [ ] `flutter test` — all tests pass

---

## Out of Scope — Do Not Implement

- Web or desktop Flutter targets
- Offline AI / local LLM
- Real-time collaboration
- Custom user font upload
- In-app purchases or payment flows
- Admin dashboard

---

## Quick Commands

```bash
# Dependencies
flutter pub get

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run

# Test with coverage
flutter test --coverage

# Analyze
flutter analyze

# Format
dart format lib/ test/

# Check outdated packages
flutter pub outdated
```
