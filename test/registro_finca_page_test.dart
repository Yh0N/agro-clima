import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agro_clima/features/finca/presentation/bloc/finca_bloc.dart';
import 'package:agro_clima/features/finca/presentation/bloc/finca_event_state.dart';
import 'package:agro_clima/features/registro/presentation/pages/registro_finca_page.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockFincaBloc extends Mock implements FincaBloc {}

// ── Helper de construcción del widget ────────────────────────────────────────

Widget _buildSubject(FincaBloc bloc) {
  return MaterialApp(
    routes: {
      '/home': (_) => const Scaffold(body: Text('Home')),
      '/registro': (_) => const RegistroFincaPage(),
    },
    home: BlocProvider<FincaBloc>.value(
      value: bloc,
      child: const RegistroFincaPage(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockFincaBloc mockBloc;

  setUp(() {
    mockBloc = MockFincaBloc();
    when(() => mockBloc.state).thenReturn(FincaInitial());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('RegistroFincaPage — validación de formulario', () {
    testWidgets('Paso 1: muestra error si nombre está vacío', (tester) async {
      await tester.pumpWidget(_buildSubject(mockBloc));

      // Busca el botón "Siguiente" y lo presiona sin rellenar nada
      final nextBtn = find.text('Siguiente →');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pump();

      // Debe mostrar mensaje de validación
      expect(find.text('Por favor escriba su nombre'), findsOneWidget);
    });

    testWidgets('Paso 1: muestra error si nombre de finca está vacío',
        (tester) async {
      await tester.pumpWidget(_buildSubject(mockBloc));

      // Solo escribe el nombre del agricultor
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Don Carlos');
      await tester.tap(find.text('Siguiente →'));
      await tester.pump();

      expect(find.text('Por favor escriba el nombre de su finca'),
          findsOneWidget);
    });

    testWidgets('Paso 1: avanza al paso 2 con datos válidos', (tester) async {
      await tester.pumpWidget(_buildSubject(mockBloc));

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Don Carlos Erazo');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Finca El Mirador');
      await tester.tap(find.text('Siguiente →'));
      await tester.pump();

      // El paso 2 debe mostrar el selector de municipio
      expect(find.text('¿En qué municipio está su finca?'), findsOneWidget);
    });

    testWidgets('Paso 2 → 3: botón Siguiente avanza al resumen',
        (tester) async {
      await tester.pumpWidget(_buildSubject(mockBloc));

      // Rellena paso 1
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Ana Narváez');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'La Cocha');
      await tester.tap(find.text('Siguiente →'));
      await tester.pump();

      // Avanza desde paso 2
      await tester.tap(find.text('Siguiente →'));
      await tester.pump();

      // Debe mostrar opciones de riego
      expect(find.text('¿Qué tipo de riego usa usted?'), findsOneWidget);
    });
  });

  group('RegistroFincaPage — navegación atrás', () {
    testWidgets('Botón Atrás en paso 2 regresa al paso 1', (tester) async {
      await tester.pumpWidget(_buildSubject(mockBloc));

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Luis Paz');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'El Vergel');
      await tester.tap(find.text('Siguiente →'));
      await tester.pump();

      await tester.tap(find.text('← Atrás'));
      await tester.pump();

      expect(find.text('¿Cómo se llama usted?'), findsOneWidget);
    });
  });
}
