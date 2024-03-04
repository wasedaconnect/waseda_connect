import 'package:flutter/material.dart';
import 'Screen/Syllabus/Syllabus.dart';
import 'Screen/TimeTable/TimeTable.dart';
import 'Screen/Test.dart';
// 必要なページをimportします。例: Syllabus.dart

void main() {
  runApp(const MyApp());
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

  // ページのリストを定義
  final List<Widget> _pages = [
    // ここにページのウィジェットを追加
    TimeTable(),
    Syllabus(), 
    Test(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
