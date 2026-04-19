import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/presentation/providers/resume/resume_list_provider.dart';
import 'package:resume_labs/presentation/screens/history/history_screen.dart';

void main() {
  testWidgets('shows empty state when there are no resumes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resumeListProvider.overrideWith((ref) async => const <Resume>[]),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('No resumes yet'), findsOneWidget);
    expect(find.text('Create New Resume'), findsOneWidget);
    expect(find.text('New Resume'), findsOneWidget);
  });
}
