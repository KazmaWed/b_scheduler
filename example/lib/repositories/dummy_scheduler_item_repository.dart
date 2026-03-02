// ignore: depend_on_referenced_packages
import 'package:b_scheduler/b_scheduler.dart';
import 'package:example/repositories/scheduler_item_repository.dart';

class DummySchedulerItemRepository implements SchedulerItemRepository {
  BSchedulerItem? generateByDatetime(DateTime datetime) {
    if (datetime.hour < 8 || 21 < datetime.hour) return null;

    final hoursSinceEpoch = datetime.difference(DateTime(1970, 1, 1)).inHours;
    final filterNums = [11, 17, 19, 29, 31, 37, 41, 59, 97, 123, 151, 181, 211, 241, 269, 307, 335];

    // hoursSinceEpochがfilterNumsのいずれかで割り切れるかチェック
    final isDivisible = filterNums.any((divisor) => hoursSinceEpoch % divisor == 0);
    if (!isDivisible) return null;

    final title = [
      'Dev Team MTG',
      'AI Project',
      'Company A MTG',
      'Design Review',
      'Code Review',
      'Weekly Report',
      'Lunch MTG',
      'Client MTG',
      'Project Kickoff',
      'Scrum MTG',
      'Workshop',
      'Brainstorming',
      '1on1 MTG',
      'Product Demo',
      'Strategy MTG',
      'Budget Review',
      'Market Analysis',
    ];

    // 割り切れる場合のみアイテムを返す
    final start = datetime.add(
      hoursSinceEpoch % 37 == 0
          ? const Duration(minutes: 15)
          : hoursSinceEpoch % 11 == 0
          ? const Duration(minutes: 30)
          : Duration.zero,
    );
    final end = start.add(
      hoursSinceEpoch % 7 == 0
          ? const Duration(minutes: 90)
          : hoursSinceEpoch % 9 == 0
          ? const Duration(minutes: 45)
          : hoursSinceEpoch % 13 == 0
          ? const Duration(minutes: 30)
          : hoursSinceEpoch % 17 == 0
          ? const Duration(hours: 2)
          : const Duration(hours: 1),
    );
    return BSchedulerItem(
      title: title[hoursSinceEpoch % title.length],
      startTime: start,
      endTime: end,
    );
  }

  @override
  Future<List<BSchedulerItem>> getItems({required DateTime from, required DateTime to}) async {
    List<BSchedulerItem> items = [];
    final s = DateTime(from.year, from.month, from.day, 0);
    final e = DateTime(to.year, to.month, to.day, 0);
    final hours = e.difference(s).inHours + 24;

    for (int i = 0; i <= hours; i++) {
      final datetime = s.add(Duration(hours: i));
      final item = generateByDatetime(datetime);
      if (item != null) items.add(item);
    }

    return items;
  }
}
