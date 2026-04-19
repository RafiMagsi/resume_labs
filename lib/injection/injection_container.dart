import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:resume_labs/data/repositories/pdf_repository_impl.dart';
import 'package:resume_labs/data/services/pdf_service.dart';
import 'package:resume_labs/domain/repositories/pdf_repository.dart';
import 'package:resume_labs/domain/usecases/pdf/export_pdf_usecase.dart';

import '../data/datasources/local/resume_local_datasource.dart';
import '../data/datasources/local/resume_local_datasource_impl.dart';
import '../data/datasources/remote/firebase_auth_datasource.dart';
import '../data/datasources/remote/firebase_auth_datasource_impl.dart';
import '../data/datasources/remote/firestore_resume_datasource.dart';
import '../data/datasources/remote/firestore_resume_datasource_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/resume_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/resume_repository.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/auth/reset_password_usecase.dart';
import '../domain/usecases/auth/sign_in_usecase.dart';
import '../domain/usecases/auth/sign_out_usecase.dart';
import '../domain/usecases/auth/sign_up_usecase.dart';
import '../domain/usecases/resume/create_resume_usecase.dart';
import '../domain/usecases/resume/delete_resume_usecase.dart';
import '../domain/usecases/resume/get_all_resumes_usecase.dart';
import '../domain/usecases/resume/get_resume_usecase.dart';
import '../domain/usecases/resume/update_resume_usecase.dart';

import 'package:http/http.dart' as http;

import '../data/datasources/remote/openai_datasource.dart';
import '../data/datasources/remote/openai_datasource_impl.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/usecases/ai/generate_summary_usecase.dart';
import '../domain/usecases/ai/improve_bullet_usecase.dart';
import '../domain/usecases/ai/suggest_skills_usecase.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthDataSourceImpl(firebaseAuth);
});

final firestoreResumeDataSourceProvider = Provider<FirestoreResumeDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreResumeDataSourceImpl(firestore);
});

final resumeLocalDataSourceProvider = Provider<ResumeLocalDataSource>((ref) {
  final hive = ref.watch(hiveProvider);
  return ResumeLocalDataSourceImpl(hive);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final remoteDataSource = ref.watch(firestoreResumeDataSourceProvider);
  final localDataSource = ref.watch(resumeLocalDataSourceProvider);

  return ResumeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final createResumeUseCaseProvider = Provider<CreateResumeUseCase>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return CreateResumeUseCase(repository);
});

final updateResumeUseCaseProvider = Provider<UpdateResumeUseCase>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return UpdateResumeUseCase(repository);
});

final deleteResumeUseCaseProvider = Provider<DeleteResumeUseCase>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return DeleteResumeUseCase(repository);
});

final getResumeUseCaseProvider = Provider<GetResumeUseCase>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return GetResumeUseCase(repository);
});

final getAllResumesUseCaseProvider = Provider<GetAllResumesUseCase>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return GetAllResumesUseCase(repository);
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final openAiDataSourceProvider = Provider<OpenAiDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return OpenAiDataSourceImpl(client);
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final dataSource = ref.watch(openAiDataSourceProvider);
  return AiRepositoryImpl(dataSource);
});

final generateSummaryUseCaseProvider = Provider<GenerateSummaryUseCase>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GenerateSummaryUseCase(repository);
});

final improveBulletUseCaseProvider = Provider<ImproveBulletUseCase>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ImproveBulletUseCase(repository);
});

final suggestSkillsUseCaseProvider = Provider<SuggestSkillsUseCase>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SuggestSkillsUseCase(repository);
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  final pdfService = ref.watch(pdfServiceProvider);
  return PdfRepositoryImpl(pdfService);
});

final exportPdfUseCaseProvider = Provider<ExportPdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return ExportPdfUseCase(repository);
});