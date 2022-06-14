import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ei_positive_affirmations/model/recording.dart';

class DatabaseHelper {
  static const databaseName = 'Affirmations.db';
  static const databaseVersion = 1;
  var setOfTags = [];
  //List<Recording> allTags = [];
  List<String> allTags = [];

  // Convert to Singleton Constructor/Class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  late Database _database;
  Future<Database> get database async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, databaseName);
    // return _database = await openDatabase(dbPath,
    //     version: databaseVersion, onCreate: onCreateDB);
    _database = await openDatabase(dbPath,
        version: databaseVersion, onCreate: onCreateDB);
    return _database;
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
    final id = await db.insert(Recording.tableName, recording.toMap());
    print('Record "$id" is inserted into database...');
    return id;
  }

  Future<List<Recording>> fetchRecordings() async {
    Database db = await database;
    List<Map<String, dynamic>> recordings = await db.query(Recording.tableName);
    // print(recordings);
    // TODO: Get Tags from here, and query the db
    var tags = recordings.map((e) => Recording.fromMap(e).tag).toList();
    //print('==||||==> tags: ${tags.length}');
    // TODO: Count number of occurrences of tags, and query the db
    var tempSetsOfTags = tags.toSet().toList();
    setOfTags = tempSetsOfTags;
    //print('setOfTags: $setOfTags');
    //print('==||||==> Size of Set: ${tempSetsOfTags.length}');
    //print('Set of Tags: $tempSetsOfTags');
    //fetchGroupedTags();
    return recordings.isEmpty
        ? []
        : recordings.map((e) => Recording.fromMap(e)).toList();
  }

  // fetchGroupedTags() async {
  //   Database db = await database;
  //   for (int x = 0; x < setOfTags.length; x++) {
  //     //List<Map<String, dynamic>> groupedTags = await db.query(
  //     List<Map> groupedTags = await db.query(Recording.tableName,
  //         where: '${Recording.columnTag} = ?',
  //         whereArgs: [setOfTags[x].toString()]);
  //     //print('Here are grouped tags:> $groupedTags');
  //
  //     allTags.add(groupedTags);
  //   }
  //   //print(allTags.length);
  //   return allTags;
  // }

  Future<List> fetchGroupedTags() async {
    Database db = await database;
    for (int x = 0; x < setOfTags.length; x++) {
      //List<Map<String, dynamic>> groupedTags = await db.query(
      List<Map> list = await db.query(Recording.tableName,
          where: '${Recording.columnTag} = ?',
          whereArgs: [setOfTags[x].toString()]);
      //print('Here are grouped tags:> $groupedTags');
      List<Recording> recording = [];
      for (int i = 0; i < list.length; i++) {
        recording.add(Recording(
            name: list[i]['name'], tag: list[i]['tag'], path: list[i]['path']));
        allTags.add(recording[i].tag);
      }
    }
    return allTags;
  }
}
