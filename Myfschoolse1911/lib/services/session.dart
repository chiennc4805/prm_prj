// ============================================================
// session.dart
// Lưu phiên đăng nhập hiện tại (trong bộ nhớ – singleton đơn giản).
// ============================================================

import '../models/app_user.dart';
import '../models/school_class.dart';
import '../models/student.dart';

/// Phiên làm việc của người dùng đã đăng nhập.
class Session {
  Session._();
  static final Session instance = Session._();

  AppUser? user;

  /// Học sinh đang xem dữ liệu (điểm, đơn từ, TKB...).
  /// - STUDENT: chính mình.
  /// - PARENT : con đang chọn (đổi được nếu có nhiều con).
  /// Được nạp khi đăng nhập và CHIA SẺ cho tất cả màn qua Session này
  /// (đúng ý sơ đồ: dùng Session để truyền dữ liệu giữa các màn hình).
  Student? currentStudent;

  /// Phụ huynh: danh sách con (nếu có).
  List<Student> children = [];

  /// Giáo viên: danh sách lớp chủ nhiệm.
  List<SchoolClass> classes = [];

  /// Vai trò đang được kích hoạt (dùng khi 1 user có nhiều quyền)
  String? currentRole;

  bool get isLoggedIn => user != null;

  bool get isTeacher => currentRole == 'TEACHER';
  bool get isParent => currentRole == 'PARENT';
  bool get isStudent => currentRole == 'STUDENT';

  /// Lớp chủ nhiệm của giáo viên (lớp đầu tiên nếu chủ nhiệm nhiều lớp).
  SchoolClass? get homeroomClass => classes.isNotEmpty ? classes.first : null;

  /// Lớp làm việc hiện tại:
  /// - GV   : lớp chủ nhiệm.
  /// - SV/PH: lớp của học sinh đang xem.
  int? get classId => isTeacher ? homeroomClass?.id : currentStudent?.classId;

  /// Phụ huynh đổi con đang xem.
  void selectChild(Student child) => currentStudent = child;

  void clear() {
    user = null;
    currentRole = null;
    currentStudent = null;
    children = [];
    classes = [];
  }
}
