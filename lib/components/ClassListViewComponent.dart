import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/main.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import 'package:waseda_connect/provider/provider.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/components/classDetailComponent.dart';

class ClassListViewComponent extends ConsumerStatefulWidget {
  final List<ClassModel>? allSyllabusData;

  const ClassListViewComponent({
    Key? key,
    required this.allSyllabusData,
  }) : super(key: key);

  @override
  _ClassListViewComponentState createState() => _ClassListViewComponentState();
}

class _ClassListViewComponentState
    extends ConsumerState<ClassListViewComponent> {
  @override
  Widget build(BuildContext context) {
    return widget.allSyllabusData != null
        ? ListView.builder(
            itemCount: widget.allSyllabusData!.length,
            itemBuilder: (context, index) {
              final classData = widget.allSyllabusData![index];
              return SyllabusItemWidget(
                classData: classData,
              );
            },
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

class SyllabusItemWidget extends ConsumerWidget {
  final ClassModel classData;

  const SyllabusItemWidget({Key? key, required this.classData})
      : super(key: key);

  Future<bool> _addLessonById(String id) async {
    final LessonLogic instance = LessonLogic();
    return (await instance.insertLesson(id));
  }

  void _showAddModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context, // showDialogにはBuildContextが必要です
      builder: (BuildContext context) {
        return ModalComponent(
          title: '${classData!.courseName}を追加しますか',
          content: '${classData!.courseName}を追加しますか',
          onConfirm: () async {
            if (await _addLessonById(classData!.pKey)) {
              ref.read(updateTimeTableProvider.notifier).state = true;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${classData!.courseName}が追加されました")));
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("同じ時間割に授業が存在します")));
              Navigator.pop(context);
            }
          },
          onCancel: () {
            print("キャンセル");
            ref.read(updateTimeTableProvider.notifier).state = true;

            Navigator.pop(context);
          },
          yesText: "追加",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              // margin: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                // borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailComponent(
                      classId: classData.pKey,
                      btnMode: ButtonMode.add,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData.courseName,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${termMap[classData.semester]} ${numToDay[classData.classDay1]} ${periodMap[classData.classStart1]}' +
                                  (classData.classDay2 != 7 ||
                                          classData.classStart2 != 0
                                      ? ' / ${numToDay[classData.classDay2]} ${periodMap[classData.classStart2]}'
                                      : ''),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${departments[classData.department]} / ${classData.instructor}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        // 追加ボタンが押されたときの処理を記述
                        _showAddModal(context, ref);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
