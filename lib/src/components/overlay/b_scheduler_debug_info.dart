import 'package:flutter/material.dart';

import 'package:b_scheduler/src/model/b_scheduler_style.dart';
import 'package:b_scheduler/src/state/b_scheduler_view_state.dart';

/// デバッグ情報表示コンポーネント
class BSchedulerDebugInfo extends StatelessWidget {
  final BSchedulerViewState viewState;
  final BSchedulerStyle? style;

  const BSchedulerDebugInfo({
    super.key,
    required this.viewState,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? const BSchedulerStyle();
    final textStyle = style.debugTextStyle;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scroll Offset: ${viewState.scrollOffsetNotifier.value.toStringAsFixed(2)}',
          style: textStyle,
        ),
        Text(
          'Load Offset Range: '
          '${viewState.itemsOverlayTop.toStringAsFixed(2)} - ${viewState.itemsOverlayBottom.toStringAsFixed(2)}',
          style: textStyle,
        ),
        Text(
          'Center Date: ${viewState.baseDate.year}/${viewState.baseDate.month}/${viewState.baseDate.day}',
          style: textStyle,
        ),
        Text(
          'Focused Date: ${viewState.focusedDate.year}/${viewState.focusedDate.month}/${viewState.focusedDate.day}',
          style: textStyle,
        ),
        Text(
          'Days In Range: ${viewState.topDate.month}/${viewState.topDate.day} - '
          '${viewState.bottomDate.month}/${viewState.bottomDate.day}',
          style: textStyle,
        ),
      ],
    );
  }
}
