import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waseda_connect/models/ClassModel.dart';

import 'Screen/displaySyllabus/SearchForm.dart';

import 'Screen/TimeTable/TimeTable.dart';
import 'Screen/Test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Tutorial/Tutorial.dart';
// 必要なページをimportします。例: Syllabus.dart
//やること
//ロード中画面を創る
//popで戻って着火するようにする。
//ポップアップメッセージ機能を創る
//終わったら、classデータとlessonデータを紐づける。

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waseda Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Waseda Connect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
    _copyDatabaseToDocumentDirectory().then((_) {
      setState(() {
        _isLoading = false; // ロード完了
      });
      ;
    }); //ロードしていることをユーザーに知らせるものを作りたい。
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialShown = prefs.getBool('tutorialShown') ?? false;
    if (!tutorialShown) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Tutorial()),
      );
    }
  }

  Future<void> _loadCsvData() async {
    // final prefs = await SharedPreferences.getInstance();
    // final isGetClassData = prefs.getBool('getClassData') ?? false;
    // if (isGetClassData){
    // ロードに一分かかるデータベース。
    final ClassLogic instance = ClassLogic();
    await instance.insertClass();
    print("完了");
    // }
    // await prefs.setBool('getClassData',true);
    // newTimeTableをデータベースに挿入する処理を呼び出
  }

  Future<void> _copyDatabaseToDocumentDirectory() async {
    final dbPath =
        path.join((await getApplicationDocumentsDirectory()).path, 'Class.db');
    // データベースファイルが既に存在するか確認
    await deleteDatabase(dbPath);
    // アセットからデータを読み込む
    final data = await rootBundle.load('assets/Class.db');
    final bytes = data.buffer.asUint8List();
    // ファイルを書き込む
    await File(dbPath).writeAsBytes(bytes);
    print("完了");
  }

  // ページのリストを定義
  final List<Widget> _pages = [
    // ここにページのウィジェットを追加
    TimeTable(),
    SearchPage(),
    Test(),
  ];

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ロード中はロード画面を表示
      return Scaffold(
        body: Center(
          child: LinearProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '時間割',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'シラバス',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'テスト',
            ),
            // 他のタブアイテムも同様に追加
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }
  }
}
