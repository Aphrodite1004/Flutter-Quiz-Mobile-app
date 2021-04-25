import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:game/model/question.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'progress_database_helper.dart';
import 'quiz_data.dart';

class QuestionDatabaseHelper {
  static final QuestionDatabaseHelper _instance = new QuestionDatabaseHelper.internal();

  factory QuestionDatabaseHelper() => _instance;


  final String columnId = 'id';
  final String columnQuestion = 'question';
  final String columnAnswer = 'answer';

  static Database _db;

  QuestionDatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quiz.db');

    await deleteDatabase(path); // just for testing

    ByteData data = await rootBundle.load("assets/quiz.db");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes);

    var db = await openDatabase(path, version: 1);
    return db;
  }

  Future<Question> getQuestion(String tablequesiton, int num) async {
    var dbclient = await db;
    var dbHelper = QuizData.progresshelper;
    int number;
    int _totalnumber = await gettotalnumber(tablequesiton);
    if (num == null) {
      int id = await dbHelper.getcurrentID(tablequesiton);
      if( id == _totalnumber) number = id;
      else number = id + 1;
    }
    else {
      number = num;
    }
    List<Map> result = await dbclient.query(tablequesiton,
        columns: [columnId, columnQuestion, columnAnswer],
        where: '$columnId = ?',
        whereArgs: [number]);
    if(result.length > 0) {
      return new Question.fromMap(result.first);
    }
    return null;
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<int> gettotalnumber(String tablename) async{
    var dbclient = await db;
    var result = await dbclient.rawQuery('select count(*) from ${tablename}');
    int count = Sqflite.firstIntValue(result);
    return count;
  }

  Future<String> updatecount(String tablename) async{
    var dbHelper = QuizData.progresshelper;
    int _solvednumber =await dbHelper.getcurrentnumber(tablename);
    int _totalnumber = await gettotalnumber(tablename);
    print("solve:${_solvednumber}\n");
    print("total:${_totalnumber}\n");
    if(_solvednumber == _totalnumber -1){
      dbHelper.update(tablename);
      return 'fail';
    }
    if (_solvednumber < _totalnumber) {
      dbHelper.update(tablename);
      return 'successful';
    }
    return 'fail';

  }

  Future<List<Question>> getquestionlist(String table_name) async{
    var dbclient = await db;
    var dbHelper = QuizData.progresshelper;
    int _solvednumber =await dbHelper.getcurrentnumber(table_name);
    List<Map> result = await dbclient.query(table_name,
        columns: [columnId, columnQuestion, columnAnswer],
        where: '$columnId <= ?',
        whereArgs: [_solvednumber]);
    List<Question> question = new List();
    for (int i = 0; i < result.length; i++){
      question.add(new Question.fromMap(result[i]));
    }
    return question;
  }


}