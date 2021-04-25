import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:game/model/progress.dart';
import 'package:game/util/question_database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'quiz_data.dart';

class ProgressDatabaseHelper {
  static final ProgressDatabaseHelper _instance = new ProgressDatabaseHelper.internal();

  factory ProgressDatabaseHelper() => _instance;

  final String tableprogress = 'progress';

  final String columnContent = 'content';
  final String columnValue = 'value';

  static Database _db;

  ProgressDatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'progress.db');

    File dbfile = new File(path);

    if(!dbfile.existsSync()) {
      ByteData data = await rootBundle.load("assets/progress.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    var db = await openDatabase(path, version: 1);
   return db;
  }


  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  void updatelangcount(int value) async{
    var dbClient = await db;
    await dbClient.rawUpdate("update progress set value =" + value.toString() + " where content ='language'");
  }

  Future<Progress> getlanguage() async{
    var dbclient = await db;
    List<Map> result = await dbclient.query(tableprogress,
        columns: [columnContent, columnValue],
        where: '$columnContent = ?',
        whereArgs: ['language']);
    if(result.length > 0) {
      return new Progress.fromMap(result.first);
    }
    return null;
  }

  Future<Progress> getlanguages() async{
    var dbclient = await db;
    List<Map> result = await dbclient.query(tableprogress,
        columns: [columnContent, columnValue],
        where: '$columnContent = ?',
        whereArgs: ['language']);
    if(result.length > 0) {
      int current = result.first[columnValue];
      List<String> table;
      switch(current) {
        case 0:
          table = QuizData.english_table;
          break;
        case 1:
          table = QuizData.romania_table;
          break;
        case 2:
          table = QuizData.austria_table;
          break;
      }
      QuizData.current =await getCurrent(table);
      QuizData.total = await getTotal(table);
      return new Progress.fromMap(result.first);
    }
    return null;
  }

  Future<int> getcurrentID(String tablequesiton) async{
    var dbclient = await db;
    List<Map> result = await dbclient.query(tableprogress,
        columns: [columnValue],
        where: '$columnContent = ?',
        whereArgs: [tablequesiton]);
    if(result.length > 0) {
      return result.first[columnValue];
    }
    return null;
  }

  Future<int> getcurrentnumber(String tablequesiton) async{
    var dbclient = await db;
    List<Map> result = await dbclient.query(tableprogress,
        columns: [columnValue],
        where: '$columnContent = ?',
        whereArgs: [tablequesiton]);
    if(result.length > 0) {
      return result.first[columnValue];
    }
    return null;
  }

  Future<int> getcurrenthint() async{
    var dbclient = await db;
    List<Map> result = await dbclient.query(tableprogress,
        columns: [columnValue],
        where: '$columnContent = ?',
        whereArgs: ['hint']);
    if(result.length > 0) {
      return result.first[columnValue];
    }
    return null;
  }

  Future<String> updatecount(String tablename) async{

    var dbClient = await db;
    int _solvednumber = await getcurrentnumber(tablename);
    var dbHelper = QuizData.questionhelper;
    int _totalnumber = await dbHelper.gettotalnumber(tablename);
    if (_solvednumber < _totalnumber) {
      await dbClient.rawUpdate("update progress set value = value + 1 where content ='$tablename'");
      return 'successful';
    }
    return 'fail';

  }
  void init_progress(String tablename) async {
    var dbClient = await db;
    await dbClient.rawUpdate("update progress set value = 0 where content ='$tablename'");
  }
  void update(String tablename) async{
    var dbClient = await db;
    await dbClient.rawUpdate("update progress set value = value + 1 where content ='$tablename'");
  }
  void decreasehint() async{
    var dbClient = await db;
    await dbClient.rawUpdate("update progress set value = value - 1 where content ='hint'");
  }

  Future<List<int>> getCurrent(List<String> table) async{
    List<int> current = new List();
    var dbclient = await db;
    for(int i = 0; i < table.length; i++){
      var result = await dbclient.query(tableprogress,
          columns: [columnValue],
          where: '$columnContent = ?',
          whereArgs: [table[i]]);
      int count = result.first[columnValue];
      current.add(count);
    }
    return current;
  }

  Future<List<int>> getTotal(List<String> table) async{
    List<int> total = new List();
    for(int i = 0; i < table.length; i++){
      int to =await QuizData.questionhelper.gettotalnumber(table[i]);
      total.add(to);
    }
    return total;
  }
}