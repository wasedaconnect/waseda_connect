import 'package:flutter/material.dart';

class SyllabusSearchResultsScreen extends StatelessWidget {
  final List<String> searchResults;

  SyllabusSearchResultsScreen({Key? key, required this.searchResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('検索結果'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchResults[index]),
          );
        },
      ),
    );
  }
}
