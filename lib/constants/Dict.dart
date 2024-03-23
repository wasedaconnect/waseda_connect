import 'package:flutter/material.dart';

// Map<String, String> gradesDict = {
//   '1': '1年生',
//   '2': '2年生',
//   '3': '3年生',
//   '4': '4年生',
// };
Map<String, List<String>> wasedaFacultiesAndDepartmentsDict = {
  '政治経済学部': ['政治学科', '経済学科', '国際政治経済学科', '未選択'],
  '法学部': [
    '法学科',
  ],
  '教育学部': [
    '教育学科',
    '初等教育学専攻',
    '国語国文学科',
    '英語英文学科',
    '社会科',
    '理学科',
    '複合文化学科',
  ],
  '商学部': [
    '経営トラック',
    '会計トラック',
    'マーケティングトラック',
    'ファイナンストラック',
    '保険・リスクマネジメントトラック',
    'ビジネスエコノミクストラック',
    '未選択'
  ],
  '社会科学部': [
    '社会科学科',
  ],
  '国際教養学部': [
    '国際教養学科',
  ],
  '文化構想学部': [
    '文化構想学科',
    '多元文化論系',
    '複合文化論系',
    '表象・メディア論系',
    '文芸・ジャーナリズム論系',
    '現代人間論系',
    '社会構築論系',
    '未選択'
  ],
  '文学部': [
    '文学科',
    '哲学コース',
    '東洋哲学コース',
    '心理学コース',
    '社会学コース',
    '教育学コース',
    '日本語日本文学コース',
    '中国語中国文学コース',
    '英文学コース',
    'フランス語フランス文学コース',
    'ドイツ語ドイツ文学コース',
    'ロシア語ロシア文学コース',
    '演劇映像コース',
    '美術史コース',
    '日本史コース',
    'アジア史コース',
    '西洋史コース',
    '考古学コース',
    '中東・イスラーム研究コース',
    '未選択'
  ],
  '基幹理工学部': [
    '数学科',
    '応用数理学科',
    '機械科学・航空宇宙学科',
    '電子物理システム学科',
    '情報理工学科',
    '情報通信学科',
    '表現工学科',
    '未選択'
  ],
  '創造理工学部': [
    '建築学科',
    '総合機械工学科',
    '経営システム工学科',
    '社会環境工学科',
    '環境資源工学科',
  ],
  '先進理工学部': [
    '物理学科',
    '応用物理学科',
    '化学・生命化学科',
    '応用化学科',
    '生命医科学科',
    '電気・情報生命工学科',
  ],
  '人間科学部': [
    '人間環境科学科',
    '健康福祉科学科',
    '人間情報科学科',
  ],
  'スポーツ科学部': [
    'スポーツ科学科',
    'スポーツ医科学コース',
    '健康スポーツコース',
    'トレーナーコース',
    'スポーツコーチングコース',
    'スポーツビジネスコース',
    'スポーツ文化コース',
    '未選択'
  ],
};
List<String> weekdays = ['月', '火', '水', '木', '金', '土', '他'];
List<int> weekdays_num = [1, 2, 3, 4, 5, 6, 7];
final Map<int, String> numToDay = {
  0: '',
  1: '月',
  2: '火',
  3: '水',
  4: '木',
  5: '金',
  6: '土',
  7: '他',
};

final startTime = ['08:50', '10:40', '13:10', '15:05', '17:00', '18:55'];
final endTime = ['10:30', '12:20', '14:50', '16:45', '18:40', '20:35'];
final List<String> semesters = ['春', '秋'];
final List<int> grades = [1, 2, 3, 4];
final List<int> years = [5, 6];

const Map<int, String> departments = {
  0: '',
  1: '政治経済学部',
  2: '法学部',
  3: '教育学部',
  4: '商学部',
  5: '社会科学部',
  6: '人間科学部',
  7: 'スポーツ科学部',
  8: '国際教養学部',
  9: '文化構想学部',
  10: '文学部',
  11: '人間科学部（通信教育課程）',
  12: '基幹理工学部',
  13: '創造理工学部',
  14: '先進理工学部', // ここまで学士過程
  15: '大学院政治学研究科',
  16: '大学院経済学研究科',
  17: '大学院法学研究科',
  18: '大学院文学研究科',
  19: '大学院商学研究科',
  20: '大学院教育学研究科',
  21: '大学院人間科学研究科',
  22: '大学院社会科学研究科',
  23: '大学院アジア太平洋研究科',
  24: '大学院日本語教育研究科',
  25: '大学院情報生産システム研究科',
  26: '大学院法務研究科',
  27: '大学院会計研究科',
  28: '大学院スポーツ科学研究科',
  29: '大学院基幹理工学研究科',
  30: '大学院創造理工学研究科',
  31: '大学院先進理工学研究科', // ここまで一般的な修士過程
  32: '大学院環境・エネルギー研究科',
  33: '大学院国際コミュニケーション研究科',
  34: '大学院経営管理研究科', // ここまで修士過程
  35: '芸術学校',
  36: '日本語教育研究センター',
  37: '留学センター',
  38: 'グローバルエデュケーションセンター',
};
const Map<int, String> durations = {
  1: '１年以上',
  2: '２年以上',
  3: '３年以上',
  4: '４年以上',
  5: '１・２年のみ',
  6: '１年のみ',
  7: '５年以上',
};
const Map<int, String> classFormatDict = {
  1: '【対面】',
  2: '【対面】ハイブリッド（対面回数半数以上）',
  3: '【オンライン】リアルタイム配信',
  4: '【オンライン】フルオンデマンド',
  5: '【オンライン】ハイブリッド（対面回数半数未満）',
  7: '【非常時】リアルタイム配信',
  8: '対面',
  0: 'なし', // 追加された「なし」のマッピング
};

// 全て+1して1を通年、2を春学期、...
Map<int, String> termMap = {
  0: '', // 「春学期／秋学期」「春学期／夏学期（アジア）」「集中（春・秋学期）」「夏秋期」も含む
  1: '春学期', // 「集中講義（春学期）」「春夏期」「春学期（アジア）／夏学期（アジア）」も含む
  2: '秋学期', // 「通年／秋学期」「集中講義（秋学期）」「秋学期（アジア）／冬学期（アジア）」「秋学期／冬学期（アジア）」も含む
  3: '春クォーター', // 「春学期（アジア）」も含む
  4: '夏クォーター', // 「夏学期（アジア）」も含む
  5: '夏季集中', // 「夏シーズン」も含む
  6: '冬クォーター', // 「冬学期（アジア）」も含む
  7: '秋クォーター', // 「秋学期（アジア）」も含む
  8: '冬季集中',
  9: '春季集中',
  10: '通年',
};

Map<int, List<int>> termToSemester = {
//通年に変換
  1: [1,2], //春学期に変換
  2: [3,4],
  3: [1],
  4: [2],
  5: [1,2],
  6: [4],
  7: [3],
  8: [3,4],
  9: [3,4],
  10: [1, 2,3,4],
};

Map<int, String> periodMap = {
  0: "",
  1: "１時限",
  2: "２時限",
  3: "３時限",
  4: "４時限",
  5: "５時限",
  6: "６時限",
  7: "７時限",
  10: "フルオンデマンド",
  11: "その他"
};

//学期とその色

// 授業の背景色候補(最初の色「Colors.grey[300]」は授業が空の場合。)
Map<int, Color> classColor = {
  // 授業が空の場合
  0: Color.fromRGBO(231, 231, 231, 1),
  1: Color.fromRGBO(230, 226, 254, 1.0),
  2: Color.fromRGBO(188, 236, 248, 1.0),
  3: Color.fromRGBO(0, 0, 0, 1.0), // # に変更
  4: Color.fromRGBO(27, 17, 17, 1), // # に変更
};

List<String> semesterList = ["春学期", "夏学期","秋学期","冬学期"];
List mainColor = [
  const Color.fromARGB(255, 194, 224, 238),
  const Color.fromARGB(255, 246, 179, 174),
   const Color.fromARGB(255, 194, 224, 238),
  const Color.fromARGB(255, 246, 179, 174)
];

