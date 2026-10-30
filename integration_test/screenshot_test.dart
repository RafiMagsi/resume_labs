import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resume_labs/app/app.dart';
import 'package:resume_labs/app/router/app_router.dart';
import 'package:resume_labs/data/services/pdf_service.dart';
import 'package:resume_labs/domain/entities/contact_details.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/resume_template.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';
import 'package:resume_labs/firebase_options.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/auth_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_form_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_list_provider.dart';
import 'package:resume_labs/presentation/providers/resume/resume_optimization_provider.dart';
import 'package:resume_labs/presentation/screens/history/history_screen.dart';
import 'package:resume_labs/presentation/screens/resume_builder/builder_screen.dart';
import 'package:resume_labs/presentation/screens/resume_builder/preview_screen.dart';
import 'package:resume_labs/presentation/screens/resume_optimizer/resume_optimizer_screen.dart';
import 'package:resume_labs/presentation/services/firebase_pdf_service.dart';

final _now = DateTime(2026, 10, 1, 9, 30);

const _optimizedPreview = '''Alex Morgan
Senior Product Designer
San Francisco, CA  |  alex.morgan@example.com

SUMMARY
Product designer with 7+ years of experience turning complex
workflows into simple, accessible products.

EXPERIENCE
Senior Product Designer - Northstar Labs (2022 - Present)
- Led the onboarding redesign, lifting activation by 28%.
- Built a design system adopted by 6 product teams.
- Partnered with research to run 40+ usability sessions.

Product Designer - Brightside (2019 - 2022)
- Shipped an analytics dashboard used by 12k weekly customers.
- Created accessible patterns that cut support tickets by 19%.

SKILLS
Figma, Design Systems, User Research, Prototyping, Accessibility
''';

final _demoResume = Resume(
  id: 'demo-resume',
  userId: 'demo-user',
  title: 'Senior Product Designer',
  personalSummary:
      'Product designer with 7+ years of experience shipping thoughtful, '
      'accessible products for high-growth teams. I turn complex workflows '
      'into simple experiences and partner closely with engineering and '
      'research to deliver measurable outcomes.',
  contactDetails: const ContactDetails(
    fullName: 'Alex Morgan',
    email: 'alex.morgan@example.com',
    phone: '+1 (415) 555-0142',
    location: 'San Francisco, CA',
    website: 'alexmorgan.design',
    linkedin: 'linkedin.com/in/alexmorgan',
  ),
  template: ResumeTemplate.modern,
  workExperiences: [
    WorkExperience(
      company: 'Northstar Labs',
      role: 'Senior Product Designer',
      location: 'San Francisco, CA',
      startDate: DateTime(2022, 3),
      isCurrentRole: true,
      bulletPoints: const [
        'Led the redesign of the onboarding experience, lifting activation by 28%.',
        'Built a shared design system adopted by 6 product teams.',
        'Partnered with research to run 40+ usability sessions.',
      ],
    ),
    WorkExperience(
      company: 'Brightside',
      role: 'Product Designer',
      location: 'Seattle, WA',
      startDate: DateTime(2019, 6),
      endDate: DateTime(2022, 2),
      isCurrentRole: false,
      bulletPoints: const [
        'Shipped a mobile analytics dashboard used by 12k weekly customers.',
        'Created accessible patterns that reduced support tickets by 19%.',
      ],
    ),
  ],
  educations: [
    Education(
      school: 'University of Washington',
      degree: 'B.S.',
      field: 'Interaction Design',
      graduationDate: DateTime(2019, 6),
      gpa: 3.8,
    ),
  ],
  skills: const [
    Skill(name: 'Figma', category: 'Design'),
    Skill(name: 'Design Systems', category: 'Design'),
    Skill(name: 'User Research', category: 'Research'),
    Skill(name: 'Prototyping', category: 'Design'),
    Skill(name: 'Accessibility', category: 'Design'),
    Skill(name: 'HTML/CSS', category: 'Technical'),
  ],
  createdAt: _now.subtract(const Duration(days: 90)),
  updatedAt: _now,
);

final _secondResume = Resume(
  id: 'demo-resume-2',
  userId: 'demo-user',
  title: 'Flutter Developer',
  personalSummary:
      'Mobile engineer focused on polished Flutter apps, clean architecture, '
      'and reliable release pipelines.',
  contactDetails: _demoResume.contactDetails,
  template: ResumeTemplate.modernClean,
  workExperiences: [
    WorkExperience(
      company: 'Orbit Mobile',
      role: 'Flutter Developer',
      location: 'Remote',
      startDate: DateTime(2021, 5),
      isCurrentRole: true,
      bulletPoints: const [
        'Shipped a cross-platform app used by 40k monthly customers.',
        'Cut release time by 35% with automated CI and integration tests.',
      ],
    ),
  ],
  educations: _demoResume.educations,
  skills: const [
    Skill(name: 'Flutter', category: 'Mobile'),
    Skill(name: 'Dart', category: 'Mobile'),
    Skill(name: 'Firebase', category: 'Backend'),
  ],
  createdAt: _now.subtract(const Duration(days: 60)),
  updatedAt: _now.subtract(const Duration(days: 2)),
);

final _thirdResume = Resume(
  id: 'demo-resume-3',
  userId: 'demo-user',
  title: 'Marketing Manager',
  personalSummary:
      'Growth marketer with a track record of launching campaigns that '
      'convert and retain customers.',
  contactDetails: _demoResume.contactDetails,
  template: ResumeTemplate.creative,
  workExperiences: [
    WorkExperience(
      company: 'Bloom & Co.',
      role: 'Marketing Manager',
      location: 'Austin, TX',
      startDate: DateTime(2020, 8),
      isCurrentRole: true,
      bulletPoints: const [
        'Grew organic traffic 2.3x through a refreshed content strategy.',
        'Managed a \$250k quarterly acquisition budget across paid channels.',
      ],
    ),
  ],
  educations: _demoResume.educations,
  skills: const [
    Skill(name: 'Content Strategy', category: 'Marketing'),
    Skill(name: 'SEO', category: 'Marketing'),
    Skill(name: 'Paid Social', category: 'Marketing'),
  ],
  createdAt: _now.subtract(const Duration(days: 45)),
  updatedAt: _now.subtract(const Duration(days: 5)),
);

final _demoResumes = [_demoResume, _secondResume, _thirdResume];

final _demoUser = UserProfile(
  uid: 'demo-user',
  email: 'alex.morgan@example.com',
  createdAt: _now,
  availableCredits: 10,
);

class _DemoFirebasePdfService extends FirebasePdfService {
  _DemoFirebasePdfService(this.resume) : super(cloudFunctionUrl: 'demo');

  final Resume resume;

  @override
  Future<List<int>> generateResumePdf({
    required Map<String, dynamic> resumeData,
    required String template,
    Duration timeout = const Duration(seconds: 60),
  }) {
    final selected = ResumeTemplate.values.firstWhere(
      (value) => value.name == template,
      orElse: () => ResumeTemplate.modern,
    );
    return PdfService().generateResumePdf(
      resume: resume.copyWith(template: selected),
      template: selected,
    );
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: HistoryScreen.routePath,
    routes: [
      GoRoute(
        path: HistoryScreen.routePath,
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: BuilderScreen.routePath,
        builder: (_, __) => const BuilderScreen(),
      ),
      GoRoute(
        path: PreviewScreen.routePath,
        builder: (_, __) => const PreviewScreen(),
      ),
      GoRoute(
        path: ResumeOptimizerScreen.routePath,
        builder: (_, __) => const ResumeOptimizerScreen(),
      ),
    ],
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> _hold(WidgetTester tester, String name) async {
  await _settle(tester);
  debugPrint('SHOT:$name');
  await tester.pump();
  await Future<void>.delayed(const Duration(seconds: 6));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots', (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final router = _router();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          authProvider.overrideWith(
            (ref) => Stream<UserProfile?>.value(_demoUser),
          ),
          resumeListProvider.overrideWith((ref) async => _demoResumes),
          creditsAvailableProvider.overrideWith(
            (ref) => Stream<int>.value(10),
          ),
          firebasePdfServiceProvider.overrideWithValue(
            _DemoFirebasePdfService(_demoResume),
          ),
        ],
        child: const App(),
      ),
    );

    await _hold(tester, 'ios_history');

    final container =
        ProviderScope.containerOf(tester.element(find.byType(HistoryScreen)));
    final form = container.read(resumeFormProvider.notifier);
    form.loadResume(_demoResume);
    form.setCurrentStep(0);

    router.push(BuilderScreen.routePath);
    await _hold(tester, 'ios_builder');

    router.push(PreviewScreen.routePath);
    await _settle(tester);
    await Future<void>.delayed(const Duration(seconds: 8));
    await _hold(tester, 'ios_preview');

    // Phone layout opens the template sheet via the "Change" button; the wide
    // (iPad) layout keeps templates in the sidebar dropdown instead.
    final changeButton = find.text('Change');
    if (changeButton.evaluate().isNotEmpty) {
      await tester.tap(changeButton);
    } else {
      await tester.tap(
        find.byType(DropdownButtonFormField<ResumeTemplate>).first,
      );
    }
    await _hold(tester, 'ios_templates');

    Navigator.of(tester.element(find.byType(PreviewScreen))).pop();
    await _settle(tester);

    router.push(ResumeOptimizerScreen.routePath);
    await _settle(tester);
    await tester.tap(find.text('Paste Text'));
    await _settle(tester);
    await tester.enterText(
      find.byType(TextField).first,
      'Alex Morgan\nSenior Product Designer\n'
      'Northstar Labs (2022 - Present)\n'
      'Led onboarding redesign and built a shared design system.\n'
      'Skills: Figma, Design Systems, User Research',
    );
    final editable = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    editable.controller.selection = const TextSelection.collapsed(offset: 0);
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(tester);

    final optimizationNotifier = container.read(
      resumeOptimizationNotifierProvider.notifier,
    );
    (optimizationNotifier as dynamic).state = const AsyncData(
      _optimizedPreview,
    );
    await _settle(tester);
    await tester.tap(find.text('Optimized'));
    await _settle(tester);
    await _hold(tester, 'ios_optimizer');
  });
}
