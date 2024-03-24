import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Future<bool> _addLessonById(String id) async {
    final LessonLogic instance = LessonLogic();
    return (await instance.insertLesson(id));
  }

  // db 'lesson'のidの授業に対してcolorを追加
  Future<void> _changeLessonColor(String id, int colorId) async {
    final LessonLogic instance = LessonLogic();
    return (await instance.changeLessonColor(id, colorId));
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

  Widget _colorButton(BuildContext context, int colorId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // クリックされたときの処理をここに追加
          _changeLessonColor(classData!.pKey, colorId);
          print('Selected colorId: $colorId');
          print('Selected color: ${classColor[colorId]}');
        },
        style: ElevatedButton.styleFrom(
          // primary: color, // ボタンの背景色を指定
          minimumSize: Size(40, 40), // ボタンの最小サイズを指定
        ).copyWith(
          backgroundColor:
              MaterialStateProperty.all<Color>(classColor[colorId]!), // 背景色を設定
          shape: MaterialStateProperty.all<OutlinedBorder>(
            CircleBorder(), // 円形のボタンを作成
          ),
        ),
        child: Icon(
          Icons.check,
          size: 16, // チェックマークのアイコン
          color: Colors.black, // チェックマークの色
        ), // ボタン内に表示するテキスト
      ),
    );
  }

  Widget _buildButton() {
    if (widget.btnMode == ButtonMode.delete) {
      return IconButton(
        onPressed: () {
          // 削除機能のロジックを実装
          print('削除ボタンが押されました');
          _showDeleteModal(); // 削除モーダルを表示する関数
        },
        icon: Icon(Icons.delete),
      );
    } else if (widget.btnMode == ButtonMode.add) {
      // return Row(
      //   mainAxisSize: MainAxisSize.min, // コンテンツのサイズに合わせてRowの幅を最小限にする
      //   children: <Widget>[
      //     IconButton(
      //       onPressed: () {
      //         // 追加機能のロジックを実装
      //         print('追加ボタンが押されました');
      //         _showAddModal(); // 追加モーダルを表示する関数
      //       },
      //       icon: Icon(Icons.add),
      //     ),
      //     Text('追加'), // アイコンの隣に表示されるテキスト
      //   ],
      // );
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () {
            // タップされたときの処理
            print('追加ボタンが押されました');
            _showAddModal(); // 追加モーダルを表示する関数
          },
          child: Material(
            color: Colors.grey[200], // ここで背景色を設定
            borderRadius: BorderRadius.circular(6), // 背景の角を丸くする
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 5, vertical: 3), // パディングを調整
              child: Row(
                mainAxisSize: MainAxisSize.min, // 子ウィジェットのサイズに合わせる
                children: <Widget>[
                  Icon(Icons.add), // アイコンの色も調整可能
                  Text('追加'), // テキストの色を白に設定
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(); // ボタンを非表示にするための空のSizedBox
    }
  }

  Widget baseInfoContents() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0), //
                child: Text(
                  '学部',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  '${departments[classData!.department]}',
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '学期',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  '${termMap[classData!.semester]}',
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '曜日/時限',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  '${numToDay[classData!.classDay1]}曜日 / ${periodMap[classData!.classStart1]}',
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          if (classData!.classDay2 != 7)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                  child: Text(
                    '曜日/時限 2',
                    style: TextStyle(
                      fontSize: 18.0, // フォントサイズを大きく
                      fontWeight: FontWeight.bold, // フォントを太く
                    ),
                  ),
                ),
                Container(
                  width: double.infinity, // 横幅を最大限に
                  padding: EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 18.0), // パディング
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                    ),
                  ),
                  child: Text(
                    '${periodMap[classData!.classDay2]}曜日 / ${periodMap[classData!.classStart2]}',
                    style: TextStyle(
                      fontSize: 17.0, // フォントサイズを大きく
                    ),
                  ),
                ),
              ],
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '教員名',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.instructor,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '教室',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.classroom,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '使用言語',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.languageUsed,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '授業形態',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.classFormat,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  'レベル',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.level,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '配当年次',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  '${classData!.assignedYear}年以上',
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '形式',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  '${classData!.teachingMethod}',
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '科目区分',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.courseCategory,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '大分野名称',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.majorField,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '中分野名称',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.subField,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  '小分野名称',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.minorField,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 子ウィジェットを左揃えに
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Text(
                  'コースコード',
                  style: TextStyle(
                    fontSize: 18.0, // フォントサイズを大きく
                    fontWeight: FontWeight.bold, // フォントを太く
                  ),
                ),
              ),
              Container(
                width: double.infinity, // 横幅を最大限に
                padding: EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 18.0), // パディング
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey), // 下線
                  ),
                ),
                child: Text(
                  classData!.courseCode,
                  style: TextStyle(
                    fontSize: 17.0, // フォントサイズを大きく
                  ),
                ),
              ),
            ],
          ),
          // 他の行も同様に追加...
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('授業詳細'),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                // タップされたときの処理
                final url =
                    "https://www.wsl.waseda.jp/syllabus/JAA104.php?pKey=${classData!.pKey.replaceAll(RegExp(r'\r'), "")}";
                print(url);
                _urlLaunchWithUri.launchUrlWithUri(context, url);
              },
              child: Material(
                color: Colors.grey[200], // ここで背景色を設定
                borderRadius: BorderRadius.circular(6), // 背景の角を丸くする
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5, vertical: 3), // パディングを調整
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 子ウィジェットのサイズに合わせる
                    children: <Widget>[
                      Text('シラバス'), // テキストの色を白に設定
                      Icon(Icons.launch), // アイコンの色も調整可能
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: classData == null
          ? Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2, // タブの数を定義します
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Columnの子ウィジェットを中央に配置
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Rowの子ウィジェットを中央に配置
                    children: [
                      Expanded(
                        child: Text(
                          ' ${classData!.courseName}', // クラスデータからコース名を取得
                          style: TextStyle(
                            fontSize: 24, // テキストのサイズを大きく
                            fontWeight: FontWeight.bold, // テキストを太字に
                          ),
                          overflow:
                              TextOverflow.ellipsis, // オーバーフロー時にはテキストの末尾に...を表示
                          maxLines: 3,
                        ),
                      ),
                      _buildButton()
                    ],
                  ),
                  // ここにTabBarが続く
                  TabBar(
                    labelColor: Colors.blue[600], // 選択されたタブのテキスト色
                    unselectedLabelColor: Colors.grey, // 選択されていないタブのテキスト色
                    tabs: [
                      Tab(text: '授業情報'),
                      Tab(text: '基本情報'),
                    ],
                  ),
                  // その他のウィジェットがここに続く...
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 1つ目のタブの内容
                        Text('授業情報のコンテンツ'),
                        // 2つ目のタブの内容
                        baseInfoContents(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      // body: classData == null
      //     ? Center(child: CircularProgressIndicator())
      //     : Column(
      //         children: [
      //           Expanded(
      //             child: SingleChildScrollView(
      //               child: DataTable(
      //                 columns: const [
      //                   DataColumn(label: Text('属性')),
      //                   DataColumn(label: Text('情報')),
      //                 ],
      //                 rows: [
      //                   DataRow(cells: [
      //                     DataCell(Text('ID')),
      //                     DataCell(Text(classData!.pKey)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('コース名')),
      //                     DataCell(Text(classData!.courseName)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('講師')),
      //                     DataCell(Text(classData!.instructor)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('学期')),
      //                     DataCell(Text('${termMap[classData!.semester]}')),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('科目区分')),
      //                     DataCell(Text(classData!.courseCategory)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('配当年次')),
      //                     DataCell(Text('${classData!.assignedYear}年以上')),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('クラスルーム')),
      //                     DataCell(Text(classData!.classroom)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('キャンパス')),
      //                     DataCell(Text(classData!.campus)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('使用言語')),
      //                     DataCell(Text(classData!.languageUsed)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('形式')),
      //                     DataCell(Text('${classData!.teachingMethod}')),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('コースコード')),
      //                     DataCell(Text(classData!.courseCode)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('大分野名称')),
      //                     DataCell(Text(classData!.majorField)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('中分野名称')),
      //                     DataCell(Text(classData!.subField)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('小分野名称')),
      //                     DataCell(Text(classData!.minorField)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('レベル')),
      //                     DataCell(Text(classData!.level)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('授業形態')),
      //                     DataCell(Text(classData!.classFormat)),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('曜日01')),
      //                     DataCell(Text('${numToDay[classData!.classDay1]}')),
      //                   ]),
      //                   DataRow(cells: [
      //                     DataCell(Text('時限01')),
      //                     DataCell(
      //                         Text('${periodMap[classData!.classStart1]}')),
      //                   ]),
      //                   if (classData!.classDay2 != 7)
      //                     DataRow(cells: [
      //                       DataCell(Text('曜日02')),
      //                       DataCell(Text('${numToDay[classData!.classDay2]}')),
      //                     ]),
      //                   if (classData!.classStart2 != 0)
      //                     DataRow(cells: [
      //                       DataCell(Text('時限02')),
      //                       DataCell(
      //                           Text('${periodMap[classData!.classStart2]}')),
      //                     ]),
      //                 ],
      //               ),
      //             ),
      //           ),
      //           // widget.btnModeがButtonMode.deleteの時以下を
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: _buildButton(), // 別の関数でボタンを構築する
      //           )
      //         ],
      //       ),
    );
  }
}
