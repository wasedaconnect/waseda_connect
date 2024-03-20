import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waseda_connect/components/ModalComponent.dart';
import 'package:waseda_connect/models/ClassModel.dart';

import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/provider/provider.dart';
import '../Screen/Syllabus/SyllabusSearchResult.dart';

import '../screen/Syllabus/SyllabusSearchResult.dart';

class Test extends StatefulWidget {
  @override
  _SyllabusSearchScreenState createState() => _SyllabusSearchScreenState();
}

class _SyllabusSearchScreenState extends State<Test> {
  List<ClassModel>? allSyllabusData;

  Future<void> _searchSyllabus(String value) async {
    // ここにテキストフィールドの入力値が変化したときの処理を記述
    final ClassLogic instance = ClassLogic();
    final newAllSyllabusData = await instance.searchClassesByName(value);
    setState(() {
      allSyllabusData = newAllSyllabusData;
    });
    print(allSyllabusData!.length);
  }

  // 検索結果を保持するリスト

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('シラバス検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              onChanged: (value) async {
                await _searchSyllabus(value); // テキストフィールドの入力が変化するたびに実行
              },
            ),
          ),
          Expanded(
            child: allSyllabusData != null && allSyllabusData!.isNotEmpty
                ? ListView.builder(
                    itemCount: allSyllabusData!.length, // リストのアイテム数
                    itemBuilder: (context, index) {
                      // 各アイテムに対するウィジェットを構築
                      final classData = allSyllabusData![index];
                      return SyllabusItemWidget(
                          classData: classData); // カスタムウィジェット
                    },
                  )
                : Container(), // allSyllabusDataが空の場合は何も表示しない
          ),
        ],
      ),
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
    return InkWell(
      onTap: () => showDialog(
        context: context, // showDialogにはBuildContextが必要です
        builder: (BuildContext context) {
          return ModalComponent(
            title: '${classData.courseName}を追加しますか',
            content: '${classData.courseName}をついかしますか',
            onConfirm: () async {
              onItemTap(classData.pKey);
              ref.read(updateTimeTableProvider.notifier).state = true;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onCancel: () {
              print("キャンセル");
              ref.read(updateTimeTableProvider.notifier).state = true;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            yesText: "追加",
          );
        },
      ), // タップされたときの処理
      child: ListTile(
        title: Text(classData.courseName),
      ),
    );
  }
}
