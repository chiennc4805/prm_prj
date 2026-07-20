// ============================================================
// thong_bao_screen.dart – Thông báo / hộp thư.
//   - SV / PH : nhận thông báo của lớp + toàn trường.
//   - GV      : xem tất cả, gửi thông báo mới (lớp CN / toàn trường).
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../services/session.dart';
import '../../widgets/ui_helpers.dart';
import 'thong_bao_detail_screen.dart';

class ThongBaoScreen extends StatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  final session = Session.instance;
  late Future<List<NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<NotificationItem>> _load() {
    if (session.isTeacher) return NotificationService.all();
    final classId = session.classId;
    if (classId == null) return Future.value(<NotificationItem>[]);
    return NotificationService.forClass(classId);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openCompose() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ComposeSheet(),
    );
    if (sent == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      floatingActionButton: session.isTeacher
          ? FloatingActionButton.extended(
              onPressed: _openCompose,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.send),
              label: const Text('Gửi thông báo'),
            )
          : null,
      body: FutureBuilder<List<NotificationItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snap.hasError) {
            return ErrorView(message: snap.error.toString(), onRetry: _reload);
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const EmptyView(
                icon: Icons.notifications_none, message: 'Chưa có thông báo nào.');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: list.length,
              itemBuilder: (context, i) => _notiCard(list[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _notiCard(NotificationItem n) {
    final scopeColor = n.isSchoolWide ? AppColors.info : AppColors.success;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThongBaoDetailScreen(notification: n),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scopeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: scopeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(n.createdAtLabel,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── (GV) Form gửi thông báo ───────────────────────────────────────────
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet();

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _schoolWide = false; // false = gửi lớp chủ nhiệm
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final session = Session.instance;
    final homeroom = session.homeroomClass;

    if (!_schoolWide && homeroom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bạn chưa có lớp chủ nhiệm — chỉ gửi được toàn trường.')));
      return;
    }

    setState(() => _sending = true);
    final noti = NotificationItem(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      senderId: session.user?.id,
      senderName: session.user?.fullName,
      classId: _schoolWide ? null : homeroom!.id,
      className: _schoolWide ? null : homeroom!.name,
    );

    try {
      await NotificationService.send(noti);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeroom = Session.instance.homeroomClass;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Gửi thông báo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Phạm vi gửi
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text('Lớp ${homeroom?.name ?? 'CN'}'),
                    icon: const Icon(Icons.class_outlined),
                  ),
                  const ButtonSegment(
                    value: true,
                    label: Text('Toàn trường'),
                    icon: Icon(Icons.campaign_outlined),
                  ),
                ],
                selected: {_schoolWide},
                onSelectionChanged: (s) =>
                    setState(() => _schoolWide = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'VD: Họp phụ huynh cuối kỳ',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập nội dung.' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_sending ? 'Đang gửi...' : 'Gửi thông báo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
