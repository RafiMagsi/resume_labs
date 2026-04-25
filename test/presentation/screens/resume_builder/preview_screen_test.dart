import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/services/firebase_pdf_service.dart';
import 'package:resume_labs/presentation/screens/resume_builder/preview_screen.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _FakeFirebasePdfService extends FirebasePdfService {
  _FakeFirebasePdfService()
      : super(cloudFunctionUrl: 'http://test', auth: _MockFirebaseAuth());

  @override
  Future<List<int>> generateResumePdf({
    required Map<String, dynamic> resumeData,
    required String template,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(resumeData['title']?.toString() ?? 'Resume'),
            pw.SizedBox(height: 8),
            pw.Text(template),
          ],
        ),
      ),
    );
    return doc.save();
  }
}

void main() {
  testWidgets('renders preview controls and export actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebasePdfServiceProvider
              .overrideWithValue(_FakeFirebasePdfService()),
        ],
        child: const MaterialApp(home: PreviewScreen()),
      ),
    );
    // `PdfPreview` keeps internal animations/timers; avoid `pumpAndSettle`.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(PreviewScreen), findsOneWidget);
    expect(find.text('Template'), findsWidgets);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Export DOCX'), findsOneWidget);
  });
}
