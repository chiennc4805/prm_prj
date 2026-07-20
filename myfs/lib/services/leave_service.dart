// ============================================================
// leave_service.dart – API đơn xin nghỉ học.
// ============================================================

import '../models/leave_request.dart';
import 'api_client.dart';

class LeaveService {
  /// Phụ huynh tạo đơn xin nghỉ.
  static Future<LeaveRequest> create(LeaveRequest req) async {
    final data = await ApiClient.post('/api/leaves', req.toJson());
    return LeaveRequest.fromJson(data as Map<String, dynamic>);
  }

  /// Lịch sử đơn của 1 học sinh.
  static Future<List<LeaveRequest>> byStudent(int studentId) async {
    final list = await ApiClient.getList('/api/leaves/student/$studentId');
    return list.map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Đơn của 1 lớp (giáo viên duyệt).
  static Future<List<LeaveRequest>> byClass(int classId) async {
    final list = await ApiClient.getList('/api/leaves/class/$classId');
    return list.map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Giáo viên duyệt/từ chối đơn.
  static Future<LeaveRequest> updateStatus(int id, String status, int reviewerId) async {
    final data = await ApiClient.put('/api/leaves/$id/status', {
      'status': status,
      'reviewedById': reviewerId,
    });
    return LeaveRequest.fromJson(data as Map<String, dynamic>);
  }
}
