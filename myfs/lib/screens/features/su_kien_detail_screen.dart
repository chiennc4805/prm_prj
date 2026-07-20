import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/event.dart';

class SuKienDetailScreen extends StatelessWidget {
  final Event event;

  const SuKienDetailScreen({super.key, required this.event});

  void _onJoinPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text(
            'Tính năng đăng ký tham gia sự kiện đang được phát triển.\n\nVui lòng theo dõi thêm thông báo từ nhà trường!'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Sự kiện'),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ô LỚN SỐ 1: Tiêu đề & Thông tin cơ bản
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink, height: 1.3),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildInfoRow(Icons.calendar_month, 'Ngày tổ chức', event.eventDate),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.schedule, 'Thời gian bắt đầu', event.eventTime ?? 'Chưa xác định'),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.location_on_outlined, 'Địa điểm', event.location ?? 'Đang cập nhật'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Ô LỚN SỐ 2: Nội dung chi tiết (description)
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nội dung chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 12),
                  Text(
                    event.description ?? 'Chưa có thông tin mô tả chi tiết cho sự kiện này.',
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _onJoinPressed(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('ĐĂNG KÝ THAM GIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink)),
            ],
          ),
        ),
      ],
    );
  }
}
