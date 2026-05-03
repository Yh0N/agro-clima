import 'package:dartz/dartz.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/repositories/i_weather_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_local_datasource.dart';
import '../../../../features/pronostico/domain/entities/weather_forecast.dart'
    show municipiosNarino;

class WeatherRepositoryImpl implements IWeatherRepository {
  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource local;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherForecast>> getForecast(
      String municipio) async {
    final mun = municipiosNarino[municipio];
    if (mun == null) {
      return Left(InputFailure('Municipio "$municipio" no encontrado.'));
    }

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final data = await remote.getForecast(
          municipio: municipio,
          lat: mun.lat,
          lon: mun.lon,
        );
        await local.cacheForecast(data);
        return Right(data);
      } catch (e) {
        final cached = await local.getCachedForecast(municipio);
        if (cached != null) return Right(cached);
        return Left(ServerFailure(
            'Error al conectar con el servidor. Sin datos guardados.'));
      }
    } else {
      final cached = await local.getCachedForecast(municipio);
      if (cached != null) return Right(cached);
      return Left(
          CacheFailure('Sin conexión y sin datos guardados para $municipio.'));
    }
  }
}
