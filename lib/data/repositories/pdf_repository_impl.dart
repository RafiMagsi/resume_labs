import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failure.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/repositories/pdf_repository.dart';
import '../services/pdf_service.dart';

class PdfRepositoryImpl implements PdfRepository {
  final PdfService pdfService;

  const PdfRepositoryImpl(this.pdfService);

  @override
  Future<Either<Failure, Uint8List>> generateResumePdfBytes({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    try {
      final Uint8List pdfBytes = await pdfService.generateResumePdf(
        resume: resume,
        template: template,
      );
      return Right(pdfBytes);
    } catch (e) {
      return Left(PdfFailure('Failed to generate PDF: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    try {
      final bytesResult = await generateResumePdfBytes(
        resume: resume,
        template: template,
      );
      return await bytesResult.match(
        (failure) async => Left(failure),
        (pdfBytes) async {
          Directory directory;
          try {
            directory = await getApplicationDocumentsDirectory();
          } catch (_) {
            // If `path_provider` fails on iOS simulator (Objective-C FFI), fall back
            // to a temp directory so export still works.
            directory =
                await Directory.systemTemp.createTemp('resume_labs_exports_');
          }
          final safeTitle = _sanitizeFileName(
            resume.title.isEmpty ? 'resume' : resume.title,
          );
          final fileName =
              '${safeTitle}_${template.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';

          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(pdfBytes, flush: true);

          return Right(file.path);
        },
      );
    } on PathNotFoundException catch (e) {
      return Left(PdfFailure('Save location not found: ${e.message}'));
    } on FileSystemException catch (e) {
      return Left(PdfFailure('Failed to save PDF file: ${e.message}'));
    } catch (e) {
      return Left(PdfFailure('Failed to export PDF: $e'));
    }
  }

  String _sanitizeFileName(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
