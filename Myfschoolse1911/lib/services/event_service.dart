// ============================================================
// event_service.dart – API sự kiện (SuKien).
// ============================================================

import '../models/event.dart';
import 'api_client.dart';

class EventService {
  static Future<List<Event>> all() async {
    final list = await ApiClient.getList('/api/events');
    return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }
}
