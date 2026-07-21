// ============================================================
// student_service.dart – API học sinh (sĩ số lớp cho giáo viên).
// ============================================================

import '../models/student.dart';
import 'api_client.dart';

class StudentService {
  /// Danh sách học sinh của 1 lớp (giáo viên chủ nhiệm dùng).
  static Future<List<Student>> byClass(int classId) async {
    final list = await ApiClient.getList('/api/students/class/$classId');
    return list
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
