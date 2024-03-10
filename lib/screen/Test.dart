import 'package:flutter/material.dart';
import '../Screen/Syllabus/SyllabusSearchResult.dart';

class Test extends StatefulWidget {
  @override
  _SyllabusSearchScreenState createState() => _SyllabusSearchScreenState();
}

class _SyllabusSearchScreenState extends State<Test> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchResults = []; // 検索結果を保持するリスト

  void _searchSyllabus() {
  // 検索ロジックを実行し、結果を取得 (ここではダミーの結果を使用)
    final searchResults = List.generate(10, (index) => '検索結果 $index : ${_controller.text}');

    // 検索結果を表示する新しいページに遷移
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SyllabusSearchResultsScreen(searchResults: searchResults),
      ),
    );
  }

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
              controller: _controller,
              decoration: InputDecoration(
                labelText: '検索',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchSyllabus,
                    ),
          ),
          onFieldSubmitted: (value) => _searchSyllabus(),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_searchResults[index]),
              // ここに検索結果の詳細画面へのリンクなど、必要に応じて他のウィジェットを追加できます。
            );
          },
        ),
      ),
    ],
  ),
);
}
}