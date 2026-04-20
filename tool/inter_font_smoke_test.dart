import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  final regular = await _fontFromFile('assets/fonts/Inter-Regular.ttf');
  final medium = await _fontFromFile('assets/fonts/Inter-Medium.ttf');
  final semiBold = await _fontFromFile('assets/fonts/Inter-SemiBold.ttf');
  final bold = await _fontFromFile('assets/fonts/Inter-Bold.ttf');

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => pw.Padding(
        padding: const pw.EdgeInsets.all(36),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Inter Regular: Hello World 123',
              style: pw.TextStyle(font: regular, fontSize: 26),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Inter Medium: Hello World 123',
              style: pw.TextStyle(font: medium, fontSize: 26),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Inter SemiBold: Hello World 123',
              style: pw.TextStyle(font: semiBold, fontSize: 26),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Inter Bold: Hello World 123',
              style: pw.TextStyle(font: bold, fontSize: 26),
            ),
          ],
        ),
      ),
    ),
  );

  final out = File('/tmp/inter_font_smoke_test.pdf');
  await out.writeAsBytes(await doc.save(), flush: true);
  // ignore: avoid_print
  print(out.path);
}

Future<pw.Font> _fontFromFile(String path) async {
  final bytes = await File(path).readAsBytes();
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return pw.Font.ttf(data);
}

