// ============================================================
// schedule_service.dart – API lịch học / TKB (LichHoc).
// ============================================================

import '../models/schedule.dart';
import 'api_client.dart';

class ScheduleService {
  /// Thời khóa biểu của 1 lớp.
  static Future<List<Schedule>> byClass(int classId) async {
    final list = await ApiClient.getList('/api/schedules/class/$classId');
    return list
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
