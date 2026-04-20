import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';
import 'package:resume_labs/presentation/providers/auth/auth_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_form_provider.dart';
import 'package:resume_labs/presentation/screens/resume_builder/builder_screen.dart';

class _EmptyResumeFormNotifier extends ResumeFormNotifier {
  @override
  ResumeFormState build() => ResumeFormState.initial(userId: 'u-1');
}

class _PrefilledResumeFormNotifier extends ResumeFormNotifier {
  @override
  ResumeFormState build() {
    return ResumeFormState.initial(userId: 'u-1').copyWith(
      title: 'Senior Flutter Developer',
      personalSummary: 'Summary text',
      workExperiences: [
        WorkExperience(
          company: 'ABC',
          role: 'Engineer',
          location: 'Dubai',
          startDate: DateTime(2020, 1, 1),
          endDate: null,
          bulletPoints: const ['Built features'],
          isCurrentRole: true,
        ),
      ],
      educations: [
        Education(
          school: 'XYZ University',
          degree: 'BS',
          field: 'CS',
          graduationDate: DateTime(2019, 6, 1),
          gpa: 3.5,
        ),
      ],
      skills: const [
        Skill(name: 'Flutter', category: 'Mobile'),
      ],
    );
  }
}

ProviderScope _buildApp({
  required ResumeFormNotifier Function() resumeFormFactory,
}) {
  return ProviderScope(
    overrides: [
      resumeFormProvider.overrideWith(resumeFormFactory),
      authProvider.overrideWith(
        (ref) => Stream.value(
          UserProfile(
            uid: 'u-1',
            email: 'test@example.com',
            createdAt: DateTime(2024, 1, 1),
          ),
        ),
      ),
    ],
    child: const MaterialApp(home: BuilderScreen()),
  );
}

void main() {
  Finder _appBarTitle(String text) => find.descendant(
        of: find.byType(AppBar),
        matching: find.text(text),
      );

  testWidgets('shows validation error dialog when required fields missing',
      (tester) async {
    await tester.pumpWidget(
      _buildApp(resumeFormFactory: _EmptyResumeFormNotifier.new),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BuilderScreen), findsOneWidget);
    expect(_appBarTitle('Personal Info'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Validation Error'), findsOneWidget);
    expect(
      find.text('Please fix the required fields before continuing.'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Validation Error'), findsNothing);
  });

  testWidgets('navigates through steps when form is valid', (tester) async {
    await tester.pumpWidget(
      _buildApp(resumeFormFactory: _PrefilledResumeFormNotifier.new),
    );
    await tester.pumpAndSettle();

    expect(_appBarTitle('Personal Info'), findsOneWidget);
    expect(find.text('Resume Title'), findsOneWidget);
    expect(find.text('Personal Summary'), findsOneWidget);

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(_appBarTitle('Work Experience'), findsOneWidget);
    expect(find.text('Add'), findsWidgets);

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(_appBarTitle('Education'), findsOneWidget);

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(_appBarTitle('Skills'), findsOneWidget);
    expect(find.text('Save Resume'), findsOneWidget);
  });
}
