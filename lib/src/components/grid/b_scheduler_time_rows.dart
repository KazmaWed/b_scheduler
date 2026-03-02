import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 時間行コンポーネント
class BSchedulerTimeRows extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerTimeRows({
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
    final baseAlpha = style.baseOutlineAlpha;
    final lightAlpha = style.lightOutlineAlpha;
    final timeTextStyle = style.timeTextStyle.copyWith(
      color: (style.timeTextStyle.color ?? Colors.black).withAlpha(
        viewState.dayDetailOpacity.toAlpha(),
      ),
    );

    final dividerColor = style.getOutlineColor(context);
    final dividerLength = viewState.dayDetailOpacity > 0.5
        ? viewState.viewportWidth - style.verticalScrollDateColumnWidth
        : (viewState.viewportWidth - style.verticalScrollDateColumnWidth) * 3 / 7;

    final detailMode = viewState.dayDetailOpacity > 0.5;

    return ListView.builder(
      controller: viewState.timeColumnScrollController,
      itemExtent: viewState.animatedHeight,
      itemBuilder: (context, index) {
        return Container(
          height: viewState.animatedHeight,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: style.verticalScrollDateColumnWidth),
          child: Column(
            children: [
              for (int h = 0; h < 24; h++)
                Container(
                  height: viewState.animatedHeight / 24,
                  width: dividerLength,
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: dividerColor.withAlpha(
                          detailMode
                              ? baseAlpha // 24時間表示
                              : h % 2 == 0
                              ? lightAlpha // 2時間ごとに薄い罫線
                              : 0,
                        ),
                        width: style.borderWidth,
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.topRight,
                    width: style.verticalScrollTimeColumnWidth,
                    padding: EdgeInsets.only(right: style.timeRowRightPadding),
                    child: Text('$h:00', style: timeTextStyle),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
