import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';
import '../entities/resume.dart';
import '../entities/resume_template.dart';

abstract interface class PdfRepository {
  Future<Either<Failure, String>> exportResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  });
}
