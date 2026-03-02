import 'dart:math';

import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_item.dart';
import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 縦スクロール表示 (週単位) - アイテムの表示
class BSchedulerVerticalTimelineOverviewItems extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerVerticalTimelineOverviewItems({
    super.key,
    required this.visible,
    required this.opacity,
    required this.viewState,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final style = this.style ?? const BSchedulerStyle();
    final alpha = opacity.toAlpha();

    final horizontalPadding = style.overviewItemHorizontalPadding;
    final textSpacing = style.overviewItemTextSpacing;

    final rowHeight = viewState.animatedHeight;
    final leftPadding = style.verticalScrollDateColumnWidth;
    final baseContentWidth = viewState.viewportWidth - leftPadding;

    final textStyle = style.overviewItemTextStyle;
    final itemColor = style.getPrimaryContainerColorWithAlpha(context, alpha);
    final textStyleWithOpacity = textStyle.copyWith(
      color: (textStyle.color ?? Colors.black).withAlpha(alpha),
    );

    final allItems = viewState.items!.keys.toList();

    final dateItemMap = allItems.toDateSlotInfo();
    final dates = dateItemMap.keys.toList()..sort((a, b) => a.compareTo(b));

    final contentWidth = baseContentWidth * 3 / 7;
    final textHeight = textStyle.fontSize! * 1.1;
    final maxTextCountPerRow = max(
      0,
      ((viewState.viewportHeight /
                      (viewState.transitioningFromDayOverview
                          ? viewState.prevMode.unitsInScreen
                          : viewState.currentMode.unitsInScreen)) /
                  textHeight)
              .floor() -
          2,
    );

    return CustomPaint(
      painter: _VerticalTimelineOverviewPainter(
        dates: dates,
        dateItemMap: dateItemMap,
        viewState: viewState,
        style: style,
        alpha: alpha,
        itemColor: itemColor,
        textStyle: textStyleWithOpacity,
        rowHeight: rowHeight,
        leftPadding: leftPadding,
        contentWidth: contentWidth,
        horizontalPadding: horizontalPadding,
        textSpacing: textSpacing,
        maxTextCountPerRow: maxTextCountPerRow,
        textHeight: textHeight,
      ),
      size: Size.infinite,
    );
  }
}

class _VerticalTimelineOverviewPainter extends CustomPainter {
  final List<DateTime> dates;
  final Map<DateTime, Map<BSchedulerItem, SlotInfo>> dateItemMap;
  final BSchedulerViewState viewState;
  final BSchedulerStyle style;
  final int alpha;
  final Color itemColor;
  final TextStyle textStyle;
  final double rowHeight;
  final double leftPadding;
  final double contentWidth;
  final double horizontalPadding;
  final double textSpacing;
  final int maxTextCountPerRow;
  final double textHeight;

  _VerticalTimelineOverviewPainter({
    required this.dates,
    required this.dateItemMap,
    required this.viewState,
    required this.style,
    required this.alpha,
    required this.itemColor,
    required this.textStyle,
    required this.rowHeight,
    required this.leftPadding,
    required this.contentWidth,
    required this.horizontalPadding,
    required this.textSpacing,
    required this.maxTextCountPerRow,
    required this.textHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemPaint = Paint()
      ..color = itemColor
      ..style = PaintingStyle.fill;

    final borderRadius = style.overviewItemBorderRadius;

    int day = 0;
    final dateCount = dates.length;
    while (day < dateCount) {
      final date = dates[day];
      final rowTop = date.difference(viewState.startDate).inDays * rowHeight;
      final itemSlotMap = Map.fromEntries(dateItemMap[date]!.entries);

      int i = 0;
      final iMax = itemSlotMap.length;
      while (i < iMax) {
        final e = itemSlotMap.entries.elementAt(i);
        final item = e.key;
        final slotInfo = e.value;

        final logicalStartDiffInMinutes = item.startTime.difference(viewState.startDate).inMinutes;
        final logicalEndDiffInMinutes = item.endTime.difference(viewState.startDate).inMinutes;

        final logicalStartUnit = logicalStartDiffInMinutes ~/ 120;
        final logicalStartMinute = logicalStartDiffInMinutes % 120;
        final logicalStartSmallHour = logicalStartMinute ~/ 60;

        final logicalEndUnit = logicalEndDiffInMinutes ~/ 120;
        final logicalEndMinute = (logicalEndDiffInMinutes % 120);
        final logicalEndSmallHour = logicalEndMinute ~/ 60;

        final top =
            logicalStartUnit / 12 * rowHeight +
            logicalStartSmallHour * 0.25 +
            logicalStartMinute / 12 / 120 * (rowHeight) +
            1;
        final bottom =
            logicalEndUnit / 12 * rowHeight -
            logicalEndSmallHour * 0.25 +
            logicalEndMinute / 12 / 120 * (rowHeight);

        final height = bottom - top;
        final fullWidth = contentWidth - (slotInfo.slotCount - 1) * 1;
        final itemWidth = fullWidth / slotInfo.slotCount;
        final left = (itemWidth + 1) * slotInfo.assignedSlot + leftPadding;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, itemWidth, height),
          Radius.circular(borderRadius),
        );
        canvas.drawRRect(rect, itemPaint);

        i++;
      }

      _drawTexts(canvas, date, rowTop, itemSlotMap);

      day++;
    }
  }

  void _drawTexts(Canvas canvas, DateTime date, double rowTop, Map<BSchedulerItem, SlotInfo> itemSlotMap) {
    final visibleItemCount = min(maxTextCountPerRow, itemSlotMap.length);
    if (visibleItemCount == 0) return;

    final textLeft = contentWidth + horizontalPadding + leftPadding;
    final fontSize = textStyle.fontSize!;

    final sortedItems = itemSlotMap.keys.toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    final hasMoreItems = itemSlotMap.length > maxTextCountPerRow;
    final moreItemsHeight = hasMoreItems ? fontSize * 0.9 * 1.1 : 0.0;
    final totalContentHeight = visibleItemCount * textHeight + (hasMoreItems ? (fontSize * 0.2 + moreItemsHeight) : 0.0);
    final startY = rowTop + (rowHeight - totalContentHeight) / 2;

    int i = 0;
    while (i < visibleItemCount) {
      final item = sortedItems[i];
      final yOffset = startY + i * textHeight;

      _drawTimeAndTitle(canvas, item, textLeft, yOffset, fontSize);

      i++;
    }

    if (hasMoreItems) {
      final yOffset = startY + visibleItemCount * textHeight;
      _drawMoreItemsText(canvas, itemSlotMap.length - maxTextCountPerRow, textLeft, yOffset, fontSize);
    }
  }

  void _drawTimeAndTitle(Canvas canvas, BSchedulerItem item, double x, double y, double fontSize) {
    double currentX = x;

    final hourText = _buildTextPainter(item.startHourString, textStyle);
    hourText.layout(minWidth: 0, maxWidth: fontSize * 1.6);
    hourText.paint(canvas, Offset(currentX + fontSize * 1.6 - hourText.width, y));
    currentX += fontSize * 1.6;

    final colonText = _buildTextPainter(':', textStyle);
    colonText.layout(minWidth: 0, maxWidth: fontSize * 0.5);
    colonText.paint(canvas, Offset(currentX + (fontSize * 0.5 - colonText.width) / 2, y));
    currentX += fontSize * 0.5;

    final minuteText = _buildTextPainter(item.startMinuteString, textStyle);
    minuteText.layout(minWidth: 0, maxWidth: fontSize * 1.6);
    minuteText.paint(canvas, Offset(currentX, y));
    currentX += fontSize * 1.6;

    currentX += textSpacing;

    final titleText = _buildTextPainter(item.title, textStyle);
    titleText.layout(minWidth: 0, maxWidth: contentWidth - (fontSize * 3.7 + textSpacing));
    titleText.paint(canvas, Offset(currentX, y));
  }

  void _drawMoreItemsText(Canvas canvas, int count, double x, double y, double fontSize) {
    final moreStyle = textStyle.copyWith(
      fontSize: fontSize * 0.9,
      fontWeight: FontWeight.bold,
      color: textStyle.color?.withAlpha((alpha * 0.5).toInt()),
    );
    final moreText = _buildTextPainter(
      'and $count more item${count > 1 ? 's' : ''}',
      moreStyle,
    );
    moreText.layout(minWidth: 0, maxWidth: contentWidth);
    moreText.paint(canvas, Offset(x + fontSize * 3.7 + textSpacing, y + fontSize * 0.2));
  }

  TextPainter _buildTextPainter(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    );
  }

  @override
  bool shouldRepaint(_VerticalTimelineOverviewPainter oldDelegate) {
    return oldDelegate.viewState != viewState ||
        oldDelegate.alpha != alpha ||
        oldDelegate.itemColor != itemColor ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.dates != dates;
  }
}
