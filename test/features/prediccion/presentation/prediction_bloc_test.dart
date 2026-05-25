import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agro_clima/features/prediccion/presentation/bloc/prediction_bloc.dart';
import 'package:agro_clima/features/prediccion/presentation/bloc/prediction_event_state.dart';
import 'package:agro_clima/features/prediccion/domain/entities/frost_prediction.dart';
import 'package:agro_clima/features/prediccion/data/datasources/frost_decision_tree.dart';

class MockFrostDecisionTree extends Mock implements FrostDecisionTree {}
class MockSprayDecisionTree extends Mock implements SprayDecisionTree {}

void main() {
  late PredictionBloc bloc;
  late MockFrostDecisionTree mockDecisionTree;
  late MockSprayDecisionTree mockSprayTree;

  setUp(() {
    mockDecisionTree = MockFrostDecisionTree();
    mockSprayTree = MockSprayDecisionTree();
    bloc = PredictionBloc(
      decisionTree: mockDecisionTree,
      sprayTree: mockSprayTree,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tPrediction = FrostPrediction(
    level: RiskLevel.low,
    confidence: 0.85,
    factors: ['Test'],
    recommendation: 'Todo bien',
  );

  final tSpray = SprayDecision(
    isGood: true,
    windOk: true,
    rainOk: true,
    bestDay: 'Hoy',
    bestTime: 'Mañana',
  );

  test('estado inicial debe ser PredictionInitial', () {
    expect(bloc.state, PredictionInitial());
  });

  blocTest<PredictionBloc, PredictionState>(
    'emite [PredictionLoading, PredictionLoaded] cuando la predicción es exitosa',
    build: () {
      when(() => mockDecisionTree.predict(
            altitud: any(named: 'altitud'),
            tempMin: any(named: 'tempMin'),
            humedad: any(named: 'humedad'),
            viento: any(named: 'viento'),
            mes: any(named: 'mes'),
            nubosidad: any(named: 'nubosidad'),
          )).thenReturn(tPrediction);
      when(() => mockSprayTree.predictFromForecast(any())).thenReturn(tSpray);
      return bloc;
    },
    act: (bloc) => bloc.add(PredictFrostEvent(
      altitud: 2500,
      tempMin: 5.0,
      humedad: 70,
      mes: 5,
    )),
    expect: () => [
      PredictionLoading(),
      PredictionLoaded(prediction: tPrediction, spray: tSpray),
    ],
  );

  blocTest<PredictionBloc, PredictionState>(
    'emite [PredictionLoading, PredictionError] cuando falla el calculo',
    build: () {
      when(() => mockDecisionTree.predict(
            altitud: any(named: 'altitud'),
            tempMin: any(named: 'tempMin'),
            humedad: any(named: 'humedad'),
            viento: any(named: 'viento'),
            mes: any(named: 'mes'),
            nubosidad: any(named: 'nubosidad'),
          )).thenThrow(Exception('Algo falló'));
      return bloc;
    },
    act: (bloc) => bloc.add(PredictFrostEvent(
      altitud: 2500,
      tempMin: 5.0,
      humedad: 70,
      mes: 5,
    )),
    expect: () => [
      PredictionLoading(),
      PredictionError(message: 'Error calculando predicción'),
    ],
  );
}
