import 'package:flutter/material.dart';

import 'package:b_scheduler/src/components/gesture/gesture.dart';
import 'package:b_scheduler/src/components/grid/grid.dart';
import 'package:b_scheduler/src/components/header/header.dart';
import 'package:b_scheduler/src/components/items/items.dart';
import 'package:b_scheduler/src/components/overlay/overlay.dart';
import 'package:b_scheduler/src/model/b_scheduler_controller.dart';
import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';

class BSchedulerView extends StatefulWidget {
  final BSchedulerViewController controller;
  final bool debugView;
  final void Function(BSchedulerItem) onTapItem;
  final BSchedulerVerticalDetailItemBuilder? detailItemBuilder;

  const BSchedulerView({
    super.key,
    required this.controller,
    this.debugView = false,
    required this.onTapItem,
    this.detailItemBuilder,
  });

  @override
  State<BSchedulerView> createState() => _BSchedulerViewState();
}

class _BSchedulerViewState extends State<BSchedulerView> with SingleTickerProviderStateMixin {
  BSchedulerViewController get controller => widget.controller;
  BSchedulerViewState get viewState => controller.state!;

  @override
  void initState() {
    super.initState();

    widget.controller.initialize(this, () => setState(() {}));
    widget.controller.loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // タイムライン
          LayoutBuilder(
            builder: (context, constraints) {
              // 描画領域のサイズ取得
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final newSize = Size(constraints.maxWidth, constraints.maxHeight);
                viewState.updateViewportSize(newSize);
              });

              if (!viewState.viewportReady) return Container(); // サイズ取得前

              return AnimatedBuilder(
                animation: controller.animationController!,
                builder: (context, child) {
                  final style = controller.style;

                  // BSchedulerTimeTable生成後にスクロール位置を更新
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    viewState.initializeScrollOffset();
                  });

                  return Stack(
                    children: [
                      // 日表示の24時間罫線
                      BSchedulerTimeRows(
                        visible: viewState.dayDetailOpacity + viewState.dayOverviewOpacity > 0.5,
                        opacity: viewState.dayDetailOpacity + viewState.dayOverviewOpacity,
                        viewState: viewState,
                        style: style,
                      ),

                      // スケジュールアイテム表示
                      if (viewState.items != null)
                        SingleChildScrollView(
                          controller: viewState.itemsScrollController,
                          child: SizedBox(
                            height: viewState.baseIndex * 2 * viewState.animatedHeight,
                            width: viewState.viewportWidth,
                            child: Stack(
                              children: [
                                BSchedulerVerticalTimelineDetailItems(
                                  visible: viewState.dayDetailOpacity > 0.5,
                                  opacity: viewState.dayDetailOpacity,
                                  viewState: viewState,
                                  style: style,
                                  onTapItem: widget.onTapItem,
                                  detailItemBuilder: widget.detailItemBuilder,
                                ),
                                BSchedulerVerticalTimelineOverviewItems(
                                  visible: viewState.dayOverviewOpacity > 0.5,
                                  opacity: viewState.dayOverviewOpacity,
                                  viewState: viewState,
                                  style: style,
                                ),
                                BSchedulerTimelineMonthlyItems(
                                  visible: viewState.weekRowOpacity > 0.5,
                                  opacity: viewState.weekRowOpacity,
                                  viewState: viewState,
                                  style: style,
                                ),
                                //  BSchedulerHorizontalTimelineItems(
                                //    controller: widget.controller,
                                //    viewState: viewState,
                                //   ),
                              ],
                            ),
                          ),
                        ),

                      // ユニット区切り罫線
                      BSchedulerUnitDivider(
                        scrollController: viewState.unitDividerScrollController,
                        viewController: controller,
                        viewState: viewState,
                        style: style,
                      ),

                      // 月表示の日付表示
                      BSchedulerWeekRows(
                        visible: viewState.weekRowOpacity > 0,
                        opacity: viewState.weekRowOpacity,
                        controller: controller,
                        viewState: viewState,
                        style: style,
                      ),

                      // 左端の日付表示
                      BSchedulerDateColumn(
                        visible: viewState.dayDetailOpacity + viewState.dayOverviewOpacity > 0,
                        opacity: viewState.dayDetailOpacity + viewState.dayOverviewOpacity,
                        viewState: viewState,
                        style: style,
                      ),

                      // 現在時刻ライン
                      BSchedulerCurrentTimeBorder(
                        visible: viewState.dayDetailOpacity + viewState.dayOverviewOpacity > 0.5,
                        opacity: viewState.dayDetailOpacity + viewState.dayOverviewOpacity,
                        viewState: viewState,
                        style: style,
                      ),

                      // 横スクロールタイムヘッダー・現在時刻ライン
                      // Visibility(
                      //   visible:
                      //         viewState.currentMode.unit == BSchedulerItemDividerUnit.day &&
                      //         viewState.currentMode.direction == Axis.horizontal,
                      //   maintainState: true,
                      //   child: BSchedulerHorizontalTimeHeader(viewState: viewState, style: style),
                      // ),

                      // 月表示の曜日ヘッダー
                      BSchedulerWeekdayRow(
                        visible: viewState.weekRowOpacity > 0,
                        opacity: viewState.weekRowOpacity,
                        height: style.horizontalScrollTimeRowHeight,
                        style: style,
                      ),

                      // デバグ情報表示
                      if (widget.debugView) BSchedulerDebugInfo(viewState: viewState, style: style),

                      // ローディング中
                      if (!viewState.scrollOffsetInitialized)
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                        ),

                      BSchedulerGestureDetecter(
                        scaleActionThreshold: controller.behaviorConfig.scaleActionThreshold,
                        onScaleTriggered: (scaleFactor) {
                          if (scaleFactor == null) return;
                          if (scaleFactor < -0.5) {
                            controller.downscale();
                          } else if (scaleFactor > 0.5) {
                            controller.upscale();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
