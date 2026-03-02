/// BSchedulerの動作・タイミング設定を管理するクラス
///
/// アニメーション時間、スクロールタイマー、ジェスチャー閾値など、
/// 視覚的なスタイルとは異なる動作パラメータを一元管理します。
class BSchedulerBehaviorConfig {
  // -------------------- アニメーション設定 --------------------

  /// 基本アニメーション時間（ミリ秒、デフォルト: 300）
  final int baseAnimationDuration;

  /// 追加アニメーション時間の比率（デフォルト: 40）
  final int extraAnimationDurationPerRatio;

  // -------------------- スクロール設定 --------------------

  /// スクロール終了判定のタイマー時間（ミリ秒、デフォルト: 200）
  final int scrollEndTimerDuration;

  // -------------------- ジェスチャー設定 --------------------

  /// スケールアクションの閾値ピクセル（デフォルト: 200.0）
  final double scaleActionThreshold;

  const BSchedulerBehaviorConfig({
    this.baseAnimationDuration = 300,
    this.extraAnimationDurationPerRatio = 40,
    this.scrollEndTimerDuration = 200,
    this.scaleActionThreshold = 200.0,
  });

  /// copyWithメソッド - 一部のプロパティを変更した新しいインスタンスを作成
  BSchedulerBehaviorConfig copyWith({
    int? baseAnimationDuration,
    int? extraAnimationDurationPerRatio,
    int? scrollEndTimerDuration,
    double? scaleActionThreshold,
  }) {
    return BSchedulerBehaviorConfig(
      baseAnimationDuration: baseAnimationDuration ?? this.baseAnimationDuration,
      extraAnimationDurationPerRatio:
          extraAnimationDurationPerRatio ?? this.extraAnimationDurationPerRatio,
      scrollEndTimerDuration: scrollEndTimerDuration ?? this.scrollEndTimerDuration,
      scaleActionThreshold: scaleActionThreshold ?? this.scaleActionThreshold,
    );
  }
}
