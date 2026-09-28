import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _db;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        'health_app.db',
        options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
      );
    }

    final path = join(await getDatabasesPath(), 'health_app.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        fotoProfil TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE alarm (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        jam TEXT NOT NULL,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        aktif INTEGER DEFAULT 1,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }
}
