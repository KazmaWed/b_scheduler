import 'package:googleapis/calendar/v3.dart' as calendar;
// ignore: depend_on_referenced_packages
import 'package:b_scheduler/b_scheduler.dart';

/// Factory class for creating BSchedulerItem from various sources
class BSchedulerItemFactory {
  /// Create a BSchedulerItem from a Google Calendar Event
  /// Returns null if the event does not have valid start/end times
  static BSchedulerItem? fromGoogleEvent(calendar.Event event) {
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;

    // Return null if start or end time is missing
    if (start == null || end == null) {
      return null;
    }

    return BSchedulerItem(
      title: event.summary ?? 'No Title',
      startTime: start,
      endTime: end,
    );
  }

  /// Convert a list of Google Calendar Events to BSchedulerItems
  /// Skips events without valid start/end times
  static List<BSchedulerItem> fromGoogleEvents(List<calendar.Event> events) {
    return events
        .map((event) => fromGoogleEvent(event))
        .whereType<BSchedulerItem>()
        .toList();
  }
}
