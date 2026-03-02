import 'package:flutter/material.dart';

import 'package:b_scheduler/src/components/common/vertical_text.dart';
import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_mode.dart';

/// 横スクロール時のアイテムの表示
class BSchedulerHorizontalTimelineItem extends StatelessWidget {
  final BSchedulerItem item;
  final SlotInfo slotInfo;
  final DateTime startDate;
  final double rowHeight;
  final double contentWidth;
  final BSchedulerMode mode;
  final TextStyle? textStyle;
  final bool verticalText;

  const BSchedulerHorizontalTimelineItem({
    super.key,
    required this.item,
    required this.slotInfo,
    required this.startDate,
    required this.rowHeight,
    required this.contentWidth,
    required this.mode,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 10),
    this.verticalText = false,
  });

  @override
  Widget build(BuildContext context) {
    // 基準日からの論理的なインデックス
    final logicalDateIndex = item.startTime.difference(startDate).inDays;
    final hourWidth = contentWidth / 24;
    final minuteWidth = hourWidth / 60;

    final slotHeight = rowHeight / slotInfo.slotCount;
    final top =
        logicalDateIndex * rowHeight +
        slotHeight * (slotInfo.slotCount - slotInfo.assignedSlot - 1) +
        1;
    final height = slotHeight - 1;

    // アイテムの座標とサイズ
    final left = hourWidth * item.startTime.hour + minuteWidth * item.startTime.minute + 1;
    final right = hourWidth * item.endTime.hour + minuteWidth * item.endTime.minute;
    final text = item.title;

    return Positioned(
      top: top,
      left: left,
      width: right - left,
      height: height,
      child: Container(
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
        ),
        child: verticalText
            ? VerticalText(text, style: textStyle)
            : RotatedBox(
                quarterTurns: 3,
                child: Text(
                  text,
                  style: textStyle,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.start,
                ),
              ),
        // ),
      ),
    );
  }
}
