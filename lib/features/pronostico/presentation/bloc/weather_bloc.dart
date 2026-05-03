import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_event_state.dart';
import '../../../pronostico/domain/usecases/get_forecast.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetForecast getForecast;

  WeatherBloc({required this.getForecast}) : super(WeatherInitial()) {
    on<FetchForecastEvent>(_onFetch);
  }

  Future<void> _onFetch(
      FetchForecastEvent event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    final result = await getForecast(ForecastParams(municipio: event.municipio));
    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (forecast) =>
          emit(WeatherLoaded(forecast: forecast, fromCache: forecast.isStale)),
    );
  }
}
