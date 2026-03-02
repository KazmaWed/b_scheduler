import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';

// ignore: depend_on_referenced_packages
import 'package:b_scheduler/b_scheduler.dart';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:example/repositories/scheduler_item_repository.dart';
import 'package:example/utils/b_scheduler_item_factory.dart';

class GoogleCalendarRepository implements SchedulerItemRepository {
  final GoogleSignInAccount _user;
  final List<String> _scopes;

  GoogleCalendarRepository(this._user, this._scopes);

  @override
  Future<List<BSchedulerItem>> getItems({required DateTime from, required DateTime to}) async {
    try {
      // Authorize scopes and get client authorization
      final authorization = await _user.authorizationClient.authorizeScopes(_scopes);

      // Get authenticated client using the extension method
      final client = authorization.authClient(scopes: _scopes);

      // Create Calendar API client
      final calendarApi = calendar.CalendarApi(client);

      // List events from primary calendar
      final events = await calendarApi.events.list(
        'primary',
        timeMin: from.toUtc(),
        timeMax: to.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      // Convert Google Calendar events to BSchedulerItems
      return BSchedulerItemFactory.fromGoogleEvents(events.items ?? []);
    } catch (e) {
      debugPrint('Error fetching calendar items: $e');
      return [];
    }
  }
}
