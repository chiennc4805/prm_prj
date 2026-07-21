import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ENetVietApp());
}

/// FPT Student Life – kết nối Nhà trường · Sinh viên · Gia đình.
/// Luồng theo sơ đồ: Login ⇄ ResetPass → HomePage →
///   ListDiemHK · LichHoc · SuKien · DonTu · CLB
/// Nội dung từng mục thay đổi theo vai trò đăng nhập:
///   STUDENT / PARENT / TEACHER (xem home_page.dart).
class ENetVietApp extends StatelessWidget {
  const ENetVietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FPT Student Life',
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}
