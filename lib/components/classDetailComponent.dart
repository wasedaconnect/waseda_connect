import 'package:flutter/material.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/screen/TimeTable/TimeTable.dart';
import 'package:waseda_connect/provider/provider.dart';

class ClassDetailComponent extends StatefulWidget {
  final String classId;

  ClassDetailComponent({Key? key, required this.classId}) : super(key: key);

  @override
  _ClassDetailComponentState createState() => _ClassDetailComponentState();
}

class _ClassDetailComponentState extends State<ClassDetailComponent> {
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

  Future<void> _deleteLessonById(String id) async{
    final LessonLogic instance = LessonLogic();
    await instance.deleteLessonByClassId(id);
  }

  void _showDeleteModal() {
    showDialog(
        context: context, // showDialogにはBuildContextが必要です
        builder: (BuildContext context) {
          return ModalComponent(
            title: '${classData!.courseName}',
            content: '本当に削除しますか',
            onConfirm: ()  {
              int count = 0;
              Navigator.popUntil(context, (_) => count++ >= 2);
              print("削除");
              _deleteLessonById(classData!.pKey);
            },
            onCancel: () {
              print("キャンセル");
              Navigator.pop(context);
            },
            yesText: "削除する",
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('授業詳細'),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // ここにアイコンボタンがタップされたときの処理を記述
                print('設定アイコンがタップされました');
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // ここに削除機能のロジックを実装
                    print('削除ボタンが押されました');
                    _showDeleteModal();
                  },
                  child: Text('削除'),
                ),
              ),
            ],
          ),
    );
  }
}
