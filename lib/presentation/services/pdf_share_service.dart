import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

abstract interface class PdfShareService {
  Future<void> sharePdf({
    required String filePath,
  });
}

final pdfShareServiceProvider = Provider<PdfShareService>((ref) {
  return const PrintingPdfShareService();
});

final class PrintingPdfShareService implements PdfShareService {
  const PrintingPdfShareService();

  @override
  Future<void> sharePdf({
    required String filePath,
  }) async {
    final bytes = await File(filePath).readAsBytes();

    await Printing.sharePdf(
      bytes: bytes,
      filename: filePath.split(Platform.pathSeparator).last,
    );
  }
}

