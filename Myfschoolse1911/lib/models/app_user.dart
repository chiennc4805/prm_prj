/// Tài khoản đăng nhập – khớp entity AppUser bên backend.
class AppUser {
  final int id;
  final String phone;
  final String fullName;
  final String role; // Role mặc định trong DB
  final List<String> roles; // Tất cả các roles mà user có
  final String? email;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.roles = const [],
    this.email,
    this.avatarUrl,
  });

  bool get isTeacher => role == 'TEACHER' || roles.contains('TEACHER');
  bool get isParent => role == 'PARENT' || roles.contains('PARENT');

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] as List<dynamic>?;
    return AppUser(
      id: json['id'] as int,
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      roles: rolesList != null
          ? rolesList.map((e) => e.toString()).toList()
          : [],
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
