import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/grade.dart';
import '../../models/student.dart';
import '../../services/grade_service.dart';
import '../../services/student_service.dart';
import '../../services/session.dart';
import '../../widgets/ui_helpers.dart';
import '../features/diem_screen.dart';

class QuanLyDiemScreen extends StatefulWidget {
  const QuanLyDiemScreen({super.key});

  @override
  State<QuanLyDiemScreen> createState() => _QuanLyDiemScreenState();
}

class _QuanLyDiemScreenState extends State<QuanLyDiemScreen> {
  late Future<List<dynamic>> _futureAssignments;
  final String _teacherName = Session.instance.user?.fullName ?? '';

  @override
  void initState() {
    super.initState();
    _futureAssignments = GradeService.teacherAssignments(_teacherName);
  }

  void _reload() {
    setState(() {
      _futureAssignments = GradeService.teacherAssignments(_teacherName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lớp giảng dạy')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAssignments,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snap.hasError) {
            return ErrorView(message: snap.error.toString(), onRetry: _reload);
          }
          final assignments = snap.data ?? [];
          if (assignments.isEmpty) {
            return const EmptyView(
              icon: Icons.assignment_outlined,
              message: 'Bạn chưa được phân công giảng dạy lớp nào.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: assignments.length,
              itemBuilder: (context, i) {
                final item = assignments[i] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1.2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceTint,
                      radius: 24,
                      child: const Icon(
                        Icons.class_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      '${item['subject']} • ${item['className']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${item['semester']} | Năm học: ${item['academicYear']}',
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _TeacherClassStudentsScreen(
                            classId: item['classId'],
                            className: item['className'],
                            subject: item['subject'],
                            semester: item['semester'],
                            academicYear: item['academicYear'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TeacherClassStudentsScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;
  final String semester;
  final String academicYear;

  const _TeacherClassStudentsScreen({
    required this.classId,
    required this.className,
    required this.subject,
    required this.semester,
    required this.academicYear,
  });

  @override
  State<_TeacherClassStudentsScreen> createState() =>
      _TeacherClassStudentsScreenState();
}

class _TeacherClassStudentsScreenState
    extends State<_TeacherClassStudentsScreen> {
  late Future<List<dynamic>> _futureData;
  final String _teacherName = Session.instance.user?.fullName ?? '';

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    final students = await StudentService.byClass(widget.classId);
    final grades = await GradeService.teacherClassGrades(
      _teacherName,
      widget.classId,
      widget.subject,
      widget.semester,
    );
    return [students, grades];
  }

  void _reload() {
    setState(() {
      _futureData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject} • ${widget.className}')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureData,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const LoadingView();
          if (snap.hasError)
            return ErrorView(message: snap.error.toString(), onRetry: _reload);

          final students = snap.data![0] as List<Student>;
          final grades = snap.data![1] as List<Grade>;

          if (students.isEmpty) {
            return const EmptyView(
              icon: Icons.groups_outlined,
              message: 'Lớp học chưa có học sinh nào.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: students.length,
              itemBuilder: (context, i) {
                final s = students[i];
                // Find grade for this student
                final gradeList = grades
                    .where((g) => g.studentId == s.id)
                    .toList();
                final grade = gradeList.isNotEmpty ? gradeList.first : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1.2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          grade != null && grade.averageScore != null
                          ? AppColors.gradeBadge(grade.gradeLetter)
                          : Colors.grey.shade200,
                      child: Text(
                        grade != null && grade.averageScore != null
                            ? (grade.gradeLetter ?? '')
                            : '-',
                        style: TextStyle(
                          color: grade != null && grade.averageScore != null
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      s.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ĐTB: ${grade?.averageScore?.toStringAsFixed(1) ?? "Chưa có"}',
                      style: TextStyle(
                        color: grade?.averageScore != null
                            ? AppColors.primary
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => _GradeFormSheet(
                          student: s,
                          existing: grade,
                          subject: widget.subject,
                          semester: widget.semester,
                          academicYear: widget.academicYear,
                        ),
                      );
                      if (result == true) {
                        _reload();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Form nhập / sửa điểm (bottom sheet) ───────────────────────────────
class _GradeFormSheet extends StatefulWidget {
  final Student student;
  final Grade? existing;
  final String subject;
  final String semester;
  final String academicYear;

  const _GradeFormSheet({
    required this.student,
    this.existing,
    required this.subject,
    required this.semester,
    required this.academicYear,
  });

  @override
  State<_GradeFormSheet> createState() => _GradeFormSheetState();
}

class _GradeFormSheetState extends State<_GradeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regularCtrl;
  late final TextEditingController _midtermCtrl;
  late final TextEditingController _finalCtrl;
  bool _saving = false;

  bool get _isEdit => widget.existing != null && widget.existing!.id != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _regularCtrl = TextEditingController(text: g?.regularScores ?? '');
    _midtermCtrl = TextEditingController(
      text: g?.midtermScore?.toStringAsFixed(1) ?? '',
    );
    _finalCtrl = TextEditingController(
      text: g?.finalScore?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _regularCtrl.dispose();
    _midtermCtrl.dispose();
    _finalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final s = widget.student;
    final teacherName = Session.instance.user?.fullName ?? '';

    double? parseScore(String text) {
      final val = double.tryParse(text.trim());
      return val;
    }

    final grade = Grade(
      id: widget.existing?.id,
      studentId: s.id,
      studentCode: s.studentCode,
      studentName: s.fullName,
      subject: widget.subject,
      regularScores: _regularCtrl.text.trim(),
      midtermScore: parseScore(_midtermCtrl.text),
      finalScore: parseScore(_finalCtrl.text),
      gradeLetter: '', // server sẽ tính
      semester: widget.semester,
      academicYear: widget.academicYear,
      teacherName: widget.existing?.teacherName ?? teacherName,
    );

    try {
      if (_isEdit) {
        await GradeService.update(grade.id!, grade);
      } else {
        await GradeService.create(grade);
      }
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
    return Padding(
      // đẩy form lên trên bàn phím
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nhập điểm • ${widget.student.fullName}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _regularCtrl,
                decoration: const InputDecoration(
                  labelText: 'Điểm Thường xuyên',
                  hintText: 'Cách nhau dấu phẩy (VD: 8.5, 9.0)',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _midtermCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Điểm Giữa kỳ',
                        prefixIcon: Icon(Icons.looks_two_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _finalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Điểm Cuối kỳ',
                        prefixIcon: Icon(Icons.looks_3_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
