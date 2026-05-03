import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:agro_clima/features/finca/data/datasources/finca_sqlite_datasource.dart';
import 'package:agro_clima/features/finca/domain/entities/finca.dart';
import 'package:agro_clima/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FincaSQLiteDataSource dataSource;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppDatabase.tableF} (
              ${AppDatabase.colId}        INTEGER PRIMARY KEY AUTOINCREMENT,
              ${AppDatabase.colNombreAg}  TEXT    NOT NULL,
              ${AppDatabase.colNombreF}   TEXT    NOT NULL,
              ${AppDatabase.colMunicipio} TEXT    NOT NULL,
              ${AppDatabase.colVereda}    TEXT    NOT NULL DEFAULT '',
              ${AppDatabase.colAltitud}   INTEGER NOT NULL,
              ${AppDatabase.colHectareas} REAL    NOT NULL,
              ${AppDatabase.colTipoRiego} TEXT    NOT NULL
            )
          ''');
        },
      ),
    );
    dataSource = FincaSQLiteDataSource.fromDatabase(db);
  });

  tearDown(() async {
    await db.close();
    await databaseFactoryFfi.deleteDatabase(inMemoryDatabasePath);
  });

  group('FincaSQLiteDataSource', () {
    const fincaDemo = Finca(
      nombreAgricultero: 'Don José García',
      nombreFinca: 'La Esperanza',
      vereda: 'El Encano',
      municipio: 'Pasto',
      altitud: 2700,
      hectareas: 2.5,
      tipoRiego: 'Lluvia',
    );

    test('loadFincas retorna lista vacía cuando la BD está vacía', () async {
      final result = await dataSource.loadFincas();
      expect(result, isEmpty);
    });

    test('saveFinca guarda y loadFincas recupera correctamente', () async {
      final saved = await dataSource.saveFinca(fincaDemo);
      expect(saved.id, isNotNull);

      final loadedList = await dataSource.loadFincas();
      expect(loadedList, isNotEmpty);
      
      final loaded = loadedList.first;
      expect(loaded.nombreAgricultero, 'Don José García');
      expect(loaded.nombreFinca, 'La Esperanza');
      expect(loaded.municipio, 'Pasto');
      expect(loaded.altitud, 2700);
      expect(loaded.hectareas, closeTo(2.5, 0.001));
      expect(loaded.tipoRiego, 'Lluvia');
    });

    test('saveFinca hace update si tiene id', () async {
      final saved1 = await dataSource.saveFinca(fincaDemo);
      await dataSource.saveFinca(saved1.copyWith(altitud: 2800));

      final loadedList = await dataSource.loadFincas();
      expect(loadedList.length, 1);
      expect(loadedList.first.altitud, 2800);
    });

    test('deleteFinca elimina el registro por id', () async {
      final saved = await dataSource.saveFinca(fincaDemo);
      await dataSource.deleteFinca(saved.id!);
      final result = await dataSource.loadFincas();
      expect(result, isEmpty);
    });
  });
}
