import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failure.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/repositories/docx_repository.dart';
import '../services/docx_service.dart';

class DocxRepositoryImpl implements DocxRepository {
  final DocxService docxService;

  const DocxRepositoryImpl(this.docxService);

  @override
  Future<Either<Failure, String>> exportResumeDocx({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    try {
      final bytes = docxService.generateResumeDocx(
        resume: resume,
        template: template,
      );

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
          '${safeTitle}_${template.name}_${DateTime.now().millisecondsSinceEpoch}.docx';

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return Right(file.path);
    } on PathNotFoundException catch (e) {
      return Left(DocxFailure('Save location not found: ${e.message}'));
    } on FileSystemException catch (e) {
      return Left(DocxFailure('Failed to save DOCX file: ${e.message}'));
    } catch (e) {
      return Left(DocxFailure('Failed to export DOCX: $e'));
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
