import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import '../utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

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
    var timeTableWithUlid = TimeTableModel(
      id: Ulid().toString(),
      grade: timeTable.grade,
      createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      semester: timeTable.semester,
      year: timeTable.year,
    );
    await db.insert(
      'timeTables',
      timeTableWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
