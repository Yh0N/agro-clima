import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton que gestiona la base de datos SQLite de AgroClima.
///
/// Tabla: finca
/// Un solo registro por dispositivo (id = 1 siempre).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  static const _dbName = 'agro_clima.db';
  static const _dbVersion = 1;

  // ── Nombre de tabla y columnas ────────────────────────────────────────────
  static const tableF = 'finca';
  static const colId = 'id';
  static const colNombreAg = 'nombre_agricultor';
  static const colNombreF = 'nombre_finca';
  static const colMunicipio = 'municipio';
  static const colVereda = 'vereda';
  static const colAltitud = 'altitud';
  static const colHectareas = 'hectareas';
  static const colTipoRiego = 'tipo_riego';

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableF (
        $colId       INTEGER PRIMARY KEY,
        $colNombreAg TEXT    NOT NULL,
        $colNombreF  TEXT    NOT NULL,
        $colMunicipio TEXT   NOT NULL,
        $colVereda   TEXT    NOT NULL DEFAULT '',
        $colAltitud  INTEGER NOT NULL,
        $colHectareas REAL   NOT NULL,
        $colTipoRiego TEXT   NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migración: en futuras versiones agregar columnas aquí.
    if (oldVersion < 2) {
      // placeholder para Sprint 2+
    }
  }

  /// Cierra la base de datos (útil en tests).
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
