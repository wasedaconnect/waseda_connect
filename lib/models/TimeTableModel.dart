import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import '../utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeTableModel {
  final String id; // IDはulidで入れる
  final int grade; //学年
  final String semester; //学期
  final int year; //学年
  final String createdAt; // 作成日時（ISO 8601形式の文字列を想定）

  TimeTableModel({
    required this.id,
    required this.grade,
    required this.semester,
    required this.year,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade': grade,
      'createdAt': createdAt,
      'semester': semester,
      'year': year,
    };
  }
}

class TimeTableLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  //挿入のロジック
  Future<void> insertTimeTable(TimeTableModel timeTable) async {
    final db = await _dbHelper.timeTableDatabase;
    final idWithUlid = Ulid().toString();
    final nowTime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
    var timeTableWithUlid = TimeTableModel(
      id: idWithUlid,
      grade: timeTable.grade,
      createdAt: nowTime,
      semester: timeTable.semester,
      year: timeTable.year,
    );
    await db.insert(
      'timeTables',
      timeTableWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 各フィールドをデフォルトの時間割に設定。
    await prefs.setString('defaultId', idWithUlid);
    await prefs.setInt('defaultGrade', timeTable.grade);
    await prefs.setString('defaultSemester', timeTable.semester);
    await prefs.setInt('defaultYear', timeTable.year);
  }

  //時間割をすべて取り出す
  Future<List<TimeTableModel>> getAllTimeTables() async {
    final db = await _dbHelper.timeTableDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'timeTables',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return TimeTableModel(
        id: maps[i]['id'],
        grade: maps[i]['grade'],
        createdAt: maps[i]['createdAt'],
        semester: maps[i]['semester'],
        year: maps[i]['year'],
      );
    });
  }

  //時間割を上から一つ取り出す。
  Future<TimeTableModel?> getTopTimeTable() async {
    final db = await _dbHelper.timeTableDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'timeTables',
      orderBy: 'createdAt DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return TimeTableModel(
        id: maps[0]['id'],
        grade: maps[0]['grade'],
        createdAt: maps[0]['createdAt'],
        semester: maps[0]['semester'],
        year: maps[0]['year'],
      );
    } else {
      return null; // データが存在しない場合はnullを返す
    }
  }

//IDに紐づいて時間割を返す。
  Future<TimeTableModel?> getTimeTable(String id) async {
    final db = await _dbHelper.timeTableDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'timeTables',
      where: 'id = ?', // 指定されたIDに一致するレコードを検索する
      whereArgs: [id], // where句のプレースホルダーに渡す値
    );

    if (maps.isNotEmpty) {
      return TimeTableModel(
        id: maps[0]['id'],
        grade: maps[0]['grade'],
        createdAt: maps[0]['createdAt'],
        semester: maps[0]['semester'],
        year: maps[0]['year'],
      );
    } else {
      return null; // データが存在しない場合はnullを返す
    }
  }
  // 既存のメソッド...

  // 時間割を削除する
  Future<void> deleteTimeTable(String id) async {
    final db = await _dbHelper.timeTableDatabase;
    await db.delete(
      'timeTables',
      where: 'id = ?', // 指定されたIDに一致するレコードを検索する
      whereArgs: [id], // where句のプレースホルダーに渡す値
    );
  }
}
