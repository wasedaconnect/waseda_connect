import 'package:flutter/material.dart';
import '../../constants/Dict.dart'; // 必要に応じてパスを調整してください

class TimeTableComponent extends StatefulWidget {
  final List<Map<String, dynamic>> lessonData;
  final Map<String, dynamic> selectedLessonData;
  final Map<String, dynamic> timeTableData;
  final Function(String?)? onSelected;

  const TimeTableComponent({
    Key? key,
    required this.lessonData,
    required this.timeTableData,
    required this.selectedLessonData,
    this.onSelected,
  }) : super(key: key);

  @override
  _TimeTableComponentState createState() => _TimeTableComponentState();
}

class _TimeTableComponentState extends State<TimeTableComponent> {
  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(64.0),
        for (int i = 1; i <= weekdays.length; i++) i: FlexColumnWidth(),
      };

  TableBorder get tableBorder => TableBorder.all(
        color: Colors.black,
        width: 1,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.red,
          child: Table(
            columnWidths: columnWidths,
            border: tableBorder,
            children: [
              TableRow(
                children: [
                  SizedBox(width: 64.0),
                  for (var day in weekdays)
                    Center(
                        child: Text(day,
                            style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: columnWidths,
              border: tableBorder,
              children: List.generate(
                6, // 仮定で一日の最大時限数を6とします
                (index) => _buildTableRow(index + 1, weekdays, context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(
      int period, List<String> weekdays, BuildContext context) {
    return TableRow(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.11,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ここではstartTimeとendTimeを直接指定していますが、
                // 実際にはwidget.timeTableDataから取得する必要があります
                Text('08:00', style: TextStyle(fontSize: 12)),
                Text('第$period時限',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('09:00', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        for (int i = 0; i < weekdays.length; i++)
          _buildLessonCell(period, weekdays[i]),
      ],
    );
  }

  Widget _buildLessonCell(int period, String day) {
    // lessonDataから特定の曜日と時限に対応する授業を検索
    var lesson = widget.lessonData.firstWhere(
      (lesson) => lesson['day'] == day && lesson['period'] == period,
      orElse: () => {},
    );

    bool isSelected = widget.selectedLessonData['id'] == lesson['id'];

    return InkWell(
      onTap: () => widget.onSelected?.call(lesson['id']),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.11,
        color: isSelected ? Colors.blue[100] : null, // 選択された授業をハイライト
        child: Center(
          child: Text(
            lesson.isNotEmpty ? lesson['name'] : '空きコマ',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
