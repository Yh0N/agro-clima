import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/database/app_database.dart';

import 'features/prediccion/data/datasources/frost_decision_tree.dart';
import 'features/prediccion/presentation/bloc/prediction_bloc.dart';

import 'features/pronostico/data/datasources/weather_remote_datasource.dart';
import 'features/pronostico/data/datasources/weather_local_datasource.dart';
import 'features/pronostico/data/repositories/weather_repository_impl.dart';
import 'features/pronostico/domain/repositories/i_weather_repository.dart';
import 'features/pronostico/domain/usecases/get_forecast.dart';
import 'features/pronostico/presentation/bloc/weather_bloc.dart';

import 'features/finca/data/datasources/finca_sqlite_datasource.dart';
import 'features/finca/data/repositories/finca_repository_impl.dart';
import 'features/finca/domain/repositories/i_finca_repository.dart';
import 'features/finca/domain/usecases/finca_usecases.dart';
import 'features/finca/presentation/bloc/finca_bloc.dart';

import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── BLoCs (factory → nueva instancia cada vez que se pide) ────────────────
  sl.registerFactory(() => PredictionBloc(
        decisionTree: sl(),
        sprayTree: sl(),
      ));
  sl.registerFactory(() => WeatherBloc(getForecast: sl()));
  sl.registerFactory(() => FincaBloc(saveFinca: sl(), loadFincas: sl(), deleteFinca: sl()));

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetForecast(sl()));
  sl.registerLazySingleton(() => SaveFinca(sl()));
  sl.registerLazySingleton(() => LoadFincas(sl()));
  sl.registerLazySingleton(() => DeleteFinca(sl()));

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<IWeatherRepository>(
    () => WeatherRepositoryImpl(
      remote: sl(),
      local: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<IFincaRepository>(
    () => FincaRepositoryImpl(dataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FrostDecisionTree());
  sl.registerLazySingleton(() => SprayDecisionTree());
  sl.registerLazySingleton(() => WeatherRemoteDataSource(client: sl()));
  sl.registerLazySingleton(() => WeatherLocalDataSource());

  // SQLite datasource para Finca (Sprint 1)
  sl.registerLazySingleton(
    () => FincaSQLiteDataSource(db: sl<AppDatabase>()),
  );

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => http.Client());

  // Singleton de la base de datos SQLite
  sl.registerLazySingleton(() => AppDatabase.instance);
}
