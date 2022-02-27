import 'package:sqflite/sqflite.dart';
import 'package:todolists/models/task.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = "tasks";

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = await getDatabasesPath() + 'tasks.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("creating a new one");
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "startTime STRING, endTime STRING, "
            "remind INTEGER, repeat STRING, "
            "color INTEGER, "
            "isCompleted INTEGER)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  /* Insert Data */
  static Future<int> insert(Task? task) async {
    print("insert data call");
    return await _db?.insert(_tableName, task!.toJson()) ?? 1;
  }

  /* Read All Data */
  static Future<List<Map<String, dynamic>>> query() async {
    print("query data call");
    return await _db!.query(_tableName);
  }

  /* Delete Data */
  static delete(Task task) async {
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
  }

  /* Update Data */
  static update(int id) async {
    return await _db!.rawUpdate('''
      UPDATE tasks
      SET isCompleted = ? 
      WHERE id = ?
    ''', [1, id]);
  }
}
