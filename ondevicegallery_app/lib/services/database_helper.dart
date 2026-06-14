import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/image_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'ondevicegallery.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        status INTEGER NOT NULL,
        ocrText TEXT,
        processingTime INTEGER,
        errorMessage TEXT
      )
    ''');
  }

  Future<int> insertImage(ImageModel image) async {
    final db = await database;
    return await db.insert('images', image.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ImageModel>> getAllImages() async {
    final db = await database;
    final maps = await db.query('images');
    return maps.map((m) => ImageModel.fromMap(m)).toList();
  }

  Future<List<ImageModel>> getImagesByStatus(ImageStatus status) async {
    final db = await database;
    final maps = await db.query('images', where: 'status = ?', whereArgs: [status.index]);
    return maps.map((m) => ImageModel.fromMap(m)).toList();
  }

  Future<int> updateImage(ImageModel image) async {
    final db = await database;
    return await db.update('images', image.toMap(),
        where: 'id = ?', whereArgs: [image.id]);
  }

  Future<int> deleteImage(String id) async {
    final db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteImages(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete('images', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('images');
  }
}
