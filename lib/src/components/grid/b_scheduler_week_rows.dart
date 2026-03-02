import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/model.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/date_time_util.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 週間表示の行
class BSchedulerWeekRows extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewController controller;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerWeekRows({
    super.key,
    required this.visible,
    required this.opacity,
    required this.controller,
    required this.viewState,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final days = (viewState.items ?? {}).keys.map((e) => e.startTime.to12am()).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    final style = this.style ?? const BSchedulerStyle();
    final alpha = opacity.toAlpha();
    final today = DateTime.now().to12am();
    final baseMonday = DateTimeUtil.lastMonday(viewState.baseDate);

    final dateHeight = style.weekDateHeight;
    final horizontalSpacing = style.monthlyHorizontalSpacing;
    final horizontalPadding = style.monthlyHorizontalPadding;

    final dateWidth = (viewState.viewportWidth - horizontalPadding * 2) / 7;

    final dateTextStyle = style.weekDateTextStyle.copyWith(
      color: style.getOnSurfaceColorWithAlpha(context, alpha),
    );
    final todayTextStyle = style.weekDateTextStyle.copyWith(
      color: style.getOnSurfaceColorWithAlpha(context, alpha),
    );

    final dateHeaderColor = style.getSurfaceColorWithAlpha(context, alpha);
    final todayHeaderColor = style.getPrimaryContainerColorWithAlpha(context, alpha);
    final dividerColor = style.getOutlineColorWithAlpha(context, alpha);
    final dividerColorLight = style.getOutlineColorWithAlpha(context, alpha ~/ 3);

    return IgnorePointer(
      ignoring: viewState.dayDetailOpacity == 1,
      child: ListView.builder(
        controller: viewState.weekColumnScrollController,
        itemExtent: viewState.animatedHeight * 7,
        itemBuilder: (context, index) {
        final int logical = index - viewState.baseIndex ~/ 7;
        final monday = baseMonday.add(Duration(days: logical * 7));

        return Stack(
          children: [
            Container(
              height: viewState.animatedHeight * 7,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 日付
                  for (int d = 0; d <= 6; d++)
                    Builder(
                      builder: (context) {
                        final date = monday.add(Duration(days: d));

                        final isStart = d == 0;
                        final isFirst = date.day == 1;
                        final isMonday = date.weekday == 1;
                        final isFirstInMiddle = isFirst && !isMonday;
                        final isEndInMiddle =
                            date.add(const Duration(days: 1)).day == 1 && date.weekday != 7;

                        final text = isStart || isFirst
                            ? '${date.month}/${date.day}'
                            : '${date.day}';

                        return InkWell(
                          onTap: () => controller.scrollAndFocusTo(date, BSchedulerMode.day),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: dateWidth,
                                height: dateHeight,
                                padding: EdgeInsets.only(
                                  left: horizontalSpacing / 2,
                                  right: horizontalSpacing / 2,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: date == today ? todayHeaderColor : dateHeaderColor,
                                  border: Border(
                                    top: date.day <= 7
                                        ? BorderSide(color: dividerColor, width: style.borderWidth)
                                        : BorderSide(
                                            color: dividerColorLight,
                                            width: style.borderWidth,
                                          ),
                                    left: isFirstInMiddle
                                        ? BorderSide(
                                            color: dividerColor,
                                            width: style.borderWidth / 2,
                                          )
                                        : BorderSide.none,
                                    right: isEndInMiddle
                                        ? BorderSide(
                                            color: dividerColor,
                                            width: style.borderWidth / 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Text(
                                  text,
                                  softWrap: false,
                                  style: date == today ? todayTextStyle : dateTextStyle,
                                ),
                              ),
                              Container(
                                height: viewState.animatedHeight * 7 - dateHeight,
                                width: dateWidth,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: isFirstInMiddle
                                        ? BorderSide(
                                            color: dividerColor,
                                            width: style.borderWidth / 2,
                                          )
                                        : BorderSide.none,
                                    right: isEndInMiddle
                                        ? BorderSide(
                                            color: dividerColor,
                                            width: style.borderWidth / 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: horizontalPadding + horizontalSpacing / 2,
                right: horizontalPadding + horizontalSpacing / 2,
                top: dateHeight,
              ),
              child: Builder(
                builder: (context) {
                  // TODO: アイテムの有無ではなく読み込み処理の状態で判定する
                  final thuesday = monday.add(const Duration(days: 3));
                  final loaded = days.contains(thuesday);

                  return !loaded && viewState.currentMode.unit == BSchedulerItemDividerUnit.week
                      // ロード中 (ただしモード遷移中以外) はくるくる表示
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: style.getOutlineColorWithAlpha(context, 48),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                      : !loaded
                      ? SizedBox.shrink()
                      : SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
      ),
    );
  }
}
