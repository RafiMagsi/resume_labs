import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_labs/presentation/screens/resume_builder/preview_screen.dart';

void main() {
  testWidgets('renders preview controls and export actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PreviewScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PreviewScreen), findsOneWidget);
    expect(find.text('Preview Controls'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Back to Edit'), findsOneWidget);
  });
}
