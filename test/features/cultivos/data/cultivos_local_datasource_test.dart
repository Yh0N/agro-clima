import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agro_clima/features/cultivos/data/datasources/cultivos_local_datasource.dart';
import 'package:agro_clima/core/database/app_database.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late CultivosLocalDataSource dataSource;
  late Database db;
  late MockAppDatabase mockAppDb;

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
            CREATE TABLE ${AppDatabase.tableC} (
              ${AppDatabase.colCId}     TEXT PRIMARY KEY,
              ${AppDatabase.colUsuarioId} INTEGER NOT NULL DEFAULT 1,
              ${AppDatabase.colCNombre} TEXT NOT NULL,
              ${AppDatabase.colCActivo} INTEGER NOT NULL DEFAULT 0,
              ${AppDatabase.colSincronizado} INTEGER NOT NULL DEFAULT 0,
              ${AppDatabase.colModificadoEn} TEXT NOT NULL DEFAULT ''
            )
          ''');
        },
      ),
    );
    mockAppDb = MockAppDatabase();
    when(() => mockAppDb.database).thenAnswer((_) async => db);
    dataSource = CultivosLocalDataSource(db: mockAppDb);
  });

  tearDown(() async {
    await db.close();
  });

  group('CultivosLocalDataSource', () {
    test('getSelectedCropIds retorna lista vacía inicialmente', () async {
      final results = await dataSource.getSelectedCropIds();
      expect(results, isEmpty);
    });

    test('saveCropStatus guarda e inserta un nuevo cultivo y luego se recupera el ID', () async {
      await dataSource.saveCropStatus('c1', 'Papa', true);
      
      final results = await dataSource.getSelectedCropIds();
      expect(results, isNotEmpty);
      expect(results.first, 'c1');
    });

    test('saveCropStatus actualiza un cultivo existente sin crear duplicados', () async {
      // Insertar por primera vez
      await dataSource.saveCropStatus('c1', 'Papa', true);
      
      // Actualizar a inactivo
      await dataSource.saveCropStatus('c1', 'Papa', false);
      
      final results = await dataSource.getSelectedCropIds();
      expect(results, isEmpty); // Como está inactivo (0), getSelectedCropIds no lo retorna
    });

    test('clearCrops limpia todos los cultivos', () async {
      await dataSource.saveCropStatus('c1', 'Papa', true);
      await dataSource.saveCropStatus('c2', 'Mora', true);
      
      var results = await dataSource.getSelectedCropIds();
      expect(results.length, 2);
      
      await dataSource.clearCrops();
      
      results = await dataSource.getSelectedCropIds();
      expect(results, isEmpty);
    });
  });
}
