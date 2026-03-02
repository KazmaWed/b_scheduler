import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';

/// 横スクロール時の上部時間帯
class BSchedulerHorizontalTimeHeader extends StatelessWidget {
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerHorizontalTimeHeader({
    super.key,
    required this.viewState,
    this.style,
  });

  // 現在時刻ライン位置 (横スクロール時)
  double currentTimeHorizontalOffset(BSchedulerStyle style) =>
      style.borderWidth + // 左端のボーダー幅
      DateTime.now().hour * (viewState.horizontalScrollContentWidth / 24) + // 時間分
      DateTime.now().minute *
          (viewState.horizontalScrollContentWidth / 24 -
              style.currentTimeBorderWidth -
              style.borderWidth) /
          59 - // 分
      (viewState.horizontalTimeScrollController.hasClients
          ? viewState.horizontalTimeScrollController.offset * 0
          : 0); // スクロール分

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? const BSchedulerStyle();
    final timeTextStyle = style.horizontalTimeHeaderTextStyle;
    final borderColor = style.getOutlineColor(context);
    final backgroundColor = style.getSurfaceColor(context);
    final cellBorderColor = style.getOutlineColorWithAlpha(context, style.baseOutlineAlpha);

    return Container(
      height: style.horizontalScrollTimeRowHeight,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: style.verticalScrollDateColumnWidth),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: style.borderWidth),
        ),
      ),
      child: SingleChildScrollView(
        controller: viewState.horizontalTimeScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: viewState.horizontalScrollContentWidth,
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  for (int h = 0; h < 24; h++)
                    Container(
                      width: viewState.horizontalScrollContentWidth / 24,
                      padding: EdgeInsets.only(left: style.horizontalTimeHeaderCellLeftPadding),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: cellBorderColor, width: style.borderWidth),
                        ),
                      ),
                      child: Text('$h:00', style: timeTextStyle),
                    ),
                ],
              ),
              if (style.currentTimeBorderWidth > 0)
                Positioned(
                  left: currentTimeHorizontalOffset(style),
                  top: 0,
                  width: style.currentTimeBorderWidth,
                  height: style.horizontalScrollTimeRowHeight,
                  child: Container(color: cellBorderColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
