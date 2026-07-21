// ============================================================
// home_page.dart – Trang chủ sau khi đăng nhập (theo sơ đồ).
// HomePage → ListDiemHK · LichHoc · SuKien · DonTu · CLB
// Nội dung 5 mục thay đổi theo vai trò (SV / PH / GV):
//   - STUDENT : xem điểm, TKB, sự kiện, tạo đơn, CLB
//   - PARENT  : như SV nhưng theo con đang chọn (đổi được con)
//   - TEACHER : quản lý điểm, lịch dạy, sự kiện, xem đơn, CLB
// Dữ liệu người dùng / học sinh lấy từ Session (chia sẻ giữa các màn).
// ============================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/session.dart';
import 'features/diem_screen.dart';
import 'features/lich_hoc_screen.dart';
import 'features/su_kien_screen.dart';
import 'features/don_tu_screen.dart';
import 'features/clb_screen.dart';
import 'features/thong_bao_screen.dart';
import 'features/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final session = Session.instance;

  List<_HomeGroup> get _groups {
    final whose = session.isParent ? 'của con' : 'của bạn';
    return [
      _HomeGroup('Học tập', [
        _HomeItem(
          'ListDiemHK',
          'Điểm học kỳ',
          'Kết quả học tập $whose',
          Icons.assessment,
          AppColors.info,
          () => const DiemScreen(),
        ),
        _HomeItem(
          'LichHoc',
          'Lịch học',
          'Thời khóa biểu theo tuần',
          Icons.calendar_month,
          AppColors.success,
          () => const LichHocScreen(),
        ),
      ]),
      _HomeGroup('Hoạt động', [
        _HomeItem(
          'SuKien',
          'Sự kiện',
          'Hoạt động toàn trường',
          Icons.event,
          AppColors.warning,
          () => const SuKienScreen(),
        ),
        _HomeItem(
          'CLB',
          'Câu lạc bộ',
          'CLB trong trường',
          Icons.groups,
          const Color(0xFF7C3AED),
          () => const ClbScreen(),
        ),
      ]),
      if (session.isParent)
        _HomeGroup('Hành chính', [
          _HomeItem(
            'DonTu',
            'Đơn xin nghỉ học',
            'Gửi đơn cho giáo viên chủ nhiệm',
            Icons.description,
            AppColors.primary,
            () => const DonTuScreen(),
          ),
        ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FPT Schools',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
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
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ).then(
                  (_) => setState(() {}),
                ), // Refresh if parent picked another child
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _welcomeCard(),
          const SizedBox(height: 24),
          ..._groups.expand(
            (group) => [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Text(
                  group.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkLight,
                    letterSpacing: 1.2,
                  ),
                ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    final user = session.user;
    final student = session.currentStudent;
    final detail = session.isTeacher
        ? 'Không gian làm việc dành cho giáo viên'
        : student == null
        ? 'Theo dõi thông tin học tập mỗi ngày'
        : '${student.className ?? 'Chưa xếp lớp'}  •  ${student.studentCode}';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: .16)),
            ),
            child: Text(
              user?.fullName.isNotEmpty == true
                  ? user!.fullName[0].toUpperCase()
                  : 'F',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${user?.fullName ?? 'bạn'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white, // Nền thẻ trắng tinh
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.0), // Viền nhạt
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04), // Đổ bóng rất nhẹ
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(
                  alpha: 0.12,
                ), // Màu nền trả lại cho icon
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 25),
            ),
            const Spacer(),
            Text(
              item.label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: AppColors.ink.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.inkLight,
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
  _HomeItem(
    this.code,
    this.label,
    this.subtitle,
    this.icon,
    this.color,
    this.builder,
  );
}
