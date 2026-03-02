import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/utils/double_extension.dart';

/// 週間表示の上部の曜日行
class BSchedulerWeekdayRow extends StatelessWidget {
  final bool visible;
  final double opacity;
  final double height;
  final BSchedulerStyle? style;

  const BSchedulerWeekdayRow({
    super.key,
    required this.visible,
    required this.height,
    this.style,
    required this.opacity,
  });

  static const _weekdays = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final style = this.style ?? const BSchedulerStyle();
    final alpha = opacity.toAlpha();
    final textStyle = style.weekdayTextStyle.copyWith(
      color: style.getOnPrimaryColorWithAlpha(context, alpha),
    );

    return Container(
      height: height,
      padding: style.weekdayRowPadding,
      color: style.getPrimaryColorWithAlpha(context, alpha),
      child: Row(
        children: [
          for (int d = 0; d < 7; d++)
            Expanded(
              child: Center(child: Text(_weekdays[d], style: textStyle)),
            ),
        ],
      ),
    );
  }
}
