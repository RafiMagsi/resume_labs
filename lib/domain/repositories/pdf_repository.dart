import 'package:fpdart/fpdart.dart';
import 'dart:typed_data';

import '../../core/errors/failure.dart';
import '../entities/resume.dart';
import '../entities/resume_template.dart';

abstract interface class PdfRepository {
  Future<Either<Failure, Uint8List>> generateResumePdfBytes({
    required Resume resume,
    required ResumeTemplate template,
  });

  Future<Either<Failure, String>> exportResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  });
}
