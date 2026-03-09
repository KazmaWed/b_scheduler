import 'package:flutter/material.dart';

import 'package:b_scheduler/src/b_scheduler_view.dart';
import 'package:b_scheduler/src/components/items/b_scheduler_vertical_timeline_detail_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 縦スクロール表示 (日単位) - アイテムの表示
class BSchedulerVerticalTimelineDetailItems extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;
  final void Function(BSchedulerItem) onTapItem;
  final BSchedulerDetailItemBuilder? detailItemBuilder;

  const BSchedulerVerticalTimelineDetailItems({
    super.key,
    required this.visible,
    required this.opacity,
    required this.viewState,
    this.style,
    required this.onTapItem,
    this.detailItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final style = this.style ?? const BSchedulerStyle();
    final alpha = opacity.toAlpha();

    final leftPadding = style.verticalScrollDateColumnWidth + style.verticalScrollTimeColumnWidth;
    final contentWidth = viewState.viewportWidth - leftPadding;
    final rowHeight = viewState.animatedHeight;

    final startDate = viewState.startDate;
    final mode = viewState.currentMode;

    final allItems = viewState.items!.keys.toList();
    final allSlotInfo = allItems.toSlotInfo();

    return Stack(
      children: [
        for (var item in allItems.reversed)
          Builder(
            builder: (context) {
              final slotInfo = allSlotInfo[item]!;

              final logicalStartDiffInMinutes = item.startTime.difference(startDate).inMinutes + 1;
              final logicalEndDiffInMinutes = item.endTime.difference(startDate).inMinutes + 1;

              late final double top;
              late final double bottom;

              if (mode.unitsInScreen <= 2) {
                final logicalStartHour = logicalStartDiffInMinutes ~/ 60;
                final logicalStartMinute = logicalStartDiffInMinutes % 60;

                final logicalEndHour = logicalEndDiffInMinutes ~/ 60;
                final logicalEndMinute = (logicalEndDiffInMinutes % 60);

                top =
                    logicalStartHour / 24 * rowHeight +
                    logicalStartMinute / 24 / 60 * (rowHeight - 1) +
                    1;
                bottom =
                    logicalEndHour / 24 * rowHeight + logicalEndMinute / 24 / 60 * (rowHeight - 1);
              } else {
                final logicalStartUnit = logicalStartDiffInMinutes ~/ 120;
                final logicalStartMinute = logicalStartDiffInMinutes % 120;
                final logicalStartSmallHour = logicalStartMinute ~/ 60;

                final logicalEndUnit = logicalEndDiffInMinutes ~/ 120;
                final logicalEndMinute = (logicalEndDiffInMinutes % 120);
                final logicalEndSmallHour = logicalEndMinute ~/ 60;

                top =
                    logicalStartUnit / 12 * rowHeight +
                    logicalStartSmallHour * 0.25 +
                    logicalStartMinute / 12 / 120 * (rowHeight) +
                    1;
                bottom =
                    logicalEndUnit / 12 * rowHeight -
                    logicalEndSmallHour * 0.25 +
                    logicalEndMinute / 12 / 120 * (rowHeight);
              }

              // アイテムの座標とサイズ
              final height = bottom - top;
              final fullWidth = contentWidth - (slotInfo.slotCount - 1) * 1;
              final itemWidth = fullWidth / slotInfo.slotCount;
              final left = (itemWidth + 1) * slotInfo.assignedSlot + leftPadding;

              return Positioned(
                top: top,
                left: left,
                width: itemWidth,
                height: height,
                child:
                    detailItemBuilder?.call(context, item, () => onTapItem(item)) ??
                    BSchedulerVerticalTimelineDetailItem(
                      item: item,
                      style: style,
                      alpha: alpha,
                      onTap: () => onTapItem(item),
                    ),
              );
            },
          ),
      ],
    );
  }
}
