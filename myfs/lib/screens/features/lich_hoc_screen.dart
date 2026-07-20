// ============================================================
// lich_hoc_screen.dart – LichHoc: thời khóa biểu của lớp.
// classId lấy từ Session (chia sẻ giữa các màn).
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/session.dart';
import '../../widgets/ui_helpers.dart';

class LichHocScreen extends StatefulWidget {
  const LichHocScreen({super.key});

  @override
  State<LichHocScreen> createState() => _LichHocScreenState();
}

class _LichHocScreenState extends State<LichHocScreen> {
  late Future<List<Schedule>> _future;
  final _classId = Session.instance.classId;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Schedule>> _load() {
    if (_classId == null) return Future.value(<Schedule>[]);
    return ScheduleService.byClass(_classId);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // GV: "Lịch dạy" của lớp CN; SV/PH: "Lịch học"
    final session = Session.instance;
    final base = session.isTeacher ? 'Lịch dạy' : 'Lịch học';
    return Scaffold(
      appBar: AppBar(title: Text(base)),
      body: FutureBuilder<List<Schedule>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snap.hasError) {
            return ErrorView(message: snap.error.toString(), onRetry: _reload);
          }
          var list = snap.data ?? [];
          
          // Nếu là giáo viên, chỉ hiển thị các tiết do mình dạy
          if (session.isTeacher && session.user?.fullName != null) {
            list = list.where((s) => s.teacherName == session.user!.fullName).toList();
          }

          if (list.isEmpty) {
            return EmptyView(
                icon: Icons.calendar_month_outlined,
                message: session.isTeacher 
                    ? 'Không có tiết dạy nào được phân công.' 
                    : 'Chưa có thời khóa biểu.');
          }

          // Nhóm theo thứ (dayOrder)
          final Map<int, List<Schedule>> byDay = {};
          for (final s in list) {
            byDay.putIfAbsent(s.dayOrder, () => []).add(s);
          }
          // Luôn hiển thị từ Thứ 2 (2) đến Chủ nhật (8)
          final days = [2, 3, 4, 5, 6, 7, 8];
          
          int displayDay = _selectedDay ?? 2;

          final periods = byDay[displayDay] ?? [];

          return Column(
            children: [
              // Thanh trượt ngang các ngày
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: days.map((d) {
                      final isSelected = d == displayDay;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedDay = d),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceTint.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              Schedule.dayLabel(d),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Danh sách tiết học của ngày đã chọn
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _reload(),
                  color: AppColors.primary,
                  child: periods.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(top: 100),
                          children: const [
                            EmptyView(
                              icon: Icons.weekend_outlined,
                              message: 'Không có lịch học ngày hôm nay.\nHãy thư giãn và nạp lại năng lượng nhé!',
                            )
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: periods.length,
                          itemBuilder: (context, i) => _periodTile(periods[i]),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _periodTile(Schedule s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cột trái: Thời gian
            SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (s.startTime != null)
                    Text(s.startTime!, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryDark)),
                  if (s.endTime != null) ...[
                    const SizedBox(height: 4),
                    Text(s.endTime!, 
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                  ]
                ],
              ),
            ),
            
            // Đường kẻ dọc
            Container(
              width: 1,
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.grey.shade300,
            ),
            
            // Cột phải: Tag tiết, Môn học, Phòng, GV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Tiết ${s.period}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.subject, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  if (s.room != null)
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Phòng: ${s.room}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5)),
                      ],
                    ),
                  if (s.room != null && s.teacherName != null) const SizedBox(height: 4),
                  if (s.teacherName != null)
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('GV: ${s.teacherName}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
