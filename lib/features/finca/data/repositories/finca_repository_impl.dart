import 'package:dartz/dartz.dart';
import '../../domain/entities/finca.dart';
import '../../domain/repositories/i_finca_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/finca_sqlite_datasource.dart';

class FincaRepositoryImpl implements IFincaRepository {
  final FincaSQLiteDataSource dataSource;

  FincaRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<Finca>>> loadFincas() async {
    try {
      final fincas = await dataSource.loadFincas();
      return Right(fincas);
    } catch (e, st) {
      // ignore: avoid_print
      print('[FincaRepo] loadFincas error: $e\n$st');
      return const Left(CacheFailure('Error al cargar datos de fincas.'));
    }
  }

  @override
  Future<Either<Failure, Finca>> saveFinca(Finca finca) async {
    try {
      final saved = await dataSource.saveFinca(finca);
      return Right(saved);
    } catch (e, st) {
      // ignore: avoid_print
      print('[FincaRepo] saveFinca error: $e\n$st');
      return Left(CacheFailure('Error al guardar datos de finca. Detalle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFinca(int id) async {
    try {
      await dataSource.deleteFinca(id);
      return const Right(null);
    } catch (e, st) {
      // ignore: avoid_print
      print('[FincaRepo] deleteFinca error: $e\n$st');
      return Left(CacheFailure('Error al eliminar datos de finca. Detalle: $e'));
    }
  }
}
