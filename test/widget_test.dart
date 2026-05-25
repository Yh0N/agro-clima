import 'package:flutter_test/flutter_test.dart';
import 'package:agro_clima/features/prediccion/data/datasources/frost_decision_tree.dart';
import 'package:agro_clima/features/prediccion/domain/entities/frost_prediction.dart';

void main() {
  group('FrostDecisionTree', () {
    final tree = FrostDecisionTree();

    test('riesgo ALTO: altitud 3200m, tempMin -1°C → RiskLevel.high', () {
      final result = tree.predict(
        altitud: 3200,
        tempMin: -1,
        humedad: 50,
        viento: 4,
        mes: 7,
        nubosidad: 50,
      );
      expect(result.level, RiskLevel.high);
    });

    test('riesgo BAJO: altitud 1800m, tempMin 15°C → RiskLevel.low', () {
      final result = tree.predict(
        altitud: 1800,
        tempMin: 15,
        humedad: 65,
        viento: 12,
        mes: 5,
        nubosidad: 60,
      );
      expect(result.level, RiskLevel.low);
    });

    test('confidence siempre entre 0.60 y 0.98', () {
      final result = tree.predict(
        altitud: 2500,
        tempMin: 5,
        humedad: 60,
        viento: 10,
        mes: 3,
        nubosidad: 50,
      );
      expect(result.confidence, greaterThanOrEqualTo(0.60));
      expect(result.confidence, lessThanOrEqualTo(0.98));
    });
  });
}
