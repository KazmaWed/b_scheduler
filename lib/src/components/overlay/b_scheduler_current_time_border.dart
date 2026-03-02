import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';

/// 現在時刻ライン
class BSchedulerCurrentTimeBorder extends StatefulWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerCurrentTimeBorder({
    super.key,
    required this.visible,
    required this.opacity,
    required this.viewState,
    this.style,
  });

  @override
  State<BSchedulerCurrentTimeBorder> createState() => _BSchedulerCurrentTimeBorderState();
}

class _BSchedulerCurrentTimeBorderState extends State<BSchedulerCurrentTimeBorder> {
  BSchedulerViewState get viewState => widget.viewState;

  // 現在時刻ライン位置 (横スクロール時)

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final style = widget.style ?? const BSchedulerStyle();

    double currentTimeHorizontalOffset =
        style.borderWidth + // 左端のボーダー幅
        24 + // 日付行の幅
        DateTime.now().hour * (viewState.horizontalScrollContentWidth / 24) + // 時間分
        DateTime.now().minute *
            (viewState.horizontalScrollContentWidth / 24 -
                style.currentTimeBorderWidth -
                style.borderWidth) /
            59 - // 分
        (viewState.horizontalScrollController.hasClients
            ? viewState.horizontalScrollController.offset
            : 0); // スクロール分

    double barFullWidth = viewState.viewportWidth - style.verticalScrollDateColumnWidth; // 全幅
    double baseWidth = barFullWidth * 3 / 7; // 表示モードによらず表示される幅
    double extraWidth = barFullWidth - baseWidth; // Week時にのみ表示される幅
    double circularSize = style.currentTimeBorderWidth * 3;

    double opacity = viewState.dayDetailOpacity + viewState.dayOverviewOpacity;
    double extraBarOpacity = viewState.dayOverviewOpacity > 0 ? viewState.dayDetailOpacity : 1;
    double borderOpacity = opacity / 3;

    Color borderColor = style.getCurrentTimeBorderColor(context);

    return viewState.currentMode.direction == Axis.vertical
        // 縦スクロール表示
        ? ValueListenableBuilder<double>(
            valueListenable: viewState.scrollOffsetNotifier,
            builder: (context, scrollOffset, child) {
              final currentDateTimeVerticalOffset =
                  style.borderWidth +
                  DateTime.now().difference(viewState.startDate).inDays * viewState.animatedHeight +
                  DateTime.now().hour * (viewState.animatedHeight / 24) +
                  DateTime.now().minute *
                      (viewState.animatedHeight / 24 -
                          style.currentTimeBorderWidth -
                          style.borderWidth) /
                      59 -
                  scrollOffset;

              return Opacity(
                opacity: borderOpacity,
                child: Stack(
                  children: [
                    Positioned(
                      left: style.verticalScrollDateColumnWidth,
                      top: currentDateTimeVerticalOffset,
                      height: style.currentTimeBorderWidth,
                      width: baseWidth,
                      child: child!,
                    ),
                    Positioned(
                      left: style.verticalScrollDateColumnWidth + baseWidth,
                      top: currentDateTimeVerticalOffset,
                      height: style.currentTimeBorderWidth,
                      width: extraWidth,
                      child: Opacity(opacity: extraBarOpacity, child: child),
                    ),
                    Positioned(
                      left: style.verticalScrollDateColumnWidth,
                      top:
                          currentDateTimeVerticalOffset -
                          circularSize / 2 +
                          style.currentTimeBorderWidth / 2,
                      child: Container(
                        height: circularSize,
                        width: circularSize,
                        decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Container(color: borderColor),
          )
        // 横スクロール表示
        : Positioned(
            left: currentTimeHorizontalOffset,
            top: 0,
            width: style.currentTimeBorderWidth,
            height: viewState.viewportHeight,
            child: Container(color: borderColor),
          );
  }
}
