import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:waseda_connect/screen/Syllabus/Syllabus.dart';

Widget syllabusToWidget(Syllabus model) {
  return Container(
      padding: const EdgeInsets.all(1), child: Text('syllabusToWidget'));
}

class DisplaySyllabus extends StatefulWidget {
  const DisplaySyllabus({super.key});

  @override
  State<DisplaySyllabus> createState() => _DisplaySyllabus();
}

class _DisplaySyllabus extends State<DisplaySyllabus> {
  // シラバス配列: 初期値 --> 空リスト
  List syllabuses = [];

  // 外部APIにリクエスト
  Future<void> fetchSyllabuses(String text) async {
    Response response =
        await Dio().get('https://api.wasedatime.com/v1/syllabus/$text');
    syllabuses = response.data;
    setState(() {});
    print(syllabuses);
  }

  @override
  void initState() {
    super.initState();
    // 最初に一度だけ呼ばれる
    fetchSyllabuses('CSE');
  }

  String getDayOfWeek(String dayIndex) {
    switch (dayIndex) {
      case '1':
        return '月曜日';
      case '2':
        return '火曜日';
      case '3':
        return '水曜日';
      case '4':
        return '木曜日';
      case '5':
        return '金曜日';
      case '6':
        return '土曜日';
      case '7':
        return '日曜日';
      default:
        return '';
    }
  }

  String getClassOfDay(String classIndex) {
    switch (classIndex) {
      case '1':
        return '1時限目';
      case '2':
        return '2時限目';
      case '3':
        return '3時限目';
      case '4':
        return '4時限目';
      case '5':
        return '5時限目';
      case '6':
        return '6時限目';
      case '7':
        return '7時限目';
      case '8':
        return '8時限目';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
        itemCount: syllabuses.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Center(
                child: Column(
              children: <Widget>[
                Card(
                    margin: const EdgeInsets.all(1.0),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  syllabuses[index]['c'].toString(),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  syllabuses[index]['e'].toString(),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  getDayOfWeek(syllabuses[index]['i'][0]['d']
                                          .toString()) +
                                      ' : ' +
                                      getClassOfDay(syllabuses[index]['i'][0]
                                              ['p']
                                          .toString()),
                                  // getDayOfWeek(syllabuses[index]['i']['d']),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   margin: const EdgeInsets.all(16.0),
                          //   child: Text(syllabuses[index]['c'].toString(),
                          //       style: TextStyle(fontSize: 20.0)),
                          //   width: 50,
                          // ),
                          // Container(
                          //   margin: const EdgeInsets.all(16.0),
                          //   child: Text(
                          //       "B:" + syllabuses[index]['c'].toString(),
                          //       style: TextStyle(fontSize: 20.0)),
                          // ),
                          // Container(
                          //   margin: const EdgeInsets.all(16.0),
                          //   child: Text(
                          //       "C:" + syllabuses[index]['d'].toString(),
                          //       style: TextStyle(fontSize: 20.0)),
                          // )
                        ],
                      ),
                      onTap: () {
                        print(syllabuses[index]['a'].toString());
                      },
                    ))
              ],
            )),
          );
        });

    final con = Center(
      child: SizedBox(
        height: 400,
        child: list,
      ),
    );

    final apb = AppBar(
      title: TextFormField(
          initialValue: 'CSE',
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            print(text);
            fetchSyllabuses(text);
          }),
    );

    final sca = Scaffold(
      appBar: apb,
      backgroundColor: Colors.grey,
      body: con,
    );

    return sca;
  }
}
// // ツイート
// class Tweet {
//   // ユーザーの名前
//   final String userName;
//   // アイコン画像
//   final String iconUrl;
//   // 文章メッセージ
//   final String text;
//   // 送信日時
//   final String createdAt;

//   // コンストラクタ
//   Tweet(this.userName, this.iconUrl, this.text, this.createdAt);
// }

// class Syllabus {
//   final Int classID;
//   final String

//   Syllabus(
//     this.className,
//   );
// }

// // 適当なモデル
// final models = [
//   Tweet('ルフィ', 'icon1.png', '海賊王におれはなる！', '2022/1/1'),
//   Tweet('ゾロ', 'icon2.png', 'おれはもう！二度と敗けねェから！', '2022/1/2'),
//   Tweet('ナミ', 'icon3.png', 'もう背中向けられないじゃないっ！', '2022/1/3'),
//   Tweet('ウソップ', 'icon4.png', 'お前らの”伝説のヒーロー”になってやる！', '2022/1/4'),
//   Tweet('サンジ', 'icon5.png', 'たとえ死んでもおれは女は蹴らん・・・！', '2022/1/5'),
//   Tweet('チョッパー', 'icon6.png', '人間ならもっと自由だ！', '2022/1/6'),
//   Tweet('ビビ', 'icon7.png', 'もう一度仲間と呼んでくれますか!?', '2022/1/7'),
//   Tweet('ロビン', 'icon8.png', '生ぎたいっ！', '2022/1/8'),
//   Tweet('フランキー', 'icon9.png', '存在することは罪にはならねェ！', '2022/1/9'),
//   Tweet('ブルック', 'icon10.png', '男が一度・・・必ず帰ると言ったのだから！', '2022/1/10'),
//   Tweet('ジンベイ', 'icon11.png', '失ったものばかり数えるな！', '2022/1/11'),
//   Tweet('シャンクス', 'icon1.png', 'この帽子をお前に預ける', '2022/2/1'),
//   Tweet('ヒルルク', 'icon2.png', '違う!…人に忘れられた時さ…!', '2022/2/2'),
//   Tweet('ドクタークレハ', 'icon3.png', '優しいだけじゃ人は救えないんだ!', '2022/2/3'),
//   Tweet('ティーチ', 'icon4.png', '人の夢は!終わらねェ!', '2022/2/4'),
//   Tweet('ガンフォール', 'icon5.png', '人の生きるこの世界に“神”などおらぬ!', '2022/2/5'),
//   Tweet('ボンクレー', 'icon6.png', '理由なんざ他にゃいらねェ!', '2022/2/6'),
//   Tweet('イワンコフ', 'icon7.png', '“奇跡”ナメるんじゃないよォ!', '2022/2/7'),
//   Tweet('ニューゲート', 'icon8.png', 'バカな息子をそれでも愛そう・・・', '2022/1/8'),
//   Tweet('エース', 'icon9.png', '愛してくれて・・・ありがとう', '2022/2/9'),
//   Tweet('ロー', 'icon10.png', '取るべきイスは…必ず奪う!', '2022/2/10'),
//   Tweet('サボ', 'icon11.png', '以後ルフィのバックにはおれがついてる!', '2022/2/11'),
//   Tweet('バルトロメオ', 'icon1.png', 'この子分盃!勝手に頂戴いたしますだべ!', '2022/3/1'),
// ];

// モデル => ウィジェット に変換する
// Widget modelToWidget(Tweet model) {
//   // ユーザーアイコン
//   final icon = Container(
//     margin: const EdgeInsets.all(20),
//     width: 60,
//     height: 60,
//     // 画像を丸くする
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(30.0),
//       child: Image.asset('assets/images/${model.iconUrl}'),
//     ),
//   );

//   // 名前と時間
//   final metaText = Container(
//     padding: const EdgeInsets.all(6),
//     height: 40,
//     alignment: Alignment.centerLeft,
//     child: Text(
//       '${model.userName}    ${model.createdAt}',
//       style: const TextStyle(color: Colors.grey),
//     ),
//   );

//   // 本文
//   final text = Container(
//     padding: const EdgeInsets.all(8),
//     alignment: Alignment.centerLeft,
//     child: Text(
//       model.text,
//       style: const TextStyle(fontWeight: FontWeight.bold),
//     ),
//   );

//   // 部品を並べる
//   return Container(
//     padding: const EdgeInsets.all(1),
//     decoration: BoxDecoration(
//       // 全体を青い枠線で囲む
//       border: Border.all(color: Colors.blue),
//       color: Colors.white,
//     ),
//     width: double.infinity,
//     // 高さ
//     height: 120,
//     child: Row(
//       children: [
//         // アイコン
//         icon,
//         Expanded(
//           child: Column(
//             children: [
//               // 名前と時間
//               metaText,
//               // 本文
//               text,
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
