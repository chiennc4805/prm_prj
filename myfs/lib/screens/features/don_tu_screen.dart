// ============================================================
// don_tu_screen.dart – DonTu: tạo & theo dõi đơn xin nghỉ.
// Học sinh lấy từ Session (chia sẻ giữa các màn).
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/leave_request.dart';
import '../../models/student.dart';
import '../../services/leave_service.dart';
import '../../services/session.dart';
import '../../widgets/ui_helpers.dart';

class DonTuScreen extends StatefulWidget {
  const DonTuScreen({super.key});

  @override
  State<DonTuScreen> createState() => _DonTuScreenState();
}

class _DonTuScreenState extends State<DonTuScreen> {
  final _student = Session.instance.currentStudent;
  late Future<List<LeaveRequest>> _future;
  String _statusFilter = 'ALL';
  String _typeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LeaveRequest>> _load() {
    if (_student == null) return Future.value(<LeaveRequest>[]);
    return LeaveService.byStudent(_student.id);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _review(LeaveRequest r, String actionStatus) async {
    final approve = actionStatus != 'REJECTED';
    final ok = await AppDialogs.showConfirm(
      context: context,
      title: approve ? 'Duyệt đơn' : 'Từ chối đơn',
      content: '${approve ? 'Đồng ý' : 'Từ chối'} đơn ${r.leaveType == 'OTHER' ? (r.title ?? 'này') : 'xin nghỉ'} của ${r.studentName}?',
      confirmText: approve ? 'Duyệt' : 'Từ chối',
      isDanger: !approve,
    );
    if (!ok) return;

    try {
      final reviewerId = Session.instance.user!.id;
      String nextStatus = actionStatus;
      if (approve) {
         nextStatus = (r.leaveType == 'OTHER') ? 'PENDING_SCHOOL' : 'PENDING_TEACHER';
      }
      
      await LeaveService.updateStatus(r.id!, nextStatus, reviewerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(approve ? 'Đã duyệt đơn.' : 'Đã từ chối đơn.'),
          backgroundColor: approve ? AppColors.success : AppColors.danger,
        ));
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

  Future<void> _openForm() async {
    if (_student == null) return;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _DonTuFormPage(student: _student)),
    );
    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    // PH tạo đơn cho con → hiện tên con trên AppBar cho rõ ngữ cảnh
    final title = Session.instance.isParent && _student != null
        ? 'Đơn từ • ${_student.fullName}'
        : 'Đơn từ';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Lọc theo loại đơn',
            icon: Icon(
              _typeFilter == 'ALL' ? Icons.filter_alt_outlined : Icons.filter_alt,
              color: Colors.white,
            ),
            onSelected: (val) => setState(() => _typeFilter = val),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'ALL',
                child: Text('Tất cả loại đơn',
                    style: TextStyle(
                        fontWeight: _typeFilter == 'ALL' ? FontWeight.bold : FontWeight.normal,
                        color: _typeFilter == 'ALL' ? AppColors.primary : null)),
              ),
              PopupMenuItem(
                value: 'ABSENT',
                child: Text('Xin nghỉ học',
                    style: TextStyle(
                        fontWeight: _typeFilter == 'ABSENT' ? FontWeight.bold : FontWeight.normal,
                        color: _typeFilter == 'ABSENT' ? AppColors.primary : null)),
              ),
              PopupMenuItem(
                value: 'LATE',
                child: Text('Xin đi muộn',
                    style: TextStyle(
                        fontWeight: _typeFilter == 'LATE' ? FontWeight.bold : FontWeight.normal,
                        color: _typeFilter == 'LATE' ? AppColors.primary : null)),
              ),
              PopupMenuItem(
                value: 'EARLY',
                child: Text('Xin về sớm',
                    style: TextStyle(
                        fontWeight: _typeFilter == 'EARLY' ? FontWeight.bold : FontWeight.normal,
                        color: _typeFilter == 'EARLY' ? AppColors.primary : null)),
              ),
              PopupMenuItem(
                value: 'OTHER',
                child: Text('Đơn khác',
                    style: TextStyle(
                        fontWeight: _typeFilter == 'OTHER' ? FontWeight.bold : FontWeight.normal,
                        color: _typeFilter == 'OTHER' ? AppColors.primary : null)),
              ),
            ],
          ),
        ],
      ),
      body: _student == null
          ? const EmptyView(
              icon: Icons.person_off_outlined,
              message: 'Không xác định được học sinh.')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusChip('ALL', 'Tất cả'),
                        _statusChip('PENDING', 'Đang chờ'),
                        _statusChip('APPROVED', 'Đã duyệt'),
                        _statusChip('REJECTED', 'Từ chối'),
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
                        return ErrorView(message: snap.error.toString(), onRetry: _reload);
                      }
                      var list = snap.data ?? [];
                      
                      // 1. Filter by Status
                      if (_statusFilter != 'ALL') {
                        if (_statusFilter == 'PENDING') {
                          list = list.where((r) => r.status.startsWith('PENDING')).toList();
                        } else {
                          list = list.where((r) => r.status == _statusFilter).toList();
                        }
                      }
                      
                      // 2. Filter by Type
                      if (_typeFilter != 'ALL') {
                        list = list.where((r) => r.leaveType == _typeFilter).toList();
                      }

                      if (list.isEmpty) {
                        return EmptyView(
                          icon: Icons.description_outlined,
                          message: 'Chưa có đơn từ nào.',
                          action: (_statusFilter == 'ALL' && _typeFilter == 'ALL')
                              ? FilledButton.icon(
                                  onPressed: _openForm,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tạo đơn xin nghỉ'),
                                )
                              : null,
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _reload(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _leaveCard(list[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _student == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('Tạo đơn'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
    );
  }

  Widget _statusChip(String value, String label) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = value),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.5),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
    );
  }

  Widget _leaveCard(LeaveRequest r) {
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
      timeText = r.fromDate == r.toDate ? 'Ngày ${r.fromDate}' : 'Từ ${r.fromDate} đến ${r.toDate}';
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(typeIcon, size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                LeaveStatusChip(r.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              r.leaveType == 'OTHER' ? (r.title ?? 'Đơn từ khác') : timeText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
            ),
            if (r.leaveType == 'OTHER') ...[
              const SizedBox(height: 4),
              Text(timeText, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            Text(
              r.reason,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (Session.instance.isParent && r.status == 'PENDING_PARENT') ...[
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

// ── Trang tạo đơn xin nghỉ ────────────────────────────────────────────
class _DonTuFormPage extends StatefulWidget {
  final Student student;
  const _DonTuFormPage({required this.student});

  @override
  State<_DonTuFormPage> createState() => _DonTuFormPageState();
}

class _DonTuFormPageState extends State<_DonTuFormPage> {
  final _reasonCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _saving = false;
  String _selectedType = 'ABSENT';

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
          if (_to.isBefore(_from)) _to = _from;
        } else {
          _to = picked;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung/lý do.')),
      );
      return;
    }
    if (_selectedType == 'OTHER' && _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề đơn.')),
      );
      return;
    }

    setState(() => _saving = true);
    final s = widget.student;
    
    String fDate = _fmt(_from);
    String tDate = _selectedType == 'ABSENT' ? _fmt(_to) : fDate;
    String? tValue = (_selectedType == 'LATE' || _selectedType == 'EARLY') ? _fmtTime(_time) : null;
    String? title = _selectedType == 'OTHER' ? _titleCtrl.text.trim() : null;

    String initialStatus = 'PENDING';
    if (Session.instance.isStudent) {
      initialStatus = 'PENDING_PARENT';
    } else if (Session.instance.isParent) {
      initialStatus = (_selectedType == 'OTHER') ? 'PENDING_SCHOOL' : 'PENDING_TEACHER';
    }

    final req = LeaveRequest(
      studentId: s.id,
      studentCode: s.studentCode,
      studentName: s.fullName,
      className: s.className,
      leaveType: _selectedType,
      title: title,
      fromDate: fDate,
      toDate: tDate,
      timeValue: tValue,
      reason: _reasonCtrl.text.trim(),
      status: initialStatus,
      createdById: Session.instance.user?.id,
    );
    try {
      await LeaveService.create(req);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo đơn từ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Học sinh: ${widget.student.fullName} (${widget.student.studentCode})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Loại đơn',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'ABSENT', child: Text('Xin nghỉ học')),
                DropdownMenuItem(value: 'LATE', child: Text('Xin đi muộn')),
                DropdownMenuItem(value: 'EARLY', child: Text('Xin về sớm')),
                DropdownMenuItem(value: 'OTHER', child: Text('Đơn khác')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 16),

            if (_selectedType == 'ABSENT') ...[
              Row(
                children: [
                  Expanded(child: _dateField('Từ ngày', _fmt(_from), () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _dateField('Đến ngày', _fmt(_to), () => _pickDate(false))),
                ],
              ),
            ] else if (_selectedType == 'LATE' || _selectedType == 'EARLY') ...[
              Row(
                children: [
                  Expanded(child: _dateField('Ngày áp dụng', _fmt(_from), () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _selectedType == 'LATE' ? 'Giờ có mặt' : 'Giờ xin về',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_fmtTime(_time), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedType == 'OTHER') ...[
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề đơn',
                  hintText: 'VD: Xin làm lại thẻ học sinh',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: _reasonCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _selectedType == 'OTHER' ? 'Nội dung chi tiết' : 'Lý do',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Gửi đơn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
