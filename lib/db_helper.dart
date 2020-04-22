import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_tasker/models/task.dart';

class DBHelper {
  static Database _database;
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String START_TIME = 'start_time';
  static const String END_TIME = 'end_time';
  static const String DURATION = 'duration';
  static const String TASK_DATE = 'date';
  static const String EXPANDED_TASKS = 'expanded_tasks';
  static const String IS_DEVICE_CALENDAR_TASK = 'calendar_task';
  static const String OVERLAP_PERIOD = 'overlap_period';
  static const String DURATION_TABLE = 'duration_task';
  static const String START_END_TABLE = 'start_end_task';
  static const String DB_NAME = 'timer_tasker.db';

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 2, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $DURATION_TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT, $DURATION INTEGER, $TASK_DATE INTEGER DEFAULT (cast(strftime('%s','now') as int)), $EXPANDED_TASKS TEXT)");
    await db.execute(
        "CREATE TABLE $START_END_TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT, $START_TIME INTEGER, $END_TIME INTEGER, $TASK_DATE INTEGER DEFAULT (cast(strftime('%s','now') as int)), $IS_DEVICE_CALENDAR_TASK INTEGER, $OVERLAP_PERIOD TEXT)");
  }

  Future<DurationTask> insertNewDurationTask(DurationTask task) async {
    var dbClient = await database;
    task.id = await dbClient.insert(DURATION_TABLE, task.toMap());
    return task;
  }

  Future<StartEndTask> insertNewStartEndTask(StartEndTask task) async {
    var dbClient = await database;
    task.id = await dbClient.insert(START_END_TABLE, task.toMap());
    return task;
  }

  Future<List<DurationTask>> getDurationTasks() async {
    var dbClient = await database;
    List<Map> maps = await dbClient.query(DURATION_TABLE,
        columns: [ID, NAME, DURATION, TASK_DATE, EXPANDED_TASKS],
        orderBy: '$TASK_DATE DESC');
    List<DurationTask> durationTasksList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        durationTasksList.add(DurationTask.fromMap(maps[i]));
      }
    }
    return durationTasksList;
  }

  Future<List<StartEndTask>> getStartEndTasks() async {
    var dbClient = await database;
    List<Map> maps = await dbClient.query(START_END_TABLE,
        columns: [
          ID,
          NAME,
          START_TIME,
          END_TIME,
          TASK_DATE,
          IS_DEVICE_CALENDAR_TASK,
          OVERLAP_PERIOD
        ],
        orderBy: '$START_TIME ASC');
    List<StartEndTask> startEndTasksList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        startEndTasksList.add(StartEndTask.fromMap(maps[i]));
      }
    }
    return startEndTasksList;
  }

  Future<int> deleteDurationTask(int id) async {
    var dbClient = await database;
    return await dbClient
        .delete(DURATION_TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> deleteStartEndTask(int id) async {
    var dbClient = await database;
    return await dbClient
        .delete(START_END_TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> updateDurationTask(DurationTask task) async {
    var dbClient = await database;
    return await dbClient.update(DURATION_TABLE, task.toMap(),
        where: '$ID= ?', whereArgs: [task.id]);
  }

  Future<int> updateStartEndTask(StartEndTask task) async {
    var dbClient = await database;
    return await dbClient.update(START_END_TABLE, task.toMap(),
        where: '$ID= ?', whereArgs: [task.id]);
  }

  Future closeDB() async {
    var dbClient = await database;
    dbClient.close();
  }
}
