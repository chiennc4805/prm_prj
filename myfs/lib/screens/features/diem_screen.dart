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

  static const List<String> ALL_SUBJECTS = [
    'Toán', 'Văn', 'Anh', 'Vật lý', 'Hóa', 'Sinh',
    'Lịch sử', 'Địa lý', 'GDCD', 'Tin học', 'Công nghệ', 'Thể dục'
  ];

  late TabController _tabController;
  List<String> _tabs = [];
  Map<String, Map<String, Grade>> _gradesByTabAndSubject = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student ?? Session.instance.currentStudent;
    
    // Init tabs synchronously so TabBar is visible immediately
    int currentGrade = 10;
    if (_student?.className?.startsWith('11') == true) currentGrade = 11;
    if (_student?.className?.startsWith('12') == true) currentGrade = 12;

    _tabs = [];
    for (int g = 10; g <= currentGrade; g++) {
      _tabs.add('Lớp $g HK1');
      _tabs.add('Lớp $g HK2');
    }

    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _tabs.length - 1);
    _initialized = true;

    _gradesByTabAndSubject = { for (var t in _tabs) t: {} };
    _future = _load();
  }

  Future<List<Grade>> _load() async {
    if (_student == null) return [];
    final list = await GradeService.byStudent(_student!.id);

    int currentGrade = 10;
    if (_student!.className?.startsWith('11') == true) currentGrade = 11;
    if (_student!.className?.startsWith('12') == true) currentGrade = 12;

    var newMap = { for (var t in _tabs) t: <String, Grade>{} };

    for (var g in list) {
      String targetTab = 'Lớp $currentGrade ${g.semester}';
      if (newMap.containsKey(targetTab)) {
        String subjectKey = ALL_SUBJECTS.firstWhere(
            (s) => g.subject.toLowerCase().contains(s.toLowerCase()), 
            orElse: () => g.subject);
        newMap[targetTab]![subjectKey] = g;
      }
    }

    setState(() {
      _gradesByTabAndSubject = newMap;
    });

    return list;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _showGradeDetail(Grade? g, String subject) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  radius: 24,
                  child: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Môn $subject', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('GV: ${g?.teacherName ?? 'Chưa cập nhật'}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildComponentRow('Điểm thường xuyên', g?.regularScores ?? 'Chưa có'),
            const Divider(),
            _buildComponentRow('Điểm giữa kỳ (Hệ số 2)', g?.midtermScore?.toString() ?? 'Chưa có'),
            const Divider(),
            _buildComponentRow('Điểm cuối kỳ (Hệ số 3)', g?.finalScore?.toString() ?? 'Chưa có'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng kết môn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  Text(g?.averageScore?.toStringAsFixed(1) ?? '--', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = Session.instance.isParent && _student != null
        ? 'Bảng điểm • ${_student!.fullName}'
        : 'Bảng điểm';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: _initialized ? PreferredSize(
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelColor: Colors.grey.shade600,
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ) : const PreferredSize(preferredSize: Size.fromHeight(0), child: SizedBox()),
      ),
      body: _student == null
          ? const EmptyView(icon: Icons.person_off_outlined, message: 'Không xác định được học sinh.')
          : FutureBuilder<List<Grade>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
                if (snap.hasError) return ErrorView(message: snap.error.toString(), onRetry: _reload);

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
    List<Grade> validGrades = gradesMap.values.where((g) => g.averageScore != null).toList();
    double gpa = 0;
    if (validGrades.isNotEmpty) {
      gpa = validGrades.map((g) => g.averageScore!).reduce((a, b) => a + b) / validGrades.length;
    }

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (validGrades.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('ĐIỂM TRUNG BÌNH HỌC KỲ', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(gpa.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          const Text('CHI TIẾT MÔN HỌC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          
          ...ALL_SUBJECTS.map((subject) {
            final g = gradesMap[subject];
            final hasAnyGrade = g != null;
            final isCompleted = g != null && g.averageScore != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _showGradeDetail(g, subject),
                leading: Container(
                  width: 44, height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.subject, color: AppColors.primary),
                ),
                title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('GV: ${g?.teacherName ?? 'Chưa cập nhật'}', style: TextStyle(color: Colors.grey.shade700)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCompleted ? g.averageScore!.toStringAsFixed(1) : '--',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.primary : Colors.grey),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
