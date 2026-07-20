import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/notification_item.dart';

class ThongBaoDetailScreen extends StatelessWidget {
  final NotificationItem notification;

  const ThongBaoDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final scopeColor = notification.isSchoolWide ? AppColors.info : AppColors.success;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Thông báo'),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ô LỚN SỐ 1: Meta (Tiêu đề, Người gửi, Thời gian)
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
                    notification.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: scopeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(notification.isSchoolWide ? Icons.campaign_outlined : Icons.class_outlined, size: 16, color: scopeColor),
                            const SizedBox(width: 6),
                            Text(
                              notification.isSchoolWide ? 'Toàn trường' : 'Lớp ${notification.className ?? ''}',
                              style: TextStyle(color: scopeColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _buildInfoRow(Icons.person_outline, 'Người gửi', notification.senderName ?? 'Hệ thống'),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.access_time, 'Thời gian', notification.createdAtLabel),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Ô LỚN SỐ 2: Nội dung
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
                  const Text('Nội dung', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 12),
                  Text(
                    notification.content,
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$title: ', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
