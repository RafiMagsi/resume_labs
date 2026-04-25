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
    // HistoryScreen has animations; avoid pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('No resumes yet'), findsOneWidget);
    expect(find.text('Create New Resume'), findsOneWidget);
  });
}
