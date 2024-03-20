import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/components/classDetailComponent.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import 'package:waseda_connect/provider/provider.dart';

import 'package:waseda_connect/screen/Tutorial/Tutorial2.dart';
import '../../components/TimeTableComponent.dart'; // 正しいパスに置き換えてください
import 'package:shared_preferences/shared_preferences.dart';

class TimeTable extends ConsumerStatefulWidget {
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends ConsumerState<TimeTable> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ダミーデータの定義
  List<List<LessonModel>>? allLessonData;

  Map<String, dynamic> selectedLessonData = {
    "id": "1",
    "name": "数",
    "day": "月",
    "period": 1
  };
  Map<String, dynamic>? timeTableData;

  int? defaultYear;
  int? defaultSemester;
  int? defaultGrade;
  List<TimeTableModel>? allTimeTablesData;
  int nowYear = 2024;

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    //時間割
    final TimeTableLogic instance = TimeTableLogic();
    var newTimeTablesData = await instance.getTimeTablesByYear(nowYear);
    //授業データ
    final LessonLogic lessonInstance = LessonLogic();
    List<List<LessonModel>> newAllLessonData = [];
    for (var timeTableData in newTimeTablesData) {
      var newLessonData =
          await lessonInstance.getLessonsByTimeTableId(timeTableData.id);
      newAllLessonData.add(newLessonData);
    }

    // SharedPreferencesからデータを読み込む
    // 値が存在しない場合はnullを許容
    setState(() {
      defaultYear = prefs.getInt('defaultYear');
      defaultSemester = prefs.getInt('defaultSemester');
      defaultGrade = prefs.getInt('defaultGrade');
      allTimeTablesData = newTimeTablesData;
      allLessonData = newAllLessonData;
    });
    print(allLessonData);
    print(allTimeTablesData);
    print("よんだよね");
  }

  void _onFacultyChanged(String? selected) {
    // 選択された項目に基づいて何かアクションを行う
    print(selected);
    if (selected != null && selected != "") {
      print("a${selected}a");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClassDetailComponent(
                  classId: selected,
                )),
      );
    }
  }

  //タイムテーブルの遷移。
  Future<void> _setTimeTable(String id) async {
    final TimeTableLogic instance = TimeTableLogic();
    var newTimeTableData = await instance.getTimeTable(id);
    if (newTimeTableData != null) {
      setState(() {
        defaultYear = newTimeTableData.year;
        defaultSemester = newTimeTableData.semester;
        defaultGrade = newTimeTableData.grade;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('defaultYear', newTimeTableData.year);
      await prefs.setInt('defaultSemester', newTimeTableData.semester);
      await prefs.setInt('defaultGrade', newTimeTableData.grade);
      await prefs.setString('defaultId', newTimeTableData.id);
    }
  }

//時間割追加というなの入力画面への遷移
  Future<void> _addNewTimeTable() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Tutorial2()),
    );
  }

  //時間割消去
  Future<bool> _deleteTimeTable(String id, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultId = prefs.getString('defaultId');
    if (defaultId != id) {
      final TimeTableLogic instance = TimeTableLogic();
      await instance.deleteTimeTable(id);
      var newTimeTablesData = await instance.getAllTimeTables();
      setState(() {
        allTimeTablesData = newTimeTablesData;
      });

      return true;
    } else {
      print("消去できない");
      return false;
    }
  }

//じかんわり
  @override
  Widget build(BuildContext context) {
    var appBarText =
        "${nowYear ?? ""}年度";

    // 仮定: timeTableDatasとlessonDatasはあらかじめ定義されているとします
    // 例えば、List<TimeTableData> timeTableDatas = [...]; と List<List<LessonData>> lessonDatas = [...];
    // ここで、lessonDatasは各タイムテーブルに対応するレッスンのリストのリストです

    return Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _showTitleOptions(context);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        body: PageView.builder(
          itemCount: 4, // 生成するページ数
          itemBuilder: (context, index) {
            // indexは0から始まり、ページ数-1までの値を取ります
            // ここで、各ページのヘッダータイトルやその他のデータを設定できます
            String appBarText = "ページ ${index + 1} のタイトル";

            // allLessonDataとallTimeTablesDataは、各ページに対応するデータのリストを想定
            // selectedLessonDataは、選択されたレッスンデータを想定（ページごとに異なる場合は、これもリストで管理する）
            return Scaffold(
              appBar: AppBar(
                title: Text(appBarText),
          
              ),
              body: TimeTableComponent(
                lessonData:
                    allLessonData?[index], // index番目のタイムテーブルに対応するレッスンデータ
                timeTableData: allTimeTablesData?[index], // index番目のタイムテーブルデータ
                selectedLessonData: selectedLessonData, // 選択されたレッスンデータ
                onSelected: _onFacultyChanged,
              ),
            );
          },
        ));
  }

  void _showTitleOptions(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 20), // メニューの位置を調整
      items: [
        // 2021年から2025年までの数字をリストとして生成し、それぞれの年に対してPopupMenuEntryを作成
        ...List.generate(5, (index) {
          int year = 2021 + index; // 2021年からスタート
          return PopupMenuItem<String>(
            value: year.toString(), // valueには年を文字列として設定
            child: Text('$year年'),
          );
        }),
      ],
    ).then((String? newValue) {
      if (newValue != null) {
        // 選択された年に対する処理
        _setTimeTable(newValue);
      }
    });
  }
}
