import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/finca.dart';

abstract class IFincaRepository {
  Future<Either<Failure, List<Finca>>> loadFincas();
  Future<Either<Failure, Finca>> saveFinca(Finca finca);
  Future<Either<Failure, void>> deleteFinca(int id);
}
