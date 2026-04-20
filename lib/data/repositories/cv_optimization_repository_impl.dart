import 'package:fpdart/fpdart.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/repositories/cv_optimization_repository.dart';
import '../datasources/remote/cv_optimization_datasource.dart';

class CvOptimizationRepositoryImpl implements CvOptimizationRepository {
  final CvOptimizationDatasource _datasource;

  CvOptimizationRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, String>> optimizeCv(String cvText) async {
    try {
      final result = await _datasource.optimizeCv(cvText);
      return Right(result);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('CV optimization failed: $e'));
    }
  }
}
