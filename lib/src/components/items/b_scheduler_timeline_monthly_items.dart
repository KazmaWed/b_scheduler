import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/date_time_util.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 縦スクロール時のアイテムの表示
/// 月表示 - アイテムの表示
class BSchedulerTimelineMonthlyItems extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerTimelineMonthlyItems({
    super.key,
    required this.visible,
    required this.opacity,
    required this.viewState,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    if ((viewState.items ?? {}).isEmpty) return const SizedBox.shrink();

    final style = this.style ?? const BSchedulerStyle();
    final alpha = opacity.toAlpha();

    final dateHeight = style.monthlyDateHeight;
    final horizontalPadding = style.monthlyHorizontalPadding;
    final horizontalSpacing = style.monthlyHorizontalSpacing;
    final verticalPadding = style.monthlyVerticalPadding;
    final verticalSpacing = style.monthlyVerticalSpacing;

    final textStyle = style.monthlyItemTextStyle.copyWith(color: style.getOnSurfaceColor(context));
    final itemColor = style.getPrimaryContainerColorWithAlpha(context, alpha);
    final textStyleWithOpacity = textStyle.copyWith(
      color: (textStyle.color ?? style.getOnSurfaceColor(context)).withAlpha(alpha),
    );

    final items = viewState.items!;
    final animatedHeight = viewState.animatedHeight * 7;
    final viewportWidth = viewState.viewportWidth;
    final startDate = viewState.startDate;

    final startMonday = DateTimeUtil.lastMonday(startDate);

    final firstItemDate = items.keys.first.startTime.to12am();
    final lastItemDate = items.keys.last.startTime.to12am();

    final firstMonday = DateTimeUtil.lastMonday(firstItemDate);
    final lastSunday = DateTimeUtil.nextSunday(lastItemDate);

    final totalWeeks = lastSunday.difference(firstMonday).inDays ~/ 7 + 1;

    final itemsAreaHeight = animatedHeight - dateHeight - verticalPadding - verticalSpacing;
    final width = (viewportWidth - horizontalPadding * 2 - horizontalSpacing * 7) / 7;

    final itemsByDate = <DateTime, List<BSchedulerItem>>{};
    int i = 0;
    final iMax = items.length;
    while (i < iMax) {
      final item = items.keys.elementAt(i);
      final date = item.startTime.to12am();
      itemsByDate.putIfAbsent(date, () => []).add(item);
      i++;
    }

    return CustomPaint(
      painter: _TimelineMonthlyPainter(
        itemsByDate: itemsByDate,
        firstMonday: firstMonday,
        startMonday: startMonday,
        totalWeeks: totalWeeks,
        animatedHeight: animatedHeight,
        dateHeight: dateHeight,
        verticalSpacing: verticalSpacing,
        itemsAreaHeight: itemsAreaHeight,
        horizontalPadding: horizontalPadding,
        horizontalSpacing: horizontalSpacing,
        width: width,
        itemColor: itemColor,
        textStyle: textStyleWithOpacity,
      ),
      size: Size.infinite,
    );
  }
}

class _TimelineMonthlyPainter extends CustomPainter {
  final Map<DateTime, List<BSchedulerItem>> itemsByDate;
  final DateTime firstMonday;
  final DateTime startMonday;
  final int totalWeeks;
  final double animatedHeight;
  final double dateHeight;
  final double verticalSpacing;
  final double itemsAreaHeight;
  final double horizontalPadding;
  final double horizontalSpacing;
  final double width;
  final Color itemColor;
  final TextStyle textStyle;

  _TimelineMonthlyPainter({
    required this.itemsByDate,
    required this.firstMonday,
    required this.startMonday,
    required this.totalWeeks,
    required this.animatedHeight,
    required this.dateHeight,
    required this.verticalSpacing,
    required this.itemsAreaHeight,
    required this.horizontalPadding,
    required this.horizontalSpacing,
    required this.width,
    required this.itemColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemPaint = Paint()
      ..color = itemColor
      ..style = PaintingStyle.fill;

    final lefts = <double>[];
    int i = 0;
    while (i < 7) {
      lefts.add(horizontalPadding + (width + horizontalSpacing) * i + horizontalSpacing / 2);
      i++;
    }

    int week = 0;
    while (week < totalWeeks) {
      final thisWeekMonday = firstMonday.add(Duration(days: week * 7));
      final row = thisWeekMonday.difference(startMonday).inDays ~/ 7;
      final areaTop = (row) * animatedHeight + dateHeight + verticalSpacing;
      final areaCenter = row * animatedHeight + itemsAreaHeight / 2 + dateHeight + verticalSpacing;

      int day = 0;
      while (day < 7) {
        final date = thisWeekMonday.add(Duration(days: day));
        final column = (date.weekday - 1) % 7;
        final left = lefts[column];

        final itemsInTheDate = itemsByDate[date] ?? [];
        final text =
            '${itemsInTheDate.length.toString()} item${itemsInTheDate.length > 1 ? 's' : ''}';

        final textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(minWidth: 0, maxWidth: width);
        textPainter.paint(canvas, Offset(left + (width - textPainter.width) / 2, areaTop));

        if (itemsInTheDate.isEmpty) {
          day++;
          continue;
        }

        int i = 0;
        final iMax = itemsInTheDate.length;
        while (i < iMax) {
          final item = itemsInTheDate[i];
          if (item.startTime.to12am() != date) {
            i++;
            continue;
          }

          final top = areaCenter + (item.startTimeRatio - 0.5) * (itemsAreaHeight) + 1;
          final height = item.heightTimeRatio * itemsAreaHeight;

          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, width, height),
            const Radius.circular(1.0),
          );
          canvas.drawRRect(rect, itemPaint);

          i++;
        }
        day++;
      }
      week++;
    }
  }

  @override
  bool shouldRepaint(_TimelineMonthlyPainter oldDelegate) {
    return oldDelegate.itemsByDate != itemsByDate ||
        oldDelegate.animatedHeight != animatedHeight ||
        oldDelegate.itemColor != itemColor ||
        oldDelegate.width != width;
  }
}
