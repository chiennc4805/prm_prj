// ============================================================
// notification_service.dart – API thông báo / hộp thư.
// ============================================================

import '../models/notification_item.dart';
import 'api_client.dart';

class NotificationService {
  /// Tất cả thông báo (giáo viên xem).
  static Future<List<NotificationItem>> all() async {
    final list = await ApiClient.getList('/api/notifications');
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Thông báo của 1 lớp + toàn trường (sinh viên / phụ huynh xem).
  static Future<List<NotificationItem>> forClass(int classId) async {
    final list = await ApiClient.getList('/api/notifications/class/$classId');
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Giáo viên gửi thông báo (toàn trường hoặc lớp chủ nhiệm).
  static Future<NotificationItem> send(NotificationItem noti) async {
    final data = await ApiClient.post('/api/notifications', noti.toJson());
    return NotificationItem.fromJson(data as Map<String, dynamic>);
  }
}
