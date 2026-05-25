import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agro_clima/features/usuario/data/datasources/usuario_local_datasource.dart';
import 'package:agro_clima/features/usuario/domain/entities/usuario.dart';
import 'package:agro_clima/core/database/app_database.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late UsuarioLocalDataSource dataSource;
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
            CREATE TABLE ${AppDatabase.tableU} (
              ${AppDatabase.colUId}        INTEGER PRIMARY KEY AUTOINCREMENT,
              ${AppDatabase.colUNombres}   TEXT    NOT NULL,
              ${AppDatabase.colUApellidos} TEXT    NOT NULL,
              ${AppDatabase.colUTelefono}  TEXT    NOT NULL,
              ${AppDatabase.colUEmail}     TEXT    NOT NULL UNIQUE,
              ${AppDatabase.colUContrasenaHash} TEXT NOT NULL,
              ${AppDatabase.colUFechaRegistro} TEXT NOT NULL
            )
          ''');
          // Dummy tables for deleteUsuario
          await db.execute('CREATE TABLE ${AppDatabase.tableF} (id INTEGER PRIMARY KEY)');
          await db.execute('CREATE TABLE ${AppDatabase.tableC} (id TEXT PRIMARY KEY)');
          await db.execute('CREATE TABLE ${AppDatabase.tableH} (id INTEGER PRIMARY KEY)');
          await db.execute('CREATE TABLE ${AppDatabase.tableW} (id INTEGER PRIMARY KEY)');
        },
      ),
    );
    mockAppDb = MockAppDatabase();
    when(() => mockAppDb.database).thenAnswer((_) async => db);
    dataSource = UsuarioLocalDataSource(db: mockAppDb);
  });

  tearDown(() async {
    await db.close();
  });

  group('UsuarioLocalDataSource', () {
    final tUsuario = Usuario(
      nombres: 'Juan',
      apellidos: 'Perez',
      telefono: '1234567890',
      email: 'juan@test.com',
      contrasenaHash: 'hash',
      fechaRegistro: DateTime(2025, 1, 1),
    );

    test('getUsuario retorna null cuando no hay usuarios', () async {
      final result = await dataSource.getUsuario();
      expect(result, isNull);
    });

    test('saveUsuario guarda e getUsuario lo recupera', () async {
      await dataSource.saveUsuario(tUsuario);
      
      final result = await dataSource.getUsuario();
      expect(result, isNotNull);
      expect(result!.nombres, 'Juan');
      expect(result.email, 'juan@test.com');
      expect(result.id, 1);
    });

    test('deleteUsuario limpia todas las tablas asociadas', () async {
      await dataSource.saveUsuario(tUsuario);
      
      await db.insert(AppDatabase.tableF, {'id': 1});
      await db.insert(AppDatabase.tableC, {'id': 'c1'});
      await db.insert(AppDatabase.tableH, {'id': 1});
      await db.insert(AppDatabase.tableW, {'id': 1});

      await dataSource.deleteUsuario();
      
      final result = await dataSource.getUsuario();
      expect(result, isNull);

      final countF = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppDatabase.tableF}'));
      final countC = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppDatabase.tableC}'));
      final countH = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppDatabase.tableH}'));
      final countW = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppDatabase.tableW}'));

      expect(countF, 0);
      expect(countC, 0);
      expect(countH, 0);
      expect(countW, 0);
    });
  });
}
