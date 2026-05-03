import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/weather_forecast.dart';

class WeatherLocalDataSource {
  static const _key = 'cached_forecasts';

  Future<WeatherForecast?> getCachedForecast(String municipio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('${_key}_$municipio');
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(map['fetchedAt'] as String);
      if (DateTime.now().difference(fetchedAt).inHours >= 6) return null;

      final daysData = map['days'] as List;
      final days = daysData.map((d) {
        return WeatherDay(
          dayName: d['dayName'] as String,
          date: DateTime.parse(d['date'] as String),
          tempMin: (d['tempMin'] as num).toDouble(),
          tempMax: (d['tempMax'] as num).toDouble(),
          rainProbability: (d['rainProbability'] as num).toDouble(),
          windSpeed: (d['windSpeed'] as num).toDouble(),
          emoji: d['emoji'] as String,
        );
      }).toList();

      return WeatherForecast(
        municipio: municipio,
        days: days,
        fetchedAt: fetchedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheForecast(WeatherForecast forecast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'fetchedAt': forecast.fetchedAt.toIso8601String(),
        'days': forecast.days
            .map((d) => {
                  'dayName': d.dayName,
                  'date': d.date.toIso8601String(),
                  'tempMin': d.tempMin,
                  'tempMax': d.tempMax,
                  'rainProbability': d.rainProbability,
                  'windSpeed': d.windSpeed,
                  'emoji': d.emoji,
                })
            .toList(),
      };
      await prefs.setString(
          '${_key}_${forecast.municipio}', jsonEncode(map));
    } catch (_) {}
  }
}
