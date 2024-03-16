# waseda_connect

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

##　ブランチの名前
Task-[人の名前]-タスクナンバー-[そのタスクの概要]
例：Task-dai-1-create-member-information

## デバッグ方法

1.クローム版
    flutter run -d chrome
    これでは残念ながらデータベースが使えないが、shared preferrence使える。
    さくっと確認したいときにおすすめ

2.android stadio版
    flutter run -d emulator-5554

## 変数名
キャメルケース
例:
〇 getClassData
×　get-class-data
×　getclassdata
※flutterはキャメルを推奨していないらしいｗ

## データベース構成
https://docs.google.com/presentation/d/1Oyn8XtQDgYXBIrew6IH6SYVhs1smf11sE_Pn4rhUnGg/edit?usp=sharing

## フォルダ構成
lib/
├── components/          # 再利用可能なUIコンポーネント、入力フォームなど
├── constants/           # アプリ全体で使用する定数
├── models/              # データモデルクラス
│   └── user.dart
├── screens/             # 画面ごとのウィジェット
│   ├── home_screen.dart　# 一例
│   └── detail_screen.dart
├── utils/               # ヘルパークラスやユーティリティ関数
│   └── database_helper.dart #データベースの初期化
└── main.dart



##　使用パッケージ
    pubspec.yamlに記載
    
    flutter pub add [パッケージ名]

    flutter pub get 更新

##　フォーマッター
    dart format lib

## テスト
/test内にdartファイルを記述
flutter test





