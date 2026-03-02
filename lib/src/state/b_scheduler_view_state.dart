import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:b_scheduler/src/model/b_scheduler_behavior_config.dart';
import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_mode.dart';
import 'package:b_scheduler/src/utils/date_time_util.dart';

class BSchedulerViewState {
  // -------------------- 依存関係 --------------------

  final VoidCallback onStateChanged;
  final VoidCallback onLoadItems;
  final Future<List<BSchedulerItem>> Function(DateTime start, DateTime end) onRangeChanged;

  // アニメーション開始コールバック（Controllerが設定）
  late final void Function(double beginHeight, double endHeight, VoidCallback onComplete)
  onStartAnimation;

  BSchedulerViewState({
    required this.onStateChanged,
    required this.onLoadItems,
    required this.onRangeChanged,
    required this.availableModes,
    required BSchedulerMode initialMode,
    required this.baseDate,
    required this.behaviorConfig,
    required this.onStartAnimation,
  }) : currentModeNotifier = ValueNotifier(initialMode) {
    _initialize();
  }

  // 設定値
  final List<BSchedulerMode> availableModes;
  final DateTime baseDate;
  final BSchedulerBehaviorConfig behaviorConfig;

  // 内部状態
  final ValueNotifier<BSchedulerMode> currentModeNotifier;

  // 計算プロパティ
  int get baseIndex => 36400 + (baseDate.weekday - 1) % 7;
  DateTime get startDate => baseDate.subtract(Duration(days: baseIndex));

  // -------------------- 表示モード --------------------

  List<BSchedulerMode> get modes => availableModes;
  BSchedulerMode get currentMode => currentModeNotifier.value;
  BSchedulerMode get nextMode {
    if (currentMode == availableModes.last) return currentMode;
    return availableModes[availableModes.indexOf(currentMode) + 1];
  }

  BSchedulerMode get prevMode {
    if (currentMode == availableModes.first) return currentMode;
    return availableModes[availableModes.indexOf(currentMode) - 1];
  }

  late BSchedulerMode lastMode = currentMode;

  // 表示モード別の期待される高さ
  double get currentExpectedHeight => viewportHeight * currentMode.unitHeightFactor;
  double get nextExpectedHeight => viewportHeight * nextMode.unitHeightFactor;
  double get prevExpectedHeight => viewportHeight * prevMode.unitHeightFactor;
  double get lastExpectedHeight => viewportHeight * lastMode.unitHeightFactor;

  // 表示モード判定フラグ
  bool get showDayDetailRows => // 日単位・24時間表示
      currentMode.direction == Axis.vertical &&
      currentMode.unit == BSchedulerItemDividerUnit.day &&
      currentMode.unitsInScreen <= 3;
  bool get showDayOverviewInWeek => // 日単位・簡略表示
      currentMode.direction == Axis.vertical &&
      currentMode.unit == BSchedulerItemDividerUnit.day &&
      3 < currentMode.unitsInScreen;
  bool get showWeekRows => // 週単位表示
      currentMode.direction == Axis.vertical && currentMode.unit == BSchedulerItemDividerUnit.week;

  // アニメーション状態判定
  bool get transitioningToDayDetailRows => isAnimating && showDayDetailRows;
  bool get transitioningFromDayDetailRows =>
      isAnimating &&
      lastMode.direction == Axis.vertical &&
      lastMode.unit == BSchedulerItemDividerUnit.day &&
      lastMode.unitsInScreen <= 3;
  bool get transitioningToAndFromDetailRows =>
      transitioningToDayDetailRows && transitioningFromDayDetailRows;
  bool get transitioningToDayOverview => isAnimating && showDayOverviewInWeek;
  bool get transitioningFromDayOverview =>
      isAnimating &&
      lastMode.direction == Axis.vertical &&
      lastMode.unit == BSchedulerItemDividerUnit.day &&
      3 < lastMode.unitsInScreen;
  bool get transitioningToAndFromDayOverview =>
      transitioningToDayOverview && transitioningFromDayOverview;
  bool get transitioningToWeekRows => isAnimating && showWeekRows;
  bool get transitioningFromWeekRows =>
      isAnimating &&
      lastMode.direction == Axis.vertical &&
      lastMode.unit == BSchedulerItemDividerUnit.week;
  bool get transitioningToAndFromWeekRows => transitioningToWeekRows && transitioningFromWeekRows;

  // 要素透過度
  double get _dayDetailOpacity => transitioningToAndFromDetailRows
      ? 1
      : transitioningToDayDetailRows
      ? (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : transitioningFromDayDetailRows
      ? 1 - (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : showDayDetailRows
      ? 1
      : 0;
  double get dayDetailOpacity => _dayDetailOpacity.clamp(0, 1);
  double get _dayOverviewOpacity => transitioningToAndFromDayOverview
      ? 1
      : transitioningToDayOverview
      ? (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : transitioningFromDayOverview
      ? 1 - (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : showDayOverviewInWeek
      ? 1
      : 0;
  double get dayOverviewOpacity => _dayOverviewOpacity.clamp(0, 1);
  double get _weekRowOpacity => transitioningToAndFromWeekRows
      ? 1
      : transitioningToWeekRows
      ? (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : transitioningFromWeekRows
      ? 1 - (animatedHeight - lastExpectedHeight) / (currentExpectedHeight - lastExpectedHeight)
      : showWeekRows
      ? 1
      : 0;
  double get weekRowOpacity => _weekRowOpacity.clamp(0, 1);

  // -------------------- ビューポートサイズ --------------------

  Size? viewportSize;
  bool get viewportReady => viewportSize != null;
  double get viewportWidth => viewportSize?.width ?? 0;
  double get viewportHeight => viewportSize?.height ?? 0;

  // レイアウト計算用の定数（BSchedulerStyleから取得するため、使用側で参照）
  // これらはviewStateではなく、各コンポーネントがstyleから直接取得する
  double get horizontalScrollContentWidth => viewportWidth * 2.5;

  // レイアウト計算（styleが必要な計算は各コンポーネント側で実施）

  // -------------------- 日付・時刻 --------------------

  DateTime get focusedDate => itemsScrollController.hasClients
      ? startDate.add(Duration(days: ((screenCenterOffset / animatedHeight)).floor()))
      : baseDate;
  late DateTime topDate = baseDate;
  late DateTime bottomDate = baseDate;
  DateTime? targetDate; // アニメーション中に特定の日付にスクロールする場合のターゲット日付

  // 現在時刻の垂直オフセット（各コンポーネントでstyleを使って計算）

  // -------------------- スクロール --------------------

  // 垂直スクロールコントローラー
  final scrollControllerGroup = LinkedScrollControllerGroup();
  late final itemsScrollController = scrollControllerGroup.addAndGet();
  late final dateColumnScrollController = scrollControllerGroup.addAndGet();
  late final timeColumnScrollController = scrollControllerGroup.addAndGet();
  late final weekColumnScrollController = scrollControllerGroup.addAndGet();
  late final unitDividerScrollController = scrollControllerGroup.addAndGet();

  // 水平スクロールコントローラー
  final horizontalScrollControllerGroup = LinkedScrollControllerGroup();
  late final horizontalScrollController = horizontalScrollControllerGroup.addAndGet();
  late final horizontalBackgroundScrollController = horizontalScrollControllerGroup.addAndGet();
  late final horizontalTimeScrollController = horizontalScrollControllerGroup.addAndGet();

  // スクロール状態
  Timer? scrollEndTimer;
  bool isScrolling = false;
  bool scrollOffsetInitialized = false;
  final scrollOffsetNotifier = ValueNotifier<double>(0.0);

  // スクロール位置計算
  double get scrollHeight => viewportReady ? baseIndex * 2 * currentHeight : 0;
  double get scrollCenter => scrollHeight / 2;
  double get screenCenterOffset => scrollOffsetNotifier.value + viewportHeight / 2;
  double get scrollOffsetFromCenter => screenCenterOffset - scrollCenter;

  // -------------------- アイテム表示 --------------------

  Map<BSchedulerItem, SlotInfo>? items;
  double itemsOverlayTop = 0;
  double itemsOverlayBottom = 0;
  bool get shouldShowOverlay =>
      itemsOverlayTop != 0 && itemsOverlayBottom != 0 && itemsOverlayTop < itemsOverlayBottom;
  Timer? refreshTimer;

  // -------------------- アニメーション --------------------

  late Animation<double> heightAnimation;
  double currentHeight = 0;
  double? _animationStartOffset;
  double? _animationStartHeight;
  bool _isAnimating = false;

  /// アニメーション実行中かどうか (外部公開用)
  bool get isAnimating => _isAnimating;

  int get animationDuration =>
      behaviorConfig.baseAnimationDuration +
      (behaviorConfig.extraAnimationDurationPerRatio *
              sqrt(
                max(
                  currentMode.unitsInScreen / lastMode.unitsInScreen,
                  lastMode.unitsInScreen / currentMode.unitsInScreen,
                ),
              ))
          .toInt();
  double get animatedHeight => isAnimating ? heightAnimation.value : currentHeight;

  // -------------------- メソッド --------------------

  // ビューポートサイズ更新
  void updateViewportSize(Size newSize) {
    if (viewportSize != newSize) {
      viewportSize = newSize;
      currentHeight = viewportHeight / currentMode.unitsInScreen;
      onStateChanged();
    }
  }

  // スクロール位置初期化
  void initializeScrollOffset() {
    if (itemsScrollController.hasClients && !scrollOffsetInitialized) {
      final jumpTo = scrollCenter - viewportHeight / 2 + currentHeight / 2;
      itemsScrollController.jumpTo(jumpTo);
      scrollOffsetInitialized = true;
      onStateChanged();
    }
  }

  // リソース解放
  void dispose() {
    scrollEndTimer?.cancel();
    refreshTimer?.cancel();
    currentModeNotifier.removeListener(_onModeChanged);
    itemsScrollController.removeListener(_onScroll);
    // animationControllerは外部で管理されるため、ここではdisposeしない
    scrollOffsetNotifier.dispose();
    itemsScrollController.dispose();
    dateColumnScrollController.dispose();
    timeColumnScrollController.dispose();
    weekColumnScrollController.dispose();
    unitDividerScrollController.dispose();
    horizontalScrollController.dispose();
    horizontalBackgroundScrollController.dispose();
    horizontalTimeScrollController.dispose();
  }

  // 初期化
  void _initialize() {
    // リスナー登録
    itemsScrollController.addListener(_onScroll);
    currentModeNotifier.addListener(_onModeChanged);

    heightAnimation = AlwaysStoppedAnimation(currentHeight);
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) => onStateChanged());
  }

  // アニメーション中のスクロール同期（Controllerから呼ばれる）
  void updateScrollDuringAnimation() {
    if (!_isAnimating ||
        _animationStartOffset == null ||
        _animationStartHeight == null ||
        targetDate != null) {
      return;
    }

    final currentAnimatedHeight = heightAnimation.value;
    final ratio = currentAnimatedHeight / _animationStartHeight!;
    final endOffset = (_animationStartOffset! + viewportHeight / 2) * ratio - viewportHeight / 2;
    itemsScrollController.jumpTo(endOffset);
  }

  // アニメーション完了時コールバック（Controllerから呼ばれる）
  void onAnimationComplete() {
    _isAnimating = false;
    lastMode = currentModeNotifier.value;
    targetDate = null; // targetDateをクリア
    onStateChanged();
  }

  // スクロール時コールバック
  void _onScroll() {
    scrollOffsetNotifier.value = itemsScrollController.offset;

    if (!isScrolling) isScrolling = true;

    scrollEndTimer?.cancel();
    scrollEndTimer = Timer(Duration(milliseconds: behaviorConfig.scrollEndTimerDuration), () {
      isScrolling = false;
      _onScrollEnd();
    });
  }

  // スクロール終了時コールバック
  void _onScrollEnd() {
    // 画面外にロードするアイテムの数
    final preloadItems = (currentMode.unitsInScreen / 7).ceil() * 7;
    // 表示中の日付を基準にロードするアイテムの日付範囲とその表示領域を計算
    topDate = DateTimeUtil.lastMonday(focusedDate).subtract(Duration(days: preloadItems));
    bottomDate = DateTimeUtil.nextSunday(focusedDate).add(Duration(days: preloadItems));
    itemsOverlayTop = currentHeight * (topDate.difference(baseDate).inDays + baseIndex);
    itemsOverlayBottom = currentHeight * (bottomDate.difference(baseDate).inDays + baseIndex);
    // アイテムロード
    onStateChanged();
    onLoadItems();
  }

  // 表示モード変更時コールバック
  void _onModeChanged() {
    if (!viewportReady) return;

    // アニメーション後のモードと行高さ
    final targetMode = currentModeNotifier.value;
    final targetHeight = viewportHeight / targetMode.unitsInScreen;

    // 初回起動時はアニメーションせずに高さを設定して終了
    if (currentHeight == 0) {
      currentHeight = targetHeight;
      onStateChanged();
      return;
    }

    // アニメーション開始前の高さ
    final beginHeight = currentHeight;

    // アニメーション中に表示するアイテムを軽量化のために絞り込む範囲
    late final DateTime filterStart;
    late final DateTime filterEnd;
    // 絞り込み前情報の一時保存
    final itemsTemp = Map<BSchedulerItem, SlotInfo>.from(items ?? {});

    // フィルター範囲計算
    if (targetDate != null) {
      // targetDateが設定されている場合、その日付と前後のみ保持
      filterStart = targetDate!.subtract(const Duration(days: 1));
      filterEnd = targetDate!.add(const Duration(days: 2));
    } else {
      if (targetMode.unit == BSchedulerItemDividerUnit.week) {
        // 月表示に切り替える場合、基準日を含む週の前後を保持
        filterStart = DateTimeUtil.lastMonday(focusedDate).subtract(const Duration(days: 21));
        filterEnd = DateTimeUtil.nextSunday(focusedDate).add(const Duration(days: 22));
      } else {
        // その他の表示モードの場合、アニメーション後に画面に収まる範囲のみ保持
        filterStart = focusedDate.subtract(Duration(days: (targetMode.unitsInScreen / 2).floor()));
        filterEnd = focusedDate.add(Duration(days: (targetMode.unitsInScreen / 2).floor() + 1));
      }
    }
    // フィルター実行
    final filtered = <BSchedulerItem, SlotInfo>{};
    final entries = items!.entries.toList();
    final length = entries.length;
    int i = 0;
    while (i < length) {
      final item = entries[i];
      if (item.key.endTime.isAfter(filterStart) && item.key.startTime.isBefore(filterEnd)) {
        filtered[item.key] = item.value;
      }
      i++;
    }
    items = filtered;

    // アニメーション開始とControllerへの通知
    _animationStartOffset = itemsScrollController.hasClients ? itemsScrollController.offset : 0;
    _animationStartHeight = beginHeight;
    currentHeight = targetHeight;
    _isAnimating = true;
    onStateChanged();
    onStartAnimation(beginHeight, targetHeight, () => items = itemsTemp);
  }
}
