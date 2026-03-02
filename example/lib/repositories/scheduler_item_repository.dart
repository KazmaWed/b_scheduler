// ignore: depend_on_referenced_packages
import 'package:b_scheduler/b_scheduler.dart';

abstract class SchedulerItemRepository {
  Future<List<BSchedulerItem>> getItems({required DateTime from, required DateTime to});
}
