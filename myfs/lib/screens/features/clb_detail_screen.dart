import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/club.dart';
import '../../services/session.dart';

class ClbDetailScreen extends StatelessWidget {
  final Club club;

  const ClbDetailScreen({super.key, required this.club});

  Color _catColor(String? cat) {
    switch (cat) {
      case 'Học thuật':
        return AppColors.info;
      case 'Thể thao':
        return AppColors.success;
      case 'Nghệ thuật':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primary;
    }
  }

  void _onJoinPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text(
          'Tính năng đăng ký trực tiếp đang được phát triển.\n\nVui lòng truy cập website của trường để đăng ký tham gia:\n\nhttp://myfschool.edu.vn',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(club.category);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Câu lạc bộ')),
      backgroundColor:
          Colors.grey.shade50, // Thêm nền xám nhạt để khối trắng nổi bật
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ô LỚN SỐ 1: Thông tin chung & Giới thiệu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                      height: 1.3,
                    ),
                  ),
                  if (club.category != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        club.category!,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Text(
                    club.description ?? 'Đang cập nhật mô tả.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ô LỚN SỐ 2: Thông tin chi tiết
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.schedule,
                    'Lịch sinh hoạt',
                    club.meetingTime ?? 'Đang cập nhật',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Địa điểm',
                    club.location ?? 'Đang cập nhật',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Liên hệ',
                    club.contact ?? 'Đang cập nhật',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildInfoRow(
                    Icons.people_alt_outlined,
                    'Thành viên',
                    '${club.memberCount} người',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Session.instance.isStudent
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => _onJoinPressed(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'ĐĂNG KÝ THAM GIA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Căn giữa icon với nội dung 2 dòng text
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ), // Tăng size lên xíu nhìn sẽ đẹp hơn khi căn giữa
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
