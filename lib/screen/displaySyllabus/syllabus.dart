// 無限ループのListViewを作成

import 'package:flutter/material.dart';

class DisplaySyllabus extends StatelessWidget {
  const DisplaySyllabus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InfinityScrollPage(),
    );
  }
}

class InfinityScrollPage extends StatefulWidget {
  const InfinityScrollPage({Key? key}) : super(key: key);

  @override
  State<InfinityScrollPage> createState() => _InfinityScrollPageState();
}

class _InfinityScrollPageState extends State<InfinityScrollPage> {
  final List<String> _contents = [];
  final int loadLength = 30;

  int _lastIndex = 0;

  Future<void> _getContents() async {
    await Future.delayed(const Duration(seconds: 3));

    for (int i = _lastIndex; i < _lastIndex + loadLength; i++) {
      _contents.add('Item $i');
    }

    _lastIndex += loadLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinity Scroll Sample')),
      body: Center(
        child: FutureBuilder(
          future: _getContents(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            //4
            return InfinityListView(
              contents: _contents,
              getContents: _getContents,
            );
          },
        ),
      ),
    );
  }
}

class InfinityListView extends StatefulWidget {
  final List<String> contents;
  final Future<void> Function() getContents;

  const InfinityListView({
    Key? key,
    required this.contents,
    required this.getContents,
  }) : super(key: key);

  @override
  State<InfinityListView> createState() => _InfinityListViewState();
}

class _InfinityListViewState extends State<InfinityListView> {
  //5
  late ScrollController _scrollController;
  //6
  bool _isLoading = false;

  //7
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {
        _isLoading = true;

        await widget.getContents();

        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  //8
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      //9
      controller: _scrollController,
      //10
      itemCount: widget.contents.length + 1,
      separatorBuilder: (BuildContext context, int index) => Container(
        width: double.infinity,
        height: 2,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context, int index) {
        //11
        if (widget.contents.length == index) {
          return const SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return SizedBox(
          height: 50,
          child: Center(
            child: Text(
              widget.contents[index],
            ),
          ),
        );
      },
    );
  }
}
