// ============================================================
// auth_service.dart – đăng nhập, đặt lại mật khẩu & nạp phiên (Session).
// ============================================================

import '../models/app_user.dart';
import '../models/school_class.dart';
import '../models/student.dart';
import 'api_client.dart';
import 'session.dart';

class AuthService {
  /// Đăng nhập bằng số điện thoại + mật khẩu.
  /// Thành công: nạp Session (user, currentStudent, children) và trả về AppUser.
  /// Thất bại: ném ApiException (401 nếu sai thông tin).
  static Future<AppUser> login(String phone, String password) async {
    final data =
        await ApiClient.post('/api/auth/login', {
              'phone': phone,
              'password': password,
            })
            as Map<String, dynamic>;

    final userMap = Map<String, dynamic>.from(
      data['user'] as Map<String, dynamic>,
    );
    userMap['roles'] = data['roles'];

    final user = AppUser.fromJson(userMap);
    final session = Session.instance;
    session.clear();
    session.user = user;
    session.currentRole = data['role'] as String?;

    // Học sinh chính để hiển thị dữ liệu (chia sẻ qua Session cho mọi màn)
    if (data['student'] != null) {
      session.currentStudent = Student.fromJson(
        data['student'] as Map<String, dynamic>,
      );
    }
    // Danh sách con (nếu là phụ huynh)
    if (data['children'] != null) {
      session.children = (data['children'] as List<dynamic>)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Danh sách lớp chủ nhiệm (nếu là giáo viên)
    if (data['classes'] != null) {
      session.classes = (data['classes'] as List<dynamic>)
          .map((e) => SchoolClass.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return user;
  }

  /// Yêu cầu gửi OTP
  static Future<String> requestOtp(String phone) async {
    final data =
        await ApiClient.post('/api/auth/forgot-password', {'phone': phone})
            as Map<String, dynamic>;
    return (data['message'] ?? 'Đã gửi mã OTP.').toString();
  }

  /// Cập nhật mật khẩu mới
  static Future<String> updatePassword(String phone, String newPassword) async {
    final data =
        await ApiClient.post('/api/auth/update-password', {
              'phone': phone,
              'newPassword': newPassword,
            })
            as Map<String, dynamic>;
    return (data['message'] ?? 'Đổi mật khẩu thành công.').toString();
  }

  static void logout() => Session.instance.clear();
}
