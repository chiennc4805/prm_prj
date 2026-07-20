// ============================================================
// home_page.dart – Trang chủ sau khi đăng nhập (theo sơ đồ).
// HomePage → ListDiemHK · LichHoc · SuKien · DonTu · CLB
// Nội dung 5 mục thay đổi theo vai trò (SV / PH / GV):
//   - STUDENT : xem điểm, TKB, sự kiện, tạo đơn, CLB
//   - PARENT  : như SV nhưng theo con đang chọn (đổi được con)
//   - TEACHER : quản lý điểm, lịch dạy, sự kiện, duyệt đơn, CLB
// Dữ liệu người dùng / học sinh lấy từ Session (chia sẻ giữa các màn).
// ============================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/student.dart';
import '../services/session.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'features/diem_screen.dart';
import 'features/lich_hoc_screen.dart';
import 'features/su_kien_screen.dart';
import 'features/don_tu_screen.dart';
import 'features/clb_screen.dart';
import 'features/thong_bao_screen.dart';
import 'features/profile_screen.dart';
import 'teacher/quan_ly_diem_screen.dart';
import 'teacher/duyet_don_screen.dart';
import '../widgets/ui_helpers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final session = Session.instance;

  List<_HomeGroup> get _groups {
    if (session.isTeacher) {
      return [
        _HomeGroup('Học tập & Giảng dạy', [
          _HomeItem('ListDiemHK', 'Quản lý điểm', 'Nhập / sửa điểm lớp CN', Icons.assessment, AppColors.info, () => const QuanLyDiemScreen()),
          _HomeItem('LichHoc', 'Lịch dạy', 'TKB lớp chủ nhiệm', Icons.calendar_month, AppColors.success, () => const LichHocScreen()),
        ]),
        _HomeGroup('Hoạt động', [
          _HomeItem('SuKien', 'Sự kiện', 'Hoạt động toàn trường', Icons.event, AppColors.warning, () => const SuKienScreen()),
          _HomeItem('CLB', 'Câu lạc bộ', 'CLB trong trường', Icons.groups, const Color(0xFF7C3AED), () => const ClbScreen()),
        ]),
        _HomeGroup('Hành chính', [
          _HomeItem('DonTu', 'Duyệt đơn từ', 'Đơn xin nghỉ của lớp', Icons.fact_check, AppColors.primary, () => const DuyetDonScreen()),
        ]),
      ];
    }
    final whose = session.isParent ? 'của con' : 'của bạn';
    return [
      _HomeGroup('Học tập', [
        _HomeItem('ListDiemHK', 'Điểm học kỳ', 'Kết quả học tập $whose', Icons.assessment, AppColors.info, () => const DiemScreen()),
        _HomeItem('LichHoc', 'Lịch học', 'Thời khóa biểu theo tuần', Icons.calendar_month, AppColors.success, () => const LichHocScreen()),
      ]),
      _HomeGroup('Hoạt động', [
        _HomeItem('SuKien', 'Sự kiện', 'Hoạt động toàn trường', Icons.event, AppColors.warning, () => const SuKienScreen()),
        _HomeItem('CLB', 'Câu lạc bộ', 'CLB trong trường', Icons.groups, const Color(0xFF7C3AED), () => const ClbScreen()),
      ]),
      _HomeGroup('Hành chính', [
        _HomeItem('DonTu', 'Đơn từ', 'Xin nghỉ & theo dõi duyệt', Icons.description, AppColors.primary, () => const DonTuScreen()),
      ]),
    ];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My F-School', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 22)),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThongBaoScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Hồ sơ cá nhân',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) => setState(() {})), // Refresh if parent picked another child
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: _groups.expand((group) => [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Text(group.title.toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.inkLight, letterSpacing: 1.2)),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.1,
            children: group.items.map((it) => _tile(context, it)).toList(),
          ),
          const SizedBox(height: 16),
        ]).toList(),
      ),
    );
  }

  Widget _tile(BuildContext context, _HomeItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.builder()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Nền thẻ trắng tinh
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.0), // Viền nhạt
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04), // Đổ bóng rất nhẹ
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12), // Màu nền trả lại cho icon
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              item.label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: AppColors.ink.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeGroup {
  final String title;
  final List<_HomeItem> items;
  _HomeGroup(this.title, this.items);
}

class _HomeItem {
  final String code;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() builder;
  _HomeItem(this.code, this.label, this.subtitle, this.icon, this.color, this.builder);
}
