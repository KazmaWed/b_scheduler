import 'package:flutter/material.dart';

/// 横スクロール時の時間罫線グリッド
class BSchedulerHorizontalTimeGrid extends StatelessWidget {
  final double height;
  final double width;
  final int hours;
  final Color? borderColor;
  final double borderWidth;

  const BSchedulerHorizontalTimeGrid({
    super.key,
    required this.height,
    required this.width,
    this.hours = 24,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = this.borderColor ?? Theme.of(context).colorScheme.outline.withAlpha(84);

    return SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          for (int h = 0; h < hours; h++)
            Container(
              width: width / hours,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: borderColor, width: borderWidth),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
