import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/DatabaseHelper.dart';

class ClassModel {
  final String pKey; //キーとして追加
  // final String academicYear; //年度
  final int department; //学部
  final String courseName; //コースの名前
  final String instructor; //教師名
  final int semester; //学期
  // final String classTime 時間
  final String courseCategory; //授業カテゴリー
  final int assignedYear; //割り当て年
  final int credits; //単位数
  final String classroom; //教室
  final String campus; //キャンパス
  // final String courseKey;//こーづコード
  // final String classCode;//クラスコード
  final String languageUsed;
  final int teachingMethod; //オンラインか対面か
  final String courseCode; //コースのコード、学科とかわかるかも
  final String majorField; //大分類
  final String subField; //中分類
  final String minorField; //小分類
  final String level; //レベル
  final String classFormat; //形式
  final int isOpened;
  // 新しい属性を追加
  final int classDay1; //何曜日か（月曜日：1、火曜日：２　のように入っている
  final int classStart1; //スタートする時限（フルオンデマンドやその他の時は10か11が入っている。）
  final int classTime1; //何時間分のコマか
  //コマが週に二個あるときの２
  final int classDay2;
  final int classStart2;
  final int classTime2;

  ClassModel({
    required this.pKey,
    required this.department,
    required this.courseName,
    required this.instructor,
    required this.semester,
    required this.courseCategory,
    required this.assignedYear,
    required this.credits,
    required this.classroom,
    required this.campus,
    required this.languageUsed,
    required this.teachingMethod,
    required this.courseCode,
    required this.majorField,
    required this.subField,
    required this.minorField,
    required this.level,
    required this.classFormat,
    // 新しい属性の初期化
    required this.classDay1,
    required this.classStart1,
    required this.classTime1,
    required this.classDay2,
    required this.classStart2,
    required this.classTime2,
    required this.isOpened,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
        pKey: map['pKey'],
        department: map['department'],
        courseName: map['courseName'],
        instructor: map['instructor'],
        semester: map['semester'],
        courseCategory: map['courseCategory'],
        assignedYear: map['assignedYear'],
        credits: map['credits'],
        classroom: map['classroom'],
        campus: map['campus'],
        languageUsed: map['languageUsed'],
        teachingMethod: map['teachingMethod'],
        courseCode: map['courseCode'],
        majorField: map['majorField'],
        subField: map['subField'],
        minorField: map['minorField'],
        level: map['level'],
        classFormat: map['classFormat'],
        // 新しい属性をマップから読み込む
        classDay1: map['classDay1'],
        classStart1: map['classStart1'],
        classTime1: map['classTime1'],
        classDay2: map['classDay2'],
        classStart2: map['classStart2'],
        classTime2: map['classTime2'],
        isOpened: map['isOpened']);
  }

  Map<String, dynamic> toMap() {
    return {
      'pKey': pKey,

      'department': department,
      'courseName': courseName,
      'instructor': instructor,
      'semester': semester,

      'courseCategory': courseCategory,
      'assignedYear': assignedYear,
      'credits': credits,
      'classroom': classroom,
      'campus': campus,

      'languageUsed': languageUsed,
      'teachingMethod': teachingMethod,
      'courseCode': courseCode,
      'majorField': majorField,
      'subField': subField,
      'minorField': minorField,
      'level': level,
      'classFormat': classFormat,
      // 新しい属性をマップに追加
      'classDay1': classDay1,
      'classStart1': classStart1,
      'classTime1': classTime1,
      'classDay2': classDay2,
      'classStart2': classStart2,
      'classTime2': classTime2,
      'isOpened': isOpened
    };
  }
}

class ClassLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertClass() async {
    final rawData = await rootBundle.loadString('assets/ClassData.csv'); //テスト用
    // CSVデータをリストに変換（ヘッダーをスキップ）
    List<List<dynamic>> listData =
        CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(rawData)
            .skip(1)
            .toList();

    int i = 0;

    final db = await _dbHelper.classDatabase;
    var batch = db.batch(); // バッチ処理の開始
    for (var rowData in listData) {
      var classData = ClassModel(
          department: int.parse(rowData[1]) ?? 0,
          courseName: rowData[2],
          instructor: rowData[3],
          semester: int.parse(rowData[4]) ?? 0,
          courseCategory: rowData[6],
          assignedYear: int.parse(rowData[7]) ?? 0,
          credits: int.parse(rowData[8]) ?? 0,
          classroom: rowData[9],
          campus: rowData[10],
          languageUsed: rowData[13],
          teachingMethod: int.parse(rowData[14]) ?? 0,
          courseCode: rowData[15],
          majorField: rowData[16],
          subField: rowData[17],
          minorField: rowData[18],
          level: rowData[19],
          classFormat: rowData[20],
          isOpened: int.parse(rowData[21]) ?? 0,
          // 新しい属性
          classDay1: int.parse(rowData[22]) ?? 0,
          classStart1: int.parse(rowData[23]) ?? 0,
          classTime1: int.parse(rowData[24]) ?? 0,
          classDay2: int.parse(rowData[25]) ?? 0,
          classStart2: int.parse(rowData[26]) ?? 0,
          classTime2: int.parse(rowData[27]) ?? 0,
          pKey: rowData[28]);

      batch.insert(
        'classes',
        classData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      i += 1;
      print(i);
    }

    await batch.commit(noResult: true); // バッチ処理のコミット
  }

//コースネームでlike検索。
  Future<List<ClassModel>> searchClassesByName(String courseName) async {
    final db = await _dbHelper.classDatabase;
    final List<Map<String, dynamic>> maps = await db
    .query(
      'classes',
      where: 'courseName LIKE ?',
      whereArgs: ['%$courseName%'],
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }

  Future<List<ClassModel>> searchClasses(
      int? day, int? time, int? teachingMethod, int? department) async {
    final db = await _dbHelper.classDatabase;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    // 条件を動的に構築
    if (day != null) {
      whereClauses.add('(classDay1 = ? OR classDay2 = ?)');
      whereArgs.addAll([day, day]);
    }
    if (time != null) {
      whereClauses.add('(classStart1 = ? OR classStart2 = ?)');
      whereArgs.addAll([time, time]);
    }
    if (teachingMethod != null) {
      whereClauses.add('teachingMethod = ?');
      whereArgs.add(teachingMethod);
    }
    if (department != null) {
      whereClauses.add('department = ?');
      whereArgs.add(department);
    }

    // WHERE句を組み立て
    String? whereClause =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    // クエリ実行
    final List<Map<String, dynamic>> maps = await db.query('classes',
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: 10);

    // 結果をClassModelのリストに変換
    return List<ClassModel>.from(maps.map((map) => ClassModel.fromMap(map)));
  }
}
