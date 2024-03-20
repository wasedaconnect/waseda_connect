import 'package:flutter/material.dart';

class ListForm extends StatefulWidget {
  final List<dynamic>? items;
  final dynamic selectedItem;
  final String? text;
  final Function(dynamic)? onSelected;

  const ListForm({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.text,
    this.onSelected,
  }) : super(key: key);

  @override
  _ListFormState createState() => _ListFormState();
}

class _ListFormState extends State<ListForm> {
  dynamic _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  @override
  void didUpdateWidget(covariant ListForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        _selectedItem = widget.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${widget.text}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        DropdownButton<dynamic>(
          value: _selectedItem,
          icon: const Icon(Icons.arrow_downward),
          elevation: 8,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (dynamic newValue) {
            setState(() {
              _selectedItem = newValue;
            });
            if (widget.onSelected != null) {
              widget.onSelected!(newValue);
            }
          },
          items: widget.items?.map<DropdownMenuItem<dynamic>>((dynamic value) {
            return DropdownMenuItem<dynamic>(
              value: value,
              child: Text(value.toString()), // `value`を文字列に変換して表示
            );
          }).toList(),
        ),
      ],
    );
  }
}
