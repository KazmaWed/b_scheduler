import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';

class BSchedulerVerticalTimelineDetailItem extends StatelessWidget {
  final BSchedulerItem item;
  final BSchedulerStyle style;
  final int alpha;
  final VoidCallback onTap;

  const BSchedulerVerticalTimelineDetailItem({
    super.key,
    required this.item,
    required this.style,
    required this.alpha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style.detailItemTextStyle;
    final textStyleWithOpacity = textStyle.copyWith(color: textStyle.color!.withAlpha(alpha));
    final itemColor = style.getPrimaryContainerColorWithAlpha(context, alpha);

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.detailItemBorderRadius),
          color: itemColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(style.detailItemBorderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 4,
              runSpacing: -4,
              children: [
                // 開始時間
                Text(
                  '${item.startHourString}:${item.startMinuteString}',
                  style: textStyleWithOpacity,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
                Text('-', style: textStyleWithOpacity),
                // 終了時間
                Text(
                  '${item.endHourString}:${item.endMinuteString}',
                  style: textStyleWithOpacity,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
                Text(
                  item.title,
                  style: textStyleWithOpacity,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
