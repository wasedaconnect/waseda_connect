import 'package:flutter/material.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import '../../constants/Dict.dart'; // 必要に応じてパスを調整してください

class TimeTableComponent extends StatefulWidget {
  final List<LessonModel>? lessonData;
  final Map<String, dynamic>? selectedLessonData;
  final TimeTableModel? timeTableData;
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
        0: FixedColumnWidth(26.0),
        for (int i = 1; i <= weekdays.length; i++) i: FlexColumnWidth(),
      };

  TableBorder get tableBorder => TableBorder.all(
        color: Colors.grey[250] ?? Colors.grey,
        width: 1,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
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
                (index) => _buildTableRow(
                    index + 1, weekdays_num, startTime, endTime, context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(int period, List<int> weekdays,
      List<String> startTime, List<String> endTime, BuildContext context) {
    return TableRow(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.11,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ここではstartTimeとendTimeを直接指定していますが、
                // 実際にはwidget.timeTableDataから取得する必要があります
                Text('${startTime[period - 1]}', style: TextStyle(fontSize: 8)),
                SizedBox(height: 20),
                Text('$period',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('${endTime[period - 1]}', style: TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ),
        for (int i = 0; i < weekdays.length; i++)
          _buildLessonCell(period, weekdays_num[i]),
      ],
    );
  }

  Widget _buildLessonCell(int period, int day) {
    // lessonDataがnullの場合は空のリストを使用
    final lessonData = widget.lessonData ?? [];

    // lessonDataから特定の曜日と時限に対応する授業を検索
    var lesson = lessonData.firstWhere(
      (lesson) => lesson.day1 == day && lesson.start1 == period,
      orElse: () => LessonModel(
          id: "",
          name: "",
          timeTableId: "",
          createdAt: "",
          day1: 0,
          start1: 0,
          time1: 0,
          day2: 0,
          start2: 0,
          time2: 0,
          classroom: "",
          classId: "",
          color: 0),
    );

    // selectedLessonDataがnullの場合は空のマップを使用
    final selectedLessonData = widget.selectedLessonData ?? {};

    bool isSelected = selectedLessonData['id'] == lesson.id;

    return InkWell(
      onTap: () => widget.onSelected?.call(lesson.classId),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.11,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.grey[350], // 授業セルの色
          // border: Border.all(
          //   color: Colors.grey, // 枠線の色を設定
          // ),
          borderRadius: BorderRadius.circular(10.0), // 角丸
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 1,
              offset: Offset(0, 2), // 影のオフセット
            ),
          ],
        ),
        child: Center(
          child: Column(
            // Column内の要素を垂直方向に中央揃えするための設定
            mainAxisAlignment: MainAxisAlignment.center,
            // Columnの高さを最小限に設定
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lesson.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(height: 8),
              lesson.name.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.0), // 左右に8ピクセルのパディングを追加
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0), // 角丸
                        color: Colors.white, // 背景色
                      ),
                      child: Text(
                        lesson.classroom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
