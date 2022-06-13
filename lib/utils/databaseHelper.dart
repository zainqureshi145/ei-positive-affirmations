import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ei_positive_affirmations/model/recording.dart';

class DatabaseHelper {
  static const databaseName = 'Affirmations.db';
  static const databaseVersion = 1;

  // Convert to Singleton Constructor/Class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  late Database _database;
  // Future<Database> get database async {
  //   if (_database != null) return _database;
  //   _database = await initDatabase();
  //   return _database;
  // }

  // initDatabase() async {
  //   Directory dataDirectory = await getApplicationDocumentsDirectory();
  //   String dbPath = join(dataDirectory.path, databaseName);
  //   return await openDatabase(dbPath,
  //       version: databaseVersion, onCreate: onCreateDB);
  // }

  Future<Database> get database async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, databaseName);
    return _database = await openDatabase(dbPath,
        version: databaseVersion, onCreate: onCreateDB);
  }

  onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Recording.tableName}(
    ${Recording.columnName} TEXT NOT NULL,
    ${Recording.columnTag} TEXT NOT NULL,
    ${Recording.columnPath} TEXT NOT NULL
    )
    ''');
  }

  Future insertRecording(Recording recording) async {
    Database db = await database;
    return await db.insert(Recording.tableName, recording.toMap());
  }

  Future<List<Recording>> fetchRecordings() async {
    Database db = await database;
    List<Map<String, dynamic>> recordings = await db.query(Recording.tableName);
    //print(recordings);
    return recordings.isEmpty
        ? []
        : recordings.map((e) => Recording.fromMap(e)).toList();
  }
}
