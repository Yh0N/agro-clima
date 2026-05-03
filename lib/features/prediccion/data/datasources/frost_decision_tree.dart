import '../../domain/entities/frost_prediction.dart';
import '../../../pronostico/domain/entities/weather_forecast.dart';

class FrostDecisionTree {
  FrostPrediction predict({
    required int altitud,
    required double tempMin,
    required double humedad,
    required int mes,
    required double nubosidad,
  }) {
    int risk = 0;
    final List<String> factors = [];

    // Factor 1: Altitud
    if (altitud > 3000) {
      risk += 3;
      factors.add('Altitud muy alta (más de 3.000m)');
    } else if (altitud > 2500) {
      risk += 2;
      factors.add('Altitud alta');
    } else if (altitud > 2000) {
      risk += 1;
    }

    // Factor 2: Temperatura mínima
    if (tempMin < 0) {
      risk += 6;
      factors.add('Temperatura bajo cero ❄️');
    } else if (tempMin < 2) {
      risk += 3;
      factors.add('Temperatura muy peligrosa');
    } else if (tempMin < 4) {
      risk += 2;
      factors.add('Temperatura baja');
    } else if (tempMin < 7) {
      risk += 1;
    } else {
      risk -= 1;
    }

    // Factor 3: Cielo despejado (helada radiativa)
    if (humedad < 40 && nubosidad < 30) {
      risk += 2;
      factors.add('Cielo despejado y seco — riesgo de helada radiativa');
    }

    // Factor 4: Mes seco de Nariño
    if ([1, 2, 6, 7, 8, 12].contains(mes)) {
      risk += 1;
    }

    risk = risk.clamp(0, 10);

    final level = risk >= 6
        ? RiskLevel.high
        : risk >= 3
            ? RiskLevel.medium
            : RiskLevel.low;

    final confidence = ((55 + risk * 4) / 100.0).clamp(0.55, 0.95);

    final recommendation = switch (level) {
      RiskLevel.high =>
        '⚠️ ¡Protege tus cultivos antes de las 6pm! Cubre la papa y la mora.',
      RiskLevel.medium => '🌡️ Esté pendiente esta noche. Revise a las 9pm.',
      RiskLevel.low => '✅ Sin riesgo hoy. Buena noche para sus cultivos.',
    };

    return FrostPrediction(
      level: level,
      confidence: confidence,
      factors: factors.isEmpty ? ['Condiciones normales de campo'] : factors,
      recommendation: recommendation,
    );
  }
}

class SprayDecisionTree {
  SprayDecision predictFromForecast(List<WeatherDay> days) {
    if (days.isEmpty) {
      return const SprayDecision(
        isGood: false,
        windOk: false,
        rainOk: false,
        bestDay: 'Sin datos',
        bestTime: '7–10am o después de las 4pm',
      );
    }

    final bestIdx = days.indexWhere(
      (d) => d.windSpeed < 20 && d.rainProbability < 40,
    );

    final today = days.first;
    final isGood = today.windSpeed < 20 && today.rainProbability < 40;

    return SprayDecision(
      isGood: isGood,
      windOk: today.windSpeed < 20,
      rainOk: today.rainProbability < 40,
      bestDay: bestIdx >= 0 ? days[bestIdx].dayName : 'Revisa en 2 días',
      bestTime: '7–10am o después de las 4pm',
    );
  }
}
