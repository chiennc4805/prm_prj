// ============================================================
// duyet_don_screen.dart – (GV) Duyệt đơn xin nghỉ của lớp chủ nhiệm.
// Lọc theo trạng thái; đơn PENDING có nút Duyệt / Từ chối.
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/leave_request.dart';
import '../../services/leave_service.dart';
import '../../services/session.dart';
import '../../widgets/ui_helpers.dart';

class DuyetDonScreen extends StatefulWidget {
  const DuyetDonScreen({super.key});

  @override
  State<DuyetDonScreen> createState() => _DuyetDonScreenState();
}

class _DuyetDonScreenState extends State<DuyetDonScreen> {
  final _classId = Session.instance.classId;
  late Future<List<LeaveRequest>> _future;
  String _filter = 'ALL'; // ALL | PENDING_TEACHER | APPROVED | REJECTED

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LeaveRequest>> _load() {
    if (_classId == null) return Future.value(<LeaveRequest>[]);
    return LeaveService.byClass(_classId);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _review(LeaveRequest r, String status) async {
    final approve = status == 'APPROVED';
    final ok = await AppDialogs.showConfirm(
      context: context,
      title: approve ? 'Duyệt đơn' : 'Từ chối đơn',
      content:
          '${approve ? 'Duyệt' : 'Từ chối'} đơn xin nghỉ của ${r.studentName} '
          '(${r.fromDate == r.toDate ? r.fromDate : '${r.fromDate} → ${r.toDate}'})?',
      confirmText: approve ? 'Duyệt' : 'Từ chối',
      isDanger: !approve,
    );
    if (!ok) return;

    try {
      final reviewerId = Session.instance.user!.id;
      await LeaveService.updateStatus(r.id!, status, reviewerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Đã duyệt đơn.' : 'Đã từ chối đơn.'),
            backgroundColor: approve ? AppColors.success : AppColors.danger,
          ),
        );
        _reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final className = Session.instance.homeroomClass?.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          className.isEmpty ? 'Duyệt đơn từ' : 'Duyệt đơn từ • $className',
        ),
      ),
      body: _classId == null
          ? const EmptyView(
              icon: Icons.meeting_room_outlined,
              message: 'Bạn chưa được phân công lớp chủ nhiệm.',
            )
          : Column(
              children: [
                // ── Bộ lọc trạng thái ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('ALL', 'Tất cả'),
                        _filterChip('PENDING_TEACHER', 'Chờ duyệt'),
                        _filterChip('APPROVED', 'Đã duyệt'),
                        _filterChip('REJECTED', 'Từ chối'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<LeaveRequest>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const LoadingView();
                      }
                      if (snap.hasError) {
                        return ErrorView(
                          message: snap.error.toString(),
                          onRetry: _reload,
                        );
                      }
                      var list = snap.data ?? [];
                      if (_filter != 'ALL') {
                        list = list.where((r) => r.status == _filter).toList();
                      }
                      if (list.isEmpty) {
                        return EmptyView(
                          icon: Icons.inbox_outlined,
                          message: _filter == 'PENDING_TEACHER'
                              ? 'Không có đơn chờ duyệt.'
                              : 'Không có đơn từ nào.',
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _reload(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _leaveCard(list[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.5),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _leaveCard(LeaveRequest r) {
    final pending = r.status == 'PENDING_TEACHER';

    Color typeColor;
    String typeLabel;
    IconData typeIcon;
    switch (r.leaveType) {
      case 'LATE':
        typeColor = AppColors.warning;
        typeLabel = 'Xin đi muộn';
        typeIcon = Icons.schedule;
        break;
      case 'EARLY':
        typeColor = Colors.purple;
        typeLabel = 'Xin về sớm';
        typeIcon = Icons.directions_run;
        break;
      case 'OTHER':
        typeColor = Colors.blueGrey;
        typeLabel = 'Đơn khác';
        typeIcon = Icons.feed_outlined;
        break;
      case 'ABSENT':
      default:
        typeColor = AppColors.danger;
        typeLabel = 'Xin nghỉ học';
        typeIcon = Icons.event_busy;
        break;
    }

    String timeText = '';
    if (r.leaveType == 'ABSENT') {
      timeText = r.fromDate == r.toDate
          ? 'Ngày ${r.fromDate}'
          : 'Từ ${r.fromDate} đến ${r.toDate}';
    } else if (r.leaveType == 'LATE' || r.leaveType == 'EARLY') {
      timeText = 'Ngày ${r.fromDate} • ${r.timeValue ?? ''}';
    } else {
      timeText = 'Ngày tạo: ${r.fromDate}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceTint,
                  child: Text(
                    r.studentName.characters.first,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Mã: ${r.studentCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                LeaveStatusChip(r.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(typeIcon, size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r.leaveType == 'OTHER' ? (r.title ?? 'Đơn từ khác') : timeText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.ink,
              ),
            ),
            if (r.leaveType == 'OTHER') ...[
              const SizedBox(height: 4),
              Text(
                timeText,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 6),
            Text('Lý do: ${r.reason}', style: const TextStyle(fontSize: 14)),
            if (pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _review(r, 'REJECTED'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _review(r, 'APPROVED'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Duyệt'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
