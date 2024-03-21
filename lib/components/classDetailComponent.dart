import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/main.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/screen/TimeTable/TimeTable.dart';
import 'package:waseda_connect/provider/provider.dart';
import 'package:waseda_connect/hooks/UrlLaunchWithUri.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// delete: 時間割から「削除」or add: 時間割に「追加」
enum ButtonMode {
  delete,
  add,
}

class ClassDetailComponent extends ConsumerStatefulWidget {
  final String classId; // 表示する詳細画面のpKey
  final ButtonMode btnMode; // 詳細画面におけるボタンの役割 ButtonModeに定義

  ClassDetailComponent({
    Key? key,
    required this.classId,
    required this.btnMode,
  }) : super(key: key);

  @override
  _ClassDetailComponentState createState() => _ClassDetailComponentState();
}

class _ClassDetailComponentState extends ConsumerState<ClassDetailComponent> {
  ClassModel? classData;

  @override
  void initState() {
    super.initState();
    _fetchClassInfoById(widget.classId);
  }

  Future<void> _fetchClassInfoById(String classId) async {
    final ClassLogic instance = ClassLogic();
    final ClassModel newClassData = await instance.searchClassesByPKey(classId);
    setState(() {
      classData = newClassData;
    });
  }

  Future<void> _deleteLessonById(String id) async {
    final LessonLogic instance = LessonLogic();
    await instance.deleteLessonByClassId(id);
  }

  Future<void> _addLessonById(String id) async {
    final LessonLogic instance = LessonLogic();
    await instance.insertLesson(id);
  }

  final _urlLaunchWithUri = UrlLaunchWithUri();

  void _showDeleteModal() {
    showDialog(
        context: context, // showDialogにはBuildContextが必要です
        builder: (BuildContext context) {
          return ModalComponent(
            title: '${classData!.courseName}',
            content: '本当に削除しますか',
            onConfirm: () {
              int count = 0;
              Navigator.popUntil(context, (_) => count++ >= 2);
              print("削除");

              _deleteLessonById(classData!.pKey);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${classData!.courseName}が消去されました")));

              ref.read(updateTimeTableProvider.notifier).state = true;
            },
            onCancel: () {
              print("キャンセル");
              Navigator.pop(context);
            },
            yesText: "削除する",
          );
        });
  }

  void _showAddModal() {
    showDialog(
      context: context, // showDialogにはBuildContextが必要です
      builder: (BuildContext context) {
        return ModalComponent(
          title: '${classData!.courseName}を追加しますか',
          content: '${classData!.courseName}を追加しますか',
          onConfirm: () async {
            _addLessonById(classData!.pKey);
            ref.read(updateTimeTableProvider.notifier).state = true;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => MyHomePage()), // NewPageに遷移
              (Route<dynamic> route) =>
                  false, // 条件がfalseを返すまで（つまり、すべてのルートを削除するまで）
            );
          },
          onCancel: () {
            print("キャンセル");
            ref.read(updateTimeTableProvider.notifier).state = true;

            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          yesText: "追加",
        );
      },
    );
  }

  Widget _buildButton() {
    if (widget.btnMode == ButtonMode.delete) {
      return ElevatedButton(
        onPressed: () {
          // 削除機能のロジックを実装
          print('削除ボタンが押されました');
          _showDeleteModal(); // 削除モーダルを表示する関数
        },
        child: Text('削除'),
      );
    } else if (widget.btnMode == ButtonMode.add) {
      return ElevatedButton(
        onPressed: () {
          // 追加機能のロジックを実装
          print('追加ボタンが押されました');
          _showAddModal(); // 追加モーダルを表示する関数
        },
        child: Text('追加'),
      );
    } else {
      return SizedBox(); // ボタンを非表示にするための空のSizedBox
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('授業詳細'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.launch),
            onPressed: () {
              // ここにアイコンボタンがタップされたときの処理を記述
              final url =
                  "https://www.wsl.waseda.jp/syllabus/JAA104.php?pKey=${classData!.pKey.replaceAll(RegExp(r'\r'), "")}";
              print(url);
              _urlLaunchWithUri.launchUrlWithUri(context, url);
            },
          ),
        ],
      ),
      body: classData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('属性')),
                        DataColumn(label: Text('情報')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('ID')),
                          DataCell(Text(classData!.pKey)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('コース名')),
                          DataCell(Text(classData!.courseName)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('講師')),
                          DataCell(Text(classData!.instructor)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('学期')),
                          DataCell(Text('${classData!.semester}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('科目区分')),
                          DataCell(Text(classData!.courseCategory)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('配当年次')),
                          DataCell(Text('${classData!.assignedYear}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('クラスルーム')),
                          DataCell(Text(classData!.classroom)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('キャンパス')),
                          DataCell(Text(classData!.campus)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('使用言語')),
                          DataCell(Text(classData!.languageUsed)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('形式')),
                          DataCell(Text('${classData!.teachingMethod}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('コースコード')),
                          DataCell(Text(classData!.courseCode)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('大分野名称')),
                          DataCell(Text(classData!.majorField)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('中分野名称')),
                          DataCell(Text(classData!.subField)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('小分野名称')),
                          DataCell(Text(classData!.minorField)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('レベル')),
                          DataCell(Text(classData!.level)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('授業形態')),
                          DataCell(Text(classData!.classFormat)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classDay1')),
                          DataCell(Text('${classData!.classDay1}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classStart1')),
                          DataCell(Text('${classData!.classStart1}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classTime1')),
                          DataCell(Text('${classData!.classTime1}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classDay2')),
                          DataCell(Text('${classData!.classDay2}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classStart2')),
                          DataCell(Text('${classData!.classStart2}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('classTime2')),
                          DataCell(Text('${classData!.classTime2}')),
                        ]),
                      ],
                    ),
                  ),
                ),
                // widget.btnModeがButtonMode.deleteの時以下を
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildButton(), // 別の関数でボタンを構築する
                )
              ],
            ),
    );
  }
}
