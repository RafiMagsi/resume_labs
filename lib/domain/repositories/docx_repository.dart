import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';
import '../entities/resume.dart';
import '../entities/resume_template.dart';

abstract interface class DocxRepository {
  Future<Either<Failure, String>> exportResumeDocx({
    required Resume resume,
    required ResumeTemplate template,
  });
}
