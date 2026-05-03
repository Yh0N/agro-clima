import 'package:equatable/equatable.dart';

class WeatherDay extends Equatable {
  final String dayName;
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double rainProbability;
  final double windSpeed;
  final String emoji;

  const WeatherDay({
    required this.dayName,
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.rainProbability,
    required this.windSpeed,
    required this.emoji,
  });

  bool get isGoodForSpray => windSpeed < 20 && rainProbability < 40;

  @override
  List<Object?> get props => [date, tempMin, tempMax, rainProbability, windSpeed];
}

class WeatherForecast extends Equatable {
  final String municipio;
  final List<WeatherDay> days;
  final DateTime fetchedAt;

  const WeatherForecast({
    required this.municipio,
    required this.days,
    required this.fetchedAt,
  });

  bool get isStale => DateTime.now().difference(fetchedAt).inHours >= 6;

  @override
  List<Object?> get props => [municipio, days, fetchedAt];
}

class MunicipioData {
  final double lat;
  final double lon;
  final int altitud;
  const MunicipioData({required this.lat, required this.lon, required this.altitud});
}

const Map<String, MunicipioData> municipiosNarino = {
  'Pasto': MunicipioData(lat: 1.214, lon: -77.279, altitud: 2527),
  'Túquerres': MunicipioData(lat: 0.823, lon: -77.642, altitud: 3070),
  'Cumbal': MunicipioData(lat: 0.841, lon: -77.643, altitud: 3050),
  'Ipiales': MunicipioData(lat: 0.859, lon: -77.641, altitud: 2899),
  'La Unión': MunicipioData(lat: 1.007, lon: -77.502, altitud: 1760),
  'Sandoná': MunicipioData(lat: 1.379, lon: -77.166, altitud: 1810),
};
