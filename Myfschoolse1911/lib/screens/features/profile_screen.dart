import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/student.dart';
import '../../services/session.dart';
import '../../services/auth_service.dart';
import '../../widgets/ui_helpers.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final session = Session.instance;

  String get _roleLabel {
    if (session.isTeacher) return 'Giáo viên chủ nhiệm';
    if (session.isParent) return 'Phụ huynh';
    return 'Học sinh';
  }

  IconData get _roleIcon {
    if (session.isTeacher) return Icons.co_present;
    if (session.isParent) return Icons.family_restroom;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildProfileAvatarAndName(),
          const SizedBox(height: 32),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildLogoutBlock(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatarAndName() {
    final user = session.user;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(_roleIcon, color: AppColors.primary, size: 48),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _roleLabel.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.fullName ?? 'Người dùng',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (user != null && user.roles.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FilledButton.icon(
              onPressed: _switchRole,
              icon: const Icon(Icons.autorenew, size: 20),
              label: Text(
                session.isTeacher ? 'Đổi sang Phụ huynh' : 'Đổi sang Giáo viên',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _switchRole() {
    setState(() {
      session.currentRole = session.isTeacher ? 'PARENT' : 'TEACHER';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chuyển sang góc nhìn ${session.isTeacher ? 'Giáo viên' : 'Phụ huynh'}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    // Về trang chủ để refresh lại giao diện
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildInfoCard() {
    final student = session.currentStudent;
    List<Widget> tiles = [];

    // 1. Nếu là phụ huynh, hiển thị tên con đang theo dõi đầu tiên
    if (session.isParent && student != null) {
      tiles.add(
        _buildInfoTile(
          Icons.person_outline,
          'Học sinh đang theo dõi',
          student.fullName,
        ),
      );
      tiles.add(const Divider(height: 1, color: AppColors.border, indent: 70));
    }

    // 2. Mã học sinh (Không áp dụng cho giáo viên)
    if (!session.isTeacher && student != null) {
      tiles.add(
        _buildInfoTile(
          Icons.badge_outlined,
          'Mã học sinh',
          student.studentCode,
        ),
      );
      tiles.add(const Divider(height: 1, color: AppColors.border, indent: 70));
    }

    // 3. Lớp
    if (session.isTeacher) {
      final c = session.homeroomClass;
      final classStr = c != null
          ? '${c.name} (NH ${c.academicYear})'
          : 'Chưa phân công';
      tiles.add(
        _buildInfoTile(Icons.meeting_room_outlined, 'Chủ nhiệm lớp', classStr),
      );
    } else if (student != null) {
      tiles.add(
        _buildInfoTile(
          Icons.meeting_room_outlined,
          'Lớp',
          student.className ?? '-',
        ),
      );
    }

    if (tiles.isNotEmpty) {
      tiles.add(const Divider(height: 1, color: AppColors.border, indent: 70));
    }

    // 3. Số điện thoại
    tiles.add(
      _buildInfoTile(
        Icons.phone_android_outlined,
        'Số điện thoại',
        session.user?.phone ?? '',
      ),
    );

    // Chuyển đổi con (dành cho Phụ huynh)
    if (session.isParent && session.children.length > 1) {
      tiles.add(const Divider(height: 1, color: AppColors.border, indent: 70));
      tiles.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: _buildTileIcon(Icons.swap_horiz, AppColors.info),
          title: const Text(
            'Chọn hồ sơ con khác',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.inkLight),
          onTap: _pickChild,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: _buildTileIcon(icon, AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.inkLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTileIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildLogoutBlock() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _buildTileIcon(Icons.logout, AppColors.danger),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  Future<void> _pickChild() async {
    final picked = await showModalBottomSheet<Student>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chọn con đang theo dõi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final c in session.children)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.surfaceTint,
                  child: Text(
                    c.fullName.characters.first,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  c.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Mã: ${c.studentCode} • Lớp ${c.className ?? '-'}',
                ),
                trailing: c.id == session.currentStudent?.id
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => session.selectChild(picked));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await AppDialogs.showConfirm(
      context: context,
      title: 'Đăng xuất',
      content: 'Bạn có chắc chắn muốn đăng xuất?',
      confirmText: 'Đăng xuất',
      isDanger: true,
    );
    if (!ok) return;
    AuthService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
