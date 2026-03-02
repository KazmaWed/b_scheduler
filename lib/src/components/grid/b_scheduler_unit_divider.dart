import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_controller.dart';
import 'package:b_scheduler/src/model/b_scheduler_mode.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/state.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// スケジューラの単位区切り線コンポーネント
class BSchedulerUnitDivider extends StatefulWidget {
  final ScrollController scrollController;
  final BSchedulerViewController viewController;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerUnitDivider({
    super.key,
    required this.scrollController,
    required this.viewController,
    required this.viewState,
    this.style,
  });

  @override
  State<BSchedulerUnitDivider> createState() => _BSchedulerUnitDividerState();
}

class _BSchedulerUnitDividerState extends State<BSchedulerUnitDivider> {
  @override
  Widget build(BuildContext context) {
    int dividerPer = widget.viewState.currentMode.unit == BSchedulerItemDividerUnit.day ? 1 : 7;

    final style = widget.style ?? const BSchedulerStyle();
    final double opacity = widget.viewState.currentMode.unit == BSchedulerItemDividerUnit.day
        ? widget.viewState.dayDetailOpacity + widget.viewState.dayOverviewOpacity
        : widget.viewState.weekRowOpacity / 3;
    final alpha = opacity.toAlpha();

    final dividerColor = style.getOutlineColorWithAlpha(context, alpha);

    return IgnorePointer(
      ignoring: widget.viewState.dayDetailOpacity == 1,
      child: Stack(
        children: [
          ListView.builder(
          controller: widget.scrollController,
          itemExtent: widget.viewState.animatedHeight * dividerPer,
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: style.borderWidth, color: dividerColor),
                ),
              ),
              child: widget.viewState.dayOverviewOpacity == 1
                  // 簡略表示のときはタップで日表示に切り替え
                  ? InkWell(
                      onTap: () => widget.viewController.scrollAndFocusTo(
                        widget.viewController.baseDate.add(
                          Duration(days: index - widget.viewState.baseIndex),
                        ),
                        BSchedulerMode.day,
                      ),
                    )
                  : null,
            );
          },
        ),
        ],
      ),
    );
  }
}
