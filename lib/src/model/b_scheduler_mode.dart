import 'package:flutter/material.dart';

class BSchedulerMode {
  final BSchedulerItemDividerUnit unit;
  final double unitsInScreen;
  final String label;
  final Axis direction;
  final IconData icon;

  const BSchedulerMode._internal(
    this.unit,
    this.unitsInScreen,
    this.label,
    this.direction,
    this.icon,
  );

  static const day = BSchedulerMode._internal(
    .day,
    1.2,
    'Day',
    .vertical,
    Icons.calendar_view_day_rounded,
  );
  static const week = BSchedulerMode._internal(
    .day,
    7.5,
    'Week',
    .vertical,
    Icons.density_small_rounded,
  );
  static const month = BSchedulerMode._internal(
    .week,
    42,
    'Month',
    .vertical,
    Icons.calendar_view_month_rounded,
  );
  // static const year = BSchedulerMode._internal(.month, 5, 'Year', .horizontal);

  double get unitHeightFactor => 1 / unitsInScreen;
}

enum BSchedulerItemDividerUnit { day, week, month }
