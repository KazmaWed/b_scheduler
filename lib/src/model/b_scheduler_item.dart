/// スケジューラー用のアイテムデータモデル
class BSchedulerItem {
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  // BSchedulerTimelineMonthlyItems時の正規化された縦位置 (0.0 ~ 1.0)
  final double startTimeRatio;
  final double heightTimeRatio;

  BSchedulerItem({required this.title, required this.startTime, required this.endTime})
    : startTimeRatio = startTime.hour / 24 + startTime.minute / 24 / 60,
      heightTimeRatio =
          endTime.hour / 24 +
          endTime.minute / 24 / 60 -
          startTime.hour / 24 +
          startTime.minute / 24 / 60;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BSchedulerItem &&
        other.title == title &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => title.hashCode ^ startTime.hashCode ^ endTime.hashCode;

  /// 開始時刻の文字列 (例: "9:00")
  String get startTimeString =>
      '${startTime.hour.toString()}:'
      '${startTime.minute.toString().padLeft(2, '0')}';

  /// 開始時刻の文字列（2桁パディング付き）(例: "9:00")
  String get startTimeStringPadded =>
      '${startTime.hour.toString()}:'
      '${startTime.minute.toString().padLeft(2, '0')}';

  /// 終了時刻の文字列 (例: "10:30")
  String get endTimeString =>
      '${endTime.hour.toString()}:'
      '${endTime.minute.toString().padLeft(2, '0')}';

  /// 終了時刻の文字列（2桁パディング付き）(例: "9:00")
  String get endTimeStringPadded =>
      '${endTime.hour.toString()}:'
      '${endTime.minute.toString().padLeft(2, '0')}';

  /// 時間範囲の文字列 (例: "9:00-10:30")
  String get timeRangeString => '$startTimeString-$endTimeString';

  /// 時間範囲の文字列（2桁パディング付き）(例: "09:00-10:30")
  String get timeRangeStringPadded => '$startTimeStringPadded-$endTimeStringPadded';

  /// タイトルと時間範囲を含む表示用文字列 (例: "会議 9:00-10:30")
  String get displayString => '$title $timeRangeString';

  /// タイトルと時間範囲を含む表示用文字列（2桁パディング付き）(例: "会議 09:00-10:30")
  String get displayStringPadded => '$title $timeRangeStringPadded';

  /// 開始時刻の時間部分のみ（文字列）
  String get startHourString => startTime.hour.toString();

  /// 開始時刻の分部分のみ（2桁パディング付き文字列）
  String get startMinuteString => startTime.minute.toString().padLeft(2, '0');

  /// 終了時刻の時間部分のみ（文字列）
  String get endHourString => endTime.hour.toString();

  /// 終了時刻の分部分のみ（2桁パディング付き文字列）
  String get endMinuteString => endTime.minute.toString().padLeft(2, '0');
}

/// スケジューラーアイテムのスロット情報
class SlotInfo {
  int slotCount;
  int assignedSlot;
  SlotInfo({this.slotCount = 1, this.assignedSlot = 0});
}

/// BSchedulerItemのリストに対する拡張メソッド
extension BSchedulerItemListExtension on List<BSchedulerItem> {
  Map<BSchedulerItem, SlotInfo> toSlotInfo() {
    Map<BSchedulerItem, SlotInfo> output = {};

    Map<BSchedulerItem, List<BSchedulerItem>> overlapTo = {};
    List<List<BSchedulerItem>> appliedItems = [];
    List<BSchedulerItem> remainingItems = List<BSchedulerItem>.from(this);
    final maxSlot = length;

    for (var slot = 0; slot < maxSlot; slot++) {
      final itemsTemp = List.from(remainingItems);
      appliedItems.add([]);

      for (var item in itemsTemp) {
        final overlapsInSameSlot = appliedItems[slot].where((other) {
          return item.startTime.isBefore(other.endTime) && other.startTime.isBefore(item.endTime);
        }).toList();

        if (overlapsInSameSlot.isEmpty) {
          appliedItems[slot].add(item);
          remainingItems.remove(item);
          final overlapsInPreviousSlots = slot == 0
              ? <BSchedulerItem>[]
              : appliedItems[slot - 1].where((other) {
                  return item.startTime.isBefore(other.endTime) &&
                      other.startTime.isBefore(item.endTime);
                }).toList();
          if (overlapTo[item] == null) overlapTo[item] = [];
          for (var prevOther in overlapsInPreviousSlots) {
            overlapTo[item]!.add(prevOther);
          }
        }
      }

      if (appliedItems.last.isEmpty) {
        appliedItems.removeLast();
        break;
      }
    }

    void assignSlot({
      required int slotCount,
      required int assignedSlot,
      required BSchedulerItem item,
    }) {
      if (output[item] != null) return;
      if (slotCount < 0) return;
      if (assignedSlot < 0) return;
      output[item] = SlotInfo(slotCount: slotCount, assignedSlot: assignedSlot);

      final overlapingItems = overlapTo[item];
      if (overlapingItems != null) {
        for (var overlapingItem in overlapingItems) {
          assignSlot(slotCount: slotCount, assignedSlot: assignedSlot - 1, item: overlapingItem);
        }
      }
    }

    for (var slot = appliedItems.length - 1; slot >= 0; slot--) {
      final items = appliedItems[slot];
      for (var item in items) {
        assignSlot(slotCount: slot + 1, assignedSlot: slot, item: item);
      }
    }

    return output;
  }

  Map<DateTime, Map<BSchedulerItem, SlotInfo>> toDateSlotInfo() {
    Map<DateTime, List<BSchedulerItem>> itemsByDate = {};
    for (var item in this) {
      final date = DateTime(item.startTime.year, item.startTime.month, item.startTime.day);
      if (itemsByDate[date] == null) {
        itemsByDate[date] = [];
      }
      itemsByDate[date]!.add(item);
    }

    Map<DateTime, Map<BSchedulerItem, SlotInfo>> output = {};
    itemsByDate.forEach((date, items) {
      output[date] = items.toSlotInfo();
    });

    return output;
  }
}
