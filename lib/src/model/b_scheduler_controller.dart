import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_behavior_config.dart';
import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_mode.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/date_time_util.dart';

class BSchedulerViewController {
  // 設定（不変）
  final DateTime baseDate;
  final List<BSchedulerMode> availableModes;
  final BSchedulerMode initialMode;
  final BSchedulerStyle style;
  final BSchedulerBehaviorConfig behaviorConfig;
  final Future<List<BSchedulerItem>> Function(DateTime start, DateTime end) onRangeChanged;

  // -------------------- 内部状態 --------------------

  AnimationController? animationController;

  // ViewStateへの参照（内部実装の詳細 - 外部から直接アクセスしない）
  BSchedulerViewState? _state;

  // 内部アクセス用getter
  BSchedulerViewState? get state => _state;

  BSchedulerViewController({
    DateTime? baseDate,
    List<BSchedulerMode>? availableModes,
    BSchedulerMode? initialMode,
    BSchedulerStyle? style,
    BSchedulerBehaviorConfig? behaviorConfig,
    required this.onRangeChanged,
  }) : baseDate = baseDate ?? DateTime.now().to12am(),
       availableModes =
           availableModes ?? const [BSchedulerMode.day, BSchedulerMode.week, BSchedulerMode.month],
       initialMode = initialMode ?? availableModes?.first ?? BSchedulerMode.day,
       style = style ?? const BSchedulerStyle(),
       behaviorConfig = behaviorConfig ?? const BSchedulerBehaviorConfig();

  /// controllerを初期化（TickerProviderが必要なため、View側から呼ばれる）
  void initialize(TickerProvider tickerProvider, VoidCallback onStateChanged) {
    // AnimationControllerを生成
    animationController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(milliseconds: behaviorConfig.baseAnimationDuration),
    );

    // ViewStateを生成
    _state = BSchedulerViewState(
      onStateChanged: onStateChanged,
      onLoadItems: loadItems,
      onRangeChanged: onRangeChanged,
      availableModes: availableModes,
      initialMode: initialMode,
      baseDate: baseDate,
      behaviorConfig: behaviorConfig,
      onStartAnimation: _startAnimation,
    );
  }

  // -------------------- 公開API --------------------
  // 外部コードは以下のメソッド/getterのみを使用してください

  /// アニメーション実行中かどうか
  bool get isAnimating => state?.isAnimating ?? false;

  /// 現在の表示モード
  BSchedulerMode get currentMode => state?.currentMode ?? initialMode;

  /// 次の表示モード（拡大時）
  BSchedulerMode get nextMode => state?.nextMode ?? initialMode;

  /// 前の表示モード（縮小時）
  BSchedulerMode get prevMode => state?.prevMode ?? initialMode;

  /// 現在モードのValueNotifier（UI監視用）
  ValueNotifier<BSchedulerMode>? get currentModeNotifier => state?.currentModeNotifier;

  /// 今日の日付にスクロール
  void scrollToToday() {
    final viewState = state;
    if (viewState == null || isAnimating) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    final today = DateTime.now().to12am();
    _animateTo(today);
  }

  /// 次の画面へスクロール
  void scrollToNextScreen() {
    final viewState = state;
    if (viewState == null || isAnimating) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    final mode = viewState.currentMode;
    final unit = mode.unit == BSchedulerItemDividerUnit.day ? 1 : 7;
    final shiftUnits = ((viewState.currentMode.unitsInScreen / unit).ceil() - 1) * unit;
    final targetDate = viewState.focusedDate.add(Duration(days: shiftUnits));
    _animateTo(targetDate);
  }

  /// 前の画面へスクロール
  void scrollToPrevScreen() {
    final viewState = state;
    if (viewState == null || isAnimating) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    final mode = viewState.currentMode;
    final unit = mode.unit == BSchedulerItemDividerUnit.day ? 1 : 7;
    final shiftUnits = ((mode.unitsInScreen / unit).ceil() - 1) * unit;
    final targetDate = viewState.focusedDate.subtract(Duration(days: shiftUnits));
    _animateTo(targetDate);
  }

  /// 指定した日付にスクロールしながら、指定したモードに変更する
  void scrollAndFocusTo(DateTime date, BSchedulerMode targetMode) {
    final viewState = state;
    if (viewState == null || isAnimating) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    // targetDateを設定してからモード変更すると、アニメーション中にスクロールも実行される
    viewState.targetDate = date;
    changeMode(targetMode);
  }

  /// 表示モードを変更
  void changeMode(BSchedulerMode mode) {
    if (isAnimating) return; // アニメーション中は無視
    if (availableModes.contains(mode)) {
      state?.currentModeNotifier.value = mode;
    }
  }

  /// 表示を拡大（より詳細な表示へ）
  void upscale() {
    if (isAnimating) return; // アニメーション中は無視
    if (currentMode == availableModes.first) return;

    final currentIndex = availableModes.indexOf(currentMode);
    changeMode(availableModes[currentIndex - 1]);
  }

  /// 表示を縮小（より広範囲の表示へ）
  void downscale() {
    if (isAnimating) return; // アニメーション中は無視
    if (currentMode == availableModes.last) return;
    final currentIndex = availableModes.indexOf(currentMode);
    changeMode(availableModes[currentIndex + 1]);
  }

  /// アイテムを読み込む
  void loadItems() {
    final viewState = state;
    if (viewState == null) return;
    onRangeChanged(viewState.topDate, viewState.bottomDate).then((items) {
      final sortedItems = List<BSchedulerItem>.from(items)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      viewState.items = sortedItems.toSlotInfo();
      viewState.onStateChanged();
    });
  }

  // -------------------- 内部実装 --------------------

  /// アニメーションを開始（ViewStateから呼ばれる）
  void _startAnimation(double beginHeight, double endHeight, VoidCallback onComplete) {
    final viewState = state;
    if (viewState == null || animationController == null) return;

    // アニメーション設定
    final animation = CurvedAnimation(parent: animationController!, curve: Curves.fastOutSlowIn);
    viewState.heightAnimation = Tween<double>(
      begin: beginHeight,
      end: endHeight,
    ).animate(animation);

    // アニメーション中のスクロール同期リスナー
    animationController!.addListener(() {
      viewState.updateScrollDuringAnimation();
    });

    // アニメーション期間を設定
    animationController!.duration = Duration(milliseconds: viewState.animationDuration);

    // targetDateが設定されている場合、スクロールアニメーションも実行
    if (viewState.targetDate != null) {
      _animateToTargetDate(viewState.targetDate!, viewState.currentMode);
    }

    // アニメーション実行
    animationController!.forward(from: 0).whenCompleteOrCancel(() {
      viewState.onAnimationComplete();
      onComplete();
    });
  }

  /// 指定した日付へアニメーションでスクロール（内部用）
  void _animateTo(DateTime targetDate, {BSchedulerMode? targetMode}) {
    final viewState = state;
    if (viewState == null || isAnimating) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    final mode = targetMode ?? viewState.currentMode;
    final targetIndex = targetDate.difference(viewState.startDate).inDays;
    final targetOffset =
        targetIndex * viewState.viewportHeight / mode.unitsInScreen -
        (1 - 1 / mode.unitsInScreen) * viewState.viewportHeight / 2;
    final maxOffset = viewState.scrollHeight - viewState.viewportHeight;
    final clampedMax = maxOffset > 0 ? maxOffset : 0.0;
    final clampedTarget = targetOffset.clamp(0.0, clampedMax).toDouble();
    final duration = animationController?.duration ?? const Duration(milliseconds: 150);
    viewState.itemsScrollController.animateTo(
      clampedTarget,
      duration: duration,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// targetDate用のスクロールアニメーション（アニメーション中でも実行可能）
  void _animateToTargetDate(DateTime targetDate, BSchedulerMode targetMode) {
    final viewState = state;
    if (viewState == null) return;
    if (!viewState.viewportReady || !viewState.itemsScrollController.hasClients) return;

    final targetIndex = targetDate.difference(viewState.startDate).inDays;
    final targetOffset =
        targetIndex * viewState.viewportHeight / targetMode.unitsInScreen -
        (1 - 1 / targetMode.unitsInScreen) * viewState.viewportHeight / 2;
    final maxOffset = viewState.scrollHeight - viewState.viewportHeight;
    final clampedMax = maxOffset > 0 ? maxOffset : 0.0;
    final clampedTarget = targetOffset.clamp(0.0, clampedMax).toDouble();
    final duration = animationController?.duration ?? const Duration(milliseconds: 150);
    viewState.itemsScrollController.animateTo(
      clampedTarget,
      duration: duration,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// リソースの解放
  void dispose() {
    animationController?.dispose();
    _state?.dispose();
    animationController = null;
    _state = null;
  }
}
