import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 悲嘆表示の左端の日付行
class BSchedulerDateColumn extends StatelessWidget {
  final bool visible;
  final double opacity;
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerDateColumn({
    super.key,
    required this.visible,
    required this.opacity,
    required this.viewState,
    this.style,
  });

  static final _weekdays = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final style = this.style ?? const BSchedulerStyle();
    int alpha = opacity.toAlpha();

    Color dividerColor = style.getOnPrimaryColorWithAlpha(context, alpha);
    final dateTextStyle = style.dateTextStyle.copyWith(
      color: style.getOnPrimaryColorWithAlpha(context, alpha),
    );
    TextStyle textStyleWithAlpha = dateTextStyle.copyWith(
      color: dateTextStyle.color?.withAlpha(alpha),
    );

    return SizedBox(
      width: style.verticalScrollDateColumnWidth,
      child: AnimatedBuilder(
        animation: viewState.dateColumnScrollController,
        builder: (context, child) {
          final scrollOffset = viewState.dateColumnScrollController.hasClients
              ? viewState.dateColumnScrollController.offset
              : 0.0;

          return ListView.builder(
            controller: viewState.dateColumnScrollController,
            itemExtent: viewState.animatedHeight,
            itemBuilder: (context, index) {
              double dateTextHeight = 0;
              final int logical = index - viewState.baseIndex;
              final date = viewState.baseDate.add(Duration(days: logical));
              final itemText = '${date.month}/${date.day} ${_weekdays[date.weekday - 1]}';

              // 日付テキストの高さを測定してキャッシュ
              final GlobalKey containerKey = GlobalKey();
              final topPadding = (scrollOffset - index * viewState.animatedHeight).clamp(
                0.0,
                viewState.animatedHeight - dateTextHeight,
              );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final RenderBox? renderBox =
                containerKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null && dateTextHeight != renderBox.size.height) {
              dateTextHeight = renderBox.size.height;
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Divider(height: 1, color: dividerColor),
              Container(
                height: viewState.animatedHeight - 1,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    // 日付
                    Container(
                      color: style.getPrimaryColorWithAlpha(context, alpha),
                      key: containerKey,
                      width: style.verticalScrollDateColumnWidth,
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: topPadding),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(itemText, softWrap: false, style: textStyleWithAlpha),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
        },
      ),
    );
  }
}
