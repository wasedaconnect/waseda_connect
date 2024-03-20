import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/components/FormModalComponent.dart';
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

  int defaultYear = 2024;

  List<TimeTableModel>? allTimeTablesData;

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      defaultYear = prefs.getInt('defaultYear') ?? 2024;
    });
    //時間割
    final TimeTableLogic instance = TimeTableLogic();
    var newTimeTablesData = await instance.getTimeTablesByYear(defaultYear);
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
      allTimeTablesData = newTimeTablesData;
      allLessonData = newAllLessonData;
    });
    // print(allLessonData.length);
    // print(allTimeTablesData.length);
    print("よんだよね");
  }

  Future<void> _addDummyLesson(String name, int day, int period) async {
    final LessonLogic instance = LessonLogic();
    await instance.insertDummyLesson(name, day, period);
  }

  void _showAddLessonModal(int day, int period) {
    showDialog(
        context: context, // showDialogにはBuildContextが必要です
        builder: (BuildContext context) {
          TextEditingController _textFieldController = TextEditingController();
          return FormModalComponent(
            title: '授業の登録',
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "授業名を入力してください"),
            ),
            onConfirm: () {
              // int count = 0;
              // Navigator.popUntil(context, (_) => count++ >= 2);
              _addDummyLesson(_textFieldController.text, day, period);
              print("追加");
              ref.read(updateTimeTableProvider.notifier).state = true;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onCancel: () {
              print("キャンセル");
              Navigator.pop(context);
            },
            yesText: "追加する",
          );
        });
  }

  void _onFacultyChanged(String? selected, int day, int period) {
    // 選択された項目に基づいて何かアクションを行う
    print(selected);
    print(day);
    print(period);
    if (selected == "") {
      //空の場合
      _showAddLessonModal(day, period);
    }
    if (selected != null && selected != "") {
      print("a${selected}a");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClassDetailComponent(
                  classId: selected,
                )),
      ).then((value) {
        // 再描画
        setState(() {
          _fetchData();
          print("戻り");
        });
      });
    }
  }

  //タイムテーブルの遷移。
  Future<void> _setTimeTable(int year) async {
    print(year);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultYear', year);
    setState(() {
      defaultYear = year;
    });
  }

//じかんわり
  @override
  Widget build(BuildContext context) {
    var appBarText = "${defaultYear ?? ""}年度";
    final pageTransition = ref.watch(updateTimeTableProvider);
    if (pageTransition) {
      // ページ遷移が検知された場合に実行する関数
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchData();
        // 必要に応じて、状態をリセット
        ref.read(updateTimeTableProvider.notifier).state = false;
      });
    }

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
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 20), // メニューの位置を調整
      items: [
        // 2021年から2025年までの数字をリストとして生成し、それぞれの年に対してPopupMenuEntryを作成
        ...List.generate(5, (index) {
          int year = 2021 + index; // 2021年からスタート
          return PopupMenuItem<int>(
            value: year, // valueには年を文字列として設定
            child: Text('$year年'),
          );
        }),
      ],
    ).then((int? newValue) {
      if (newValue != null) {
        // 選択された年に対する処理
        _setTimeTable(newValue);
        ref.read(updateTimeTableProvider.notifier).state = true;
      }
    });
  }
}
