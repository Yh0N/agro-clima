import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/finca.dart';

/// Fuente de datos local usando SQLite (sqflite).
/// Soporta múltiples fincas.
class FincaSQLiteDataSource {
  final AppDatabase? _db;
  final Database? _rawDb;

  // Clave para el fallback en SharedPreferences
  static const _spKey = 'finca_list_v2';

  /// Constructor principal — usa AppDatabase singleton.
  FincaSQLiteDataSource({AppDatabase? db})
      : _db = db ?? AppDatabase.instance,
        _rawDb = null;

  /// Constructor para tests — recibe una Database ya abierta (in-memory).
  FincaSQLiteDataSource.fromDatabase(Database database)
      : _db = null,
        _rawDb = database;

  Future<Database> get _database async =>
      _rawDb ?? await _db!.database;

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<List<Finca>> loadFincas() async {
    // 1. Intenta SQLite
    try {
      final database = await _database;
      final rows = await database.query(AppDatabase.tableF);
      return rows.map((r) => _fromRow(r)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[SQLiteDS] loadFincas SQLite error: $e — usando SP fallback');
    }

    // 2. Fallback: SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_spKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => Finca.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Guardar (upsert) ──────────────────────────────────────────────────────

  Future<Finca> saveFinca(Finca finca) async {
    bool savedToSqlite = false;
    Finca? savedFinca;

    // 1. Intenta SQLite
    try {
      final database = await _database;
      final map = _toRow(finca);

      if (finca.id == null) {
        final newId = await database.insert(AppDatabase.tableF, map);
        savedFinca = finca.copyWith(id: newId);
      } else {
        await database.update(
          AppDatabase.tableF,
          map,
          where: '${AppDatabase.colId} = ?',
          whereArgs: [finca.id],
        );
        savedFinca = finca;
      }
      savedToSqlite = true;
    } catch (e) {
      // ignore: avoid_print
      print('[SQLiteDS] saveFinca SQLite error: $e — usando SP fallback');
      savedFinca = finca;
    }

    // 2. Siempre guarda en SharedPreferences como respaldo
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_spKey);
      List<Finca> current = [];
      if (raw != null) {
        current = (jsonDecode(raw) as List)
            .map((e) => Finca.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      
      if (savedFinca!.id != null) {
        final idx = current.indexWhere((e) => e.id == savedFinca!.id);
        if (idx >= 0) {
          current[idx] = savedFinca;
        } else {
          current.add(savedFinca);
        }
      } else {
        // Fallback ID si sqlite falló completamente
        final fakeId = DateTime.now().millisecondsSinceEpoch;
        savedFinca = savedFinca.copyWith(id: fakeId);
        current.add(savedFinca);
      }

      await prefs.setString(_spKey, jsonEncode(current.map((e) => e.toMap()).toList()));
    } catch (e) {
      if (!savedToSqlite) rethrow;
    }

    return savedFinca!;
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<void> deleteFinca(int id) async {
    try {
      final database = await _database;
      await database.delete(
        AppDatabase.tableF,
        where: '${AppDatabase.colId} = ?',
        whereArgs: [id],
      );
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_spKey);
      if (raw != null) {
        final current = (jsonDecode(raw) as List)
            .map((e) => Finca.fromMap(e as Map<String, dynamic>))
            .toList();
        current.removeWhere((e) => e.id == id);
        await prefs.setString(_spKey, jsonEncode(current.map((e) => e.toMap()).toList()));
      }
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(Finca finca) {
    final map = <String, dynamic>{
      AppDatabase.colNombreAg: finca.nombreAgricultero,
      AppDatabase.colNombreF: finca.nombreFinca,
      AppDatabase.colMunicipio: finca.municipio,
      AppDatabase.colVereda: finca.vereda,
      AppDatabase.colAltitud: finca.altitud,
      AppDatabase.colHectareas: finca.hectareas,
      AppDatabase.colTipoRiego: finca.tipoRiego,
    };
    if (finca.id != null) {
      map[AppDatabase.colId] = finca.id;
    }
    return map;
  }

  Finca _fromRow(Map<String, dynamic> row) => Finca(
        id: row[AppDatabase.colId] as int?,
        nombreAgricultero: row[AppDatabase.colNombreAg] as String? ?? '',
        nombreFinca: row[AppDatabase.colNombreF] as String? ?? '',
        municipio: row[AppDatabase.colMunicipio] as String? ?? 'Pasto',
        vereda: row[AppDatabase.colVereda] as String? ?? '',
        altitud: row[AppDatabase.colAltitud] as int? ?? 2527,
        hectareas: (row[AppDatabase.colHectareas] as num?)?.toDouble() ?? 1.0,
        tipoRiego: row[AppDatabase.colTipoRiego] as String? ?? 'Lluvia',
      );
}
