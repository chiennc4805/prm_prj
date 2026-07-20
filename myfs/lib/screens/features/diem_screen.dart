import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/grade.dart';
import '../../services/grade_service.dart';
import '../../services/session.dart';
import '../../models/student.dart';
import '../../widgets/ui_helpers.dart';

class DiemScreen extends StatefulWidget {
  final Student? student;
  const DiemScreen({super.key, this.student});

  @override
  State<DiemScreen> createState() => _DiemScreenState();
}

class _DiemScreenState extends State<DiemScreen> with TickerProviderStateMixin {
  late Future<List<Grade>> _future;
  late final Student? _student;

  late TabController _tabController;
  List<String> _tabs = [];
  Map<String, Map<String, Grade>> _gradesByTabAndSubject = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student ?? Session.instance.currentStudent;
    _tabController = TabController(length: 0, vsync: this);
    _future = _load();
  }

  Future<List<Grade>> _load() async {
    if (_student == null) return [];
    final list = await GradeService.byStudent(_student.id);

    final sorted = [...list]
      ..sort((a, b) {
        final year = a.academicYear.compareTo(b.academicYear);
        return year != 0 ? year : a.semester.compareTo(b.semester);
      });
    final newMap = <String, Map<String, Grade>>{};
    for (final grade in sorted) {
      final tab = '${grade.academicYear} • ${grade.semester}';
      newMap.putIfAbsent(tab, () => <String, Grade>{})[grade.subject] = grade;
    }
    final newTabs = newMap.keys.toList();
    if (mounted) {
      setState(() {
        _tabController.dispose();
        _tabs = newTabs;
        _gradesByTabAndSubject = newMap;
        _tabController = TabController(
          length: _tabs.length,
          vsync: this,
          initialIndex: _tabs.isEmpty ? 0 : _tabs.length - 1,
        );
        _initialized = _tabs.isNotEmpty;
      });
    }

    return list;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _showGradeDetail(Grade? g, String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GradeDetailScreen(grade: g, subject: subject),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = Session.instance.isParent && _student != null
        ? 'Bảng điểm • ${_student.fullName}'
        : 'Bảng điểm';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: _initialized
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.primary,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    unselectedLabelColor: Colors.grey.shade600,
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox(),
              ),
      ),
      body: _student == null
          ? const EmptyView(
              icon: Icons.person_off_outlined,
              message: 'Không xác định được học sinh.',
            )
          : FutureBuilder<List<Grade>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const LoadingView();
                if (snap.hasError)
                  return ErrorView(
                    message: snap.error.toString(),
                    onRetry: _reload,
                  );
                if (_tabs.isEmpty)
                  return const EmptyView(
                    icon: Icons.assessment_outlined,
                    message: 'Chưa có dữ liệu điểm trong hệ thống.',
                  );

                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tabName) {
                    final gradesMap = _gradesByTabAndSubject[tabName] ?? {};
                    return _buildSubjectList(gradesMap);
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _buildSubjectList(Map<String, Grade> gradesMap) {
    final validGrades = gradesMap.values
        .where((g) => g.averageScore != null)
        .toList();
    final allCompleted =
        gradesMap.isNotEmpty && validGrades.length == gradesMap.length;
    final gpa = allCompleted
        ? validGrades.map((g) => g.averageScore!).reduce((a, b) => a + b) /
              validGrades.length
        : null;

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (gradesMap.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ĐIỂM TRUNG BÌNH HỌC KỲ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allCompleted ? gpa!.toStringAsFixed(1) : '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'CHI TIẾT MÔN HỌC',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          ...gradesMap.entries.map((entry) {
            final subject = entry.key;
            final g = entry.value;
            final isCompleted = g.averageScore != null;
            final accent = _subjectColor(subject);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _showGradeDetail(g, subject),
                leading: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: accent, size: 21),
                ),
                title: Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'GV: ${g.teacherName}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? accent.withValues(alpha: .1)
                            : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isCompleted ? g.averageScore!.toStringAsFixed(1) : '--',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isCompleted ? accent : AppColors.inkLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkLight,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _subjectColor(String subject) {
    const colors = [
      AppColors.info,
      AppColors.success,
      Color(0xFF7C3AED),
      AppColors.primary,
      Color(0xFF0891B2),
      Color(0xFFDB2777),
    ];
    return colors[subject.hashCode.abs() % colors.length];
  }
}

class _GradeDetailScreen extends StatelessWidget {
  final Grade? grade;
  final String subject;
  const _GradeDetailScreen({required this.grade, required this.subject});

  @override
  Widget build(BuildContext context) {
    final g = grade;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết điểm')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .22),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            g == null
                                ? 'Chưa có dữ liệu điểm'
                                : '${g.semester} • ${g.academicYear}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .72),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        g?.gradeLetter.isNotEmpty == true
                            ? g!.gradeLetter
                            : '—',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: .18),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ĐIỂM TỔNG KẾT',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .7),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kết quả hiện tại',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      g?.averageScore?.toStringAsFixed(1) ?? '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        height: .9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'THÀNH PHẦN ĐIỂM',
            style: TextStyle(
              color: AppColors.inkLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 11),
          if (g?.items.isEmpty ?? true)
            _scoreCard(
              Icons.hourglass_empty_rounded,
              'Chưa có đầu điểm',
              '—',
              AppColors.inkLight,
            )
          else
            ...g!.items.asMap().entries.expand(
              (entry) => [
                _scoreCard(
                  Icons.fact_check_outlined,
                  entry.value.name,
                  entry.value.score.toStringAsFixed(1),
                  _itemColor(entry.key),
                  note:
                      'Trọng số ${entry.value.weight.toStringAsFixed(entry.value.weight % 1 == 0 ? 0 : 1)}',
                ),
                const SizedBox(height: 11),
              ],
            ),
          const SizedBox(height: 24),
          const Text(
            'THÔNG TIN MÔN HỌC',
            style: TextStyle(
              color: AppColors.inkLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 11),
          Card(
            child: Column(
              children: [
                _infoRow(
                  Icons.person_outline_rounded,
                  'Giáo viên',
                  g?.teacherName ?? 'Chưa cập nhật',
                ),
                const Divider(indent: 56),
                _infoRow(
                  Icons.school_outlined,
                  'Học sinh',
                  g?.studentName ?? 'Chưa cập nhật',
                ),
                const Divider(indent: 56),
                _infoRow(
                  Icons.badge_outlined,
                  'Mã học sinh',
                  g?.studentCode ?? '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(
    IconData icon,
    String label,
    String value,
    Color color, {
    String? note,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: value == 'Chưa có' ? AppColors.inkLight : color,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Color _itemColor(int index) => const [
    AppColors.primary,
    AppColors.info,
    AppColors.success,
    Color(0xFF7C3AED),
  ][index % 4];

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 21),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.inkLight),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    ),
  );
}
