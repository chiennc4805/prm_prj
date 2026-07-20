// ============================================================
// grade_service.dart – API điểm / sổ liên lạc.
// ============================================================

import '../models/grade.dart';
import 'api_client.dart';

class GradeService {
  /// Điểm của 1 học sinh (phụ huynh xem con).
  static Future<List<Grade>> byStudent(int studentId) async {
    final list = await ApiClient.getList('/api/grades/student/$studentId');
    return list.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Toàn bộ điểm (giáo viên).
  static Future<List<Grade>> all() async {
    final list = await ApiClient.getList('/api/grades');
    return list.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Danh sách lớp/môn mà giáo viên đang dạy
  static Future<List<dynamic>> teacherAssignments(String teacherName) async {
    // Return raw map or create a model. Let's return raw map and parse it in UI or use a model.
    return ApiClient.getList('/api/grades/teacher/$teacherName/assignments');
  }

  /// Danh sách điểm của lớp theo môn cho giáo viên
  static Future<List<Grade>> teacherClassGrades(
      String teacherName, int classId, String subject, String semester) async {
    final list = await ApiClient.getList(
        '/api/grades/teacher/$teacherName/class/$classId/subject/$subject/semester/$semester');
    return list.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Grade> create(Grade g) async {
    final data = await ApiClient.post('/api/grades', g.toJson());
    return Grade.fromJson(data as Map<String, dynamic>);
  }

  static Future<Grade> update(int id, Grade g) async {
    final data = await ApiClient.put('/api/grades/$id', g.toJson());
    return Grade.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> delete(int id) => ApiClient.delete('/api/grades/$id');
}
