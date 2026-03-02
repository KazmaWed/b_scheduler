import 'package:flutter/material.dart';

import 'package:b_scheduler/src/components/grid/grid.dart';
import 'package:b_scheduler/src/model/b_scheduler_mode.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'b_scheduler_horizontal_timeline_item.dart';

/// 横スクロール時のアイテム群の表示
class BSchedulerHorizontalTimelineItems extends StatefulWidget {
  final BSchedulerViewState viewState;

  const BSchedulerHorizontalTimelineItems({
    super.key,
    required this.viewState,
  });

  @override
  State<BSchedulerHorizontalTimelineItems> createState() =>
      _BSchedulerHorizontalTimelineItemsState();
}

class _BSchedulerHorizontalTimelineItemsState extends State<BSchedulerHorizontalTimelineItems> {
  BSchedulerViewState get viewState => widget.viewState;
  int get baseIndex => viewState.baseIndex;
  DateTime get startDate => viewState.startDate;
  BSchedulerMode get mode => viewState.currentMode;

  double get horizontalTimeLineScrollInitialOffset =>
      (DateTime.now().hour - 1) * (viewState.horizontalScrollContentWidth / 24);

  @override
  void didUpdateWidget(BSchedulerHorizontalTimelineItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewState.currentMode != widget.viewState.currentMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewState.horizontalTimeScrollController.jumpTo(horizontalTimeLineScrollInitialOffset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        SingleChildScrollView(
          controller: viewState.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: viewState.horizontalScrollContentWidth,
            child: Stack(
              children: [
                BSchedulerHorizontalTimeGrid(
                  height: baseIndex * 2 * viewState.animatedHeight,
                  width: viewState.horizontalScrollContentWidth,
                ),
                ...viewState.items!.entries.map((entry) {
                  return BSchedulerHorizontalTimelineItem(
                    item: entry.key,
                    slotInfo: entry.value,
                    startDate: startDate,
                    rowHeight: viewState.animatedHeight,
                    contentWidth: viewState.horizontalScrollContentWidth,
                    mode: mode,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
