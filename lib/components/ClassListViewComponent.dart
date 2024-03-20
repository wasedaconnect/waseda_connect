import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import 'package:waseda_connect/provider/provider.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/components/ModalComponent.dart';

class ClassListViewComponent extends StatefulWidget {
  final List<ClassModel>? allSyllabusData;

  const ClassListViewComponent({Key? key, required this.allSyllabusData})
      : super(key: key);

  @override
  State<ClassListViewComponent> createState() => _ClassListViewComponentState();
}

class _ClassListViewComponentState extends State<ClassListViewComponent> {
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

  Future<void> onItemTap(String pKey) async {
    final LessonLogic instance = LessonLogic();
    await instance.insertLesson(pKey);
    print("完了");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(1.0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData.courseName,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              classData.instructor,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${termMap[classData.semester]} ${numToDay[classData.classDay1]} ${classData.classStart1}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => showDialog(
                  context: context, // showDialogにはBuildContextが必要です
                  builder: (BuildContext context) {
                    return ModalComponent(
                      title: '${classData.courseName}を追加しますか',
                      content: '${classData.courseName}をついかしますか',
                      onConfirm: () async {
                        onItemTap(classData.pKey);
                        ref.read(updateTimeTableProvider.notifier).state = true;
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      onCancel: () {
                        print("キャンセル");
                        ref.read(updateTimeTableProvider.notifier).state = true;
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      yesText: "追加",
                    );
                  },
                ), // タップされたときの処理
              ),
            ),
          ],
        ),
      ),
    );
  }
}