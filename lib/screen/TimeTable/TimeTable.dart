import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/components/FormModalComponent.dart';
import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/components/classDetailComponent.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import 'package:waseda_connect/provider/provider.dart';

import '../../components/TimeTableComponent.dart'; // 正しいパスに置き換えてください
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/update_request_provider.dart';
import '../../components/Update/UpdateModal.dart';

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
    print(allLessonData);
    print(allTimeTablesData);
    print("よんだよね");
  }

  Future<void> _addDummyLesson(String name, int day, int period,
      TimeTableModel? timeTableData, context) async {
    final LessonLogic instance = LessonLogic();
    await instance.insertDummyLesson(name, day, period, timeTableData);
    ref.read(updateTimeTableProvider.notifier).state = true;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showAddLessonModal(int day, int period, TimeTableModel? timeTableData) {
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
              print("追加aaa");
              _addDummyLesson(_textFieldController.text, day, period,
                  timeTableData, context);
            },
            onCancel: () {
              print("キャンセル");
              Navigator.pop(context);
            },
            yesText: "追加する",
          );
        });
  }

  Future<void> _deleteDummyLesson(
      int day, int period, TimeTableModel? timeTableData) async {
    final LessonLogic instance = LessonLogic();
    await instance.deleteDummyLesson(day, period, timeTableData);
  }

  void _showDeleteDummyLessonModal(
      int day, int period, TimeTableModel? timeTableData) {
    showDialog(
        context: context, // showDialogにはBuildContextが必要です
        builder: (BuildContext context) {
          return ModalComponent(
            title: '授業の登録',
            content: '本当に削除しますか',
            onConfirm: () {
              // int count = 0;
              // Navigator.popUntil(context, (_) => count++ >= 2);
              _deleteDummyLesson(day, period, timeTableData);
              print("ダミーデータ削除");
              ref.read(updateTimeTableProvider.notifier).state = true;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onCancel: () {
              print("キャンセル");
              Navigator.pop(context);
            },
            yesText: "削除する",
          );
        });
  }

  void _onLongFacultyChanged(String? id) {
    // 長押しされた項目に基づいて何かアクションを行う
    print(id);
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy - size.height, // タップしたウィジェットの上に表示
        width: size.width,
        child: buildPopup(context),
      ),
    );

    overlay?.insert(overlayEntry);

    // どこかをタップしたらOverlayを消す
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _onFacultyChanged(
      String? selected, int day, int period, TimeTableModel? timeTableData) {
    // 選択された項目に基づいて何かアクションを行う
    print(selected);
    print("day");
    print(day);
    print("period");
    print(period);
    if (selected == "") {
      //空の場合
      _showAddLessonModal(day, period, timeTableData);
    }
    if (selected == "dummy") {
      //ダミーデータ
      print('ダミ0');
      _showDeleteDummyLessonModal(day, period, timeTableData);
    } else if (selected != null && selected != "") {
      print("a${selected}a");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClassDetailComponent(
                  classId: selected,
                  btnMode: ButtonMode.delete,
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
    ref.watch(updateRequesterProvider)
    .when(data: (updateRequestFlag) {
      if (updateRequestFlag) {
        print("アプデある");
        WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateModal(),
        );
      });
      }
    },
    loading: () => {
      // ローディング中の処理をここに書く
    },
    error: (error, stack) => {
      // エラーが発生した場合の処理をここに書く
    },);
    

    var appBarText = "${defaultYear}年度";
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
          title: Text(
            appBarText,
            textAlign: TextAlign.center,
          ),
          toolbarHeight: 30,
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
          itemCount: 2, // 生成するページ数
          itemBuilder: (context, index) {
            String appBarText = semesterList[index];

            // allLessonDataとallTimeTablesDataは、各ページに対応するデータのリストを想定
            // selectedLessonDataは、選択されたレッスンデータを想定（ページごとに異なる場合は、これもリストで管理する）
            return Scaffold(
              backgroundColor: mainColor[index],
              appBar: AppBar(
                title: Text(appBarText),
                backgroundColor: mainColor[index],
                toolbarHeight: 30,
              ),
              body: TimeTableComponent(
                lessonData:
                    allLessonData?[index], // index番目のタイムテーブルに対応するレッスンデータ
                timeTableData: allTimeTablesData?[index], // index番目のタイムテーブルデータ
                // 選択されたレッスンデータ
                onSelected: _onFacultyChanged,
                onLongSelected: _onLongFacultyChanged,
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

  Widget buildPopup(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(top: 5), // 吹き出しの矢印部分のスペースを作る
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'ここに情報を表示',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
