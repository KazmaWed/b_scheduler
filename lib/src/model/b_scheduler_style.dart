import 'package:flutter/material.dart';

/// BSchedulerのスタイル設定を管理するクラス
///
/// 色、テキストスタイル、サイズなどのビジュアル設定を一元管理します。
class BSchedulerStyle {
  // -------------------- レイアウト定数 --------------------

  /// 基本のボーダー幅
  final double borderWidth;

  /// 現在時刻ラインのボーダー幅
  final double currentTimeBorderWidth;

  /// 縦スクロール時の時間列幅
  final double verticalScrollTimeColumnWidth;

  /// 縦スクロール時の日付列幅
  final double verticalScrollDateColumnWidth;

  /// 横スクロール時の時間行の高さ
  final double horizontalScrollTimeRowHeight;

  // -------------------- テキストスタイル --------------------

  /// 時間表示のテキストスタイル（デフォルト: 11px）
  final TextStyle timeTextStyle;

  /// 日付列の日付表示スタイル（デフォルト: 14px, bold）
  final TextStyle dateTextStyle;

  /// 週行の日付表示スタイル（デフォルト: 12px, bold）
  final TextStyle weekDateTextStyle;

  /// 曜日行のテキストスタイル（デフォルト: 12px, bold）
  final TextStyle weekdayTextStyle;

  /// 横スクロール時間ヘッダーのテキストスタイル（デフォルト: 10px）
  final TextStyle horizontalTimeHeaderTextStyle;

  /// 詳細アイテムのテキストスタイル（デフォルト: 12px, black）
  final TextStyle detailItemTextStyle;

  /// 概要アイテムのテキストスタイル（デフォルト: 12px）
  final TextStyle overviewItemTextStyle;

  /// 月表示アイテムのテキストスタイル（デフォルト: 12px）
  final TextStyle monthlyItemTextStyle;

  /// 横スクロールアイテムのテキストスタイル（デフォルト: 10px, black）
  final TextStyle horizontalItemTextStyle;

  /// デバッグ情報のテキストスタイル（デフォルト: 12px, bold, 半透明赤）
  final TextStyle debugTextStyle;

  // -------------------- 色設定 --------------------

  /// 罫線・区切り線の基本色（デフォルト: colorScheme.outline）
  final Color? outlineColor;

  /// プライマリカラー（デフォルト: colorScheme.primary）
  final Color? primaryColor;

  /// プライマリ上のテキスト色（デフォルト: colorScheme.onPrimary）
  final Color? onPrimaryColor;

  /// プライマリコンテナ色（デフォルト: colorScheme.primaryContainer）
  final Color? primaryContainerColor;

  /// サーフェス上のテキスト色（デフォルト: colorScheme.onSurface）
  final Color? onSurfaceColor;

  /// サーフェス背景色（デフォルト: colorScheme.surface）
  final Color? surfaceColor;

  /// 現在時刻ラインの色（デフォルト: colorScheme.tertiary）
  final Color? currentTimeBorderColor;

  // -------------------- Alpha値（透明度）設定 --------------------

  /// 罫線の基本透明度（デフォルト: 84）
  final int baseOutlineAlpha;

  /// 薄い罫線の透明度（デフォルト: 42）
  final int lightOutlineAlpha;

  /// 週行の日付ヘッダー背景の透明度（デフォルト: 64）
  final int weekDateHeaderAlpha;

  /// アイテムの基本透明度（デフォルト: 200）
  final int itemAlpha;

  // -------------------- パディング・スペーシング --------------------

  /// 曜日行の水平パディング（デフォルト: 4.0）
  final EdgeInsets weekdayRowPadding;

  /// 時間行の右パディング（デフォルト: 4.0）
  final double timeRowRightPadding;

  /// 横スクロール時間ヘッダーのセル左パディング（デフォルト: 2.0）
  final double horizontalTimeHeaderCellLeftPadding;

  /// 概要アイテムの水平パディング（デフォルト: 8.0）
  final double overviewItemHorizontalPadding;

  /// 概要アイテムのテキスト間隔（デフォルト: 2.0）
  final double overviewItemTextSpacing;

  /// 月表示の日付ヘッダーの高さ（デフォルト: 20.0）
  final double monthlyDateHeight;

  /// 月表示の水平パディング（デフォルト: 6）
  final double monthlyHorizontalPadding;

  /// 月表示の水平スペーシング（デフォルト: 6）
  final double monthlyHorizontalSpacing;

  /// 月表示の垂直パディング（デフォルト: 6）
  final double monthlyVerticalPadding;

  /// 月表示の垂直スペーシング（デフォルト: 8）
  final double monthlyVerticalSpacing;

  /// 週行の日付ヘッダーの高さ（デフォルト: 24）
  final double weekDateHeight;

  /// 週行の水平スペーシング（デフォルト: 6）
  final double weekHorizontalSpacing;

  /// 週行の水平パディング（デフォルト: 6）
  final double weekHorizontalPadding;

  // -------------------- 形状設定 --------------------

  /// 詳細アイテムの角丸半径（デフォルト: 6.0）
  final double detailItemBorderRadius;

  /// 詳細アイテムの水平パディング（デフォルト: 4.0）
  final double detailItemHorizontalPadding;

  /// 概要アイテムの角丸半径（デフォルト: 2.0）
  final double overviewItemBorderRadius;

  /// 月表示アイテムの角丸半径（デフォルト: 1.0）
  final double monthlyItemBorderRadius;

  const BSchedulerStyle({
    // レイアウト定数
    this.borderWidth = 1.0,
    this.currentTimeBorderWidth = 2.0,
    this.verticalScrollTimeColumnWidth = 40.0,
    this.verticalScrollDateColumnWidth = 24.0,
    this.horizontalScrollTimeRowHeight = 24.0,
    // テキストスタイル
    this.timeTextStyle = const TextStyle(fontSize: 11),
    this.dateTextStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.weekDateTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    this.weekdayTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    this.horizontalTimeHeaderTextStyle = const TextStyle(fontSize: 10),
    this.detailItemTextStyle = const TextStyle(color: Colors.black, fontSize: 12),
    this.overviewItemTextStyle = const TextStyle(fontSize: 12),
    this.monthlyItemTextStyle = const TextStyle(fontSize: 12),
    this.horizontalItemTextStyle = const TextStyle(color: Colors.black, fontSize: 10),
    this.debugTextStyle = const TextStyle(
      color: Color.fromARGB(180, 255, 0, 0),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    // 色設定（nullの場合はTheme.of(context).colorSchemeから取得）
    this.outlineColor,
    this.primaryColor,
    this.onPrimaryColor,
    this.primaryContainerColor,
    this.onSurfaceColor,
    this.surfaceColor,
    this.currentTimeBorderColor,
    // Alpha値設定
    this.baseOutlineAlpha = 84,
    this.lightOutlineAlpha = 42,
    this.weekDateHeaderAlpha = 64,
    this.itemAlpha = 200,
    // パディング・スペーシング
    this.weekdayRowPadding = const EdgeInsets.symmetric(horizontal: 4.0),
    this.timeRowRightPadding = 4.0,
    this.horizontalTimeHeaderCellLeftPadding = 2.0,
    this.overviewItemHorizontalPadding = 8.0,
    this.overviewItemTextSpacing = 2.0,
    this.monthlyDateHeight = 20.0,
    this.monthlyHorizontalPadding = 6.0,
    this.monthlyHorizontalSpacing = 6.0,
    this.monthlyVerticalPadding = 4.0,
    this.monthlyVerticalSpacing = 8.0,
    this.weekDateHeight = 24.0,
    this.weekHorizontalSpacing = 6.0,
    this.weekHorizontalPadding = 6.0,
    // 形状設定
    this.detailItemBorderRadius = 6.0,
    this.detailItemHorizontalPadding = 4.0,
    this.overviewItemBorderRadius = 2.0,
    this.monthlyItemBorderRadius = 1.0,
  });

  /// テーマから色を取得するヘルパーメソッド
  Color getOutlineColor(BuildContext context) =>
      outlineColor ?? Theme.of(context).colorScheme.outline;

  Color getPrimaryColor(BuildContext context) =>
      primaryColor ?? Theme.of(context).colorScheme.primary;

  Color getOnPrimaryColor(BuildContext context) =>
      onPrimaryColor ?? Theme.of(context).colorScheme.onPrimary;

  Color getPrimaryContainerColor(BuildContext context) =>
      primaryContainerColor ?? Theme.of(context).colorScheme.primaryContainer;

  Color getOnSurfaceColor(BuildContext context) =>
      onSurfaceColor ?? Theme.of(context).colorScheme.onSurface;

  Color getSurfaceColor(BuildContext context) =>
      surfaceColor ?? Theme.of(context).colorScheme.surface;

  Color getCurrentTimeBorderColor(BuildContext context) =>
      currentTimeBorderColor ?? Theme.of(context).colorScheme.tertiary;

  /// 透明度付きの色を取得するヘルパーメソッド
  Color getOutlineColorWithAlpha(BuildContext context, int alpha) =>
      getOutlineColor(context).withAlpha(alpha);

  Color getPrimaryColorWithAlpha(BuildContext context, int alpha) =>
      getPrimaryColor(context).withAlpha(alpha);

  Color getOnPrimaryColorWithAlpha(BuildContext context, int alpha) =>
      getOnPrimaryColor(context).withAlpha(alpha);

  Color getPrimaryContainerColorWithAlpha(BuildContext context, int alpha) =>
      getPrimaryContainerColor(context).withAlpha(alpha);

  Color getOnSurfaceColorWithAlpha(BuildContext context, int alpha) =>
      getOnSurfaceColor(context).withAlpha(alpha);

  Color getSurfaceColorWithAlpha(BuildContext context, int alpha) =>
      getSurfaceColor(context).withAlpha(alpha);

  /// copyWithメソッド - 一部のプロパティを変更した新しいインスタンスを作成
  BSchedulerStyle copyWith({
    double? borderWidth,
    double? currentTimeBorderWidth,
    double? verticalScrollTimeColumnWidth,
    double? verticalScrollDateColumnWidth,
    double? horizontalScrollTimeRowHeight,
    TextStyle? timeTextStyle,
    TextStyle? dateTextStyle,
    TextStyle? weekDateTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? horizontalTimeHeaderTextStyle,
    TextStyle? detailItemTextStyle,
    TextStyle? overviewItemTextStyle,
    TextStyle? monthlyItemTextStyle,
    TextStyle? horizontalItemTextStyle,
    TextStyle? debugTextStyle,
    Color? outlineColor,
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? primaryContainerColor,
    Color? onSurfaceColor,
    Color? surfaceColor,
    Color? currentTimeBorderColor,
    int? baseOutlineAlpha,
    int? lightOutlineAlpha,
    int? weekDateHeaderAlpha,
    int? itemAlpha,
    EdgeInsets? weekdayRowPadding,
    double? timeRowRightPadding,
    double? horizontalTimeHeaderCellLeftPadding,
    double? overviewItemHorizontalPadding,
    double? overviewItemTextSpacing,
    double? monthlyDateHeight,
    double? monthlyHorizontalPadding,
    double? monthlyHorizontalSpacing,
    double? monthlyVerticalPadding,
    double? monthlyVerticalSpacing,
    double? weekDateHeight,
    double? weekHorizontalSpacing,
    double? weekHorizontalPadding,
    double? detailItemBorderRadius,
    double? detailItemHorizontalPadding,
    double? overviewItemBorderRadius,
    double? monthlyItemBorderRadius,
  }) {
    return BSchedulerStyle(
      borderWidth: borderWidth ?? this.borderWidth,
      currentTimeBorderWidth: currentTimeBorderWidth ?? this.currentTimeBorderWidth,
      verticalScrollTimeColumnWidth:
          verticalScrollTimeColumnWidth ?? this.verticalScrollTimeColumnWidth,
      verticalScrollDateColumnWidth:
          verticalScrollDateColumnWidth ?? this.verticalScrollDateColumnWidth,
      horizontalScrollTimeRowHeight:
          horizontalScrollTimeRowHeight ?? this.horizontalScrollTimeRowHeight,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      dateTextStyle: dateTextStyle ?? this.dateTextStyle,
      weekDateTextStyle: weekDateTextStyle ?? this.weekDateTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      horizontalTimeHeaderTextStyle:
          horizontalTimeHeaderTextStyle ?? this.horizontalTimeHeaderTextStyle,
      detailItemTextStyle: detailItemTextStyle ?? this.detailItemTextStyle,
      overviewItemTextStyle: overviewItemTextStyle ?? this.overviewItemTextStyle,
      monthlyItemTextStyle: monthlyItemTextStyle ?? this.monthlyItemTextStyle,
      horizontalItemTextStyle: horizontalItemTextStyle ?? this.horizontalItemTextStyle,
      debugTextStyle: debugTextStyle ?? this.debugTextStyle,
      outlineColor: outlineColor ?? this.outlineColor,
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      primaryContainerColor: primaryContainerColor ?? this.primaryContainerColor,
      onSurfaceColor: onSurfaceColor ?? this.onSurfaceColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      currentTimeBorderColor: currentTimeBorderColor ?? this.currentTimeBorderColor,
      baseOutlineAlpha: baseOutlineAlpha ?? this.baseOutlineAlpha,
      lightOutlineAlpha: lightOutlineAlpha ?? this.lightOutlineAlpha,
      weekDateHeaderAlpha: weekDateHeaderAlpha ?? this.weekDateHeaderAlpha,
      itemAlpha: itemAlpha ?? this.itemAlpha,
      weekdayRowPadding: weekdayRowPadding ?? this.weekdayRowPadding,
      timeRowRightPadding: timeRowRightPadding ?? this.timeRowRightPadding,
      horizontalTimeHeaderCellLeftPadding:
          horizontalTimeHeaderCellLeftPadding ?? this.horizontalTimeHeaderCellLeftPadding,
      overviewItemHorizontalPadding:
          overviewItemHorizontalPadding ?? this.overviewItemHorizontalPadding,
      overviewItemTextSpacing: overviewItemTextSpacing ?? this.overviewItemTextSpacing,
      monthlyDateHeight: monthlyDateHeight ?? this.monthlyDateHeight,
      monthlyHorizontalPadding: monthlyHorizontalPadding ?? this.monthlyHorizontalPadding,
      monthlyHorizontalSpacing: monthlyHorizontalSpacing ?? this.monthlyHorizontalSpacing,
      monthlyVerticalPadding: monthlyVerticalPadding ?? this.monthlyVerticalPadding,
      monthlyVerticalSpacing: monthlyVerticalSpacing ?? this.monthlyVerticalSpacing,
      weekDateHeight: weekDateHeight ?? this.weekDateHeight,
      weekHorizontalSpacing: weekHorizontalSpacing ?? this.weekHorizontalSpacing,
      weekHorizontalPadding: weekHorizontalPadding ?? this.weekHorizontalPadding,
      detailItemBorderRadius: detailItemBorderRadius ?? this.detailItemBorderRadius,
      detailItemHorizontalPadding: detailItemHorizontalPadding ?? this.detailItemHorizontalPadding,
      overviewItemBorderRadius: overviewItemBorderRadius ?? this.overviewItemBorderRadius,
      monthlyItemBorderRadius: monthlyItemBorderRadius ?? this.monthlyItemBorderRadius,
    );
  }
}
