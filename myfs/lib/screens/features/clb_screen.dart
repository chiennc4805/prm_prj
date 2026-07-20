// ============================================================
// clb_screen.dart – CLB: danh sách câu lạc bộ.
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/club.dart';
import '../../services/club_service.dart';
import '../../widgets/ui_helpers.dart';
import 'clb_detail_screen.dart';

class ClbScreen extends StatefulWidget {
  const ClbScreen({super.key});

  @override
  State<ClbScreen> createState() => _ClbScreenState();
}

class _ClbScreenState extends State<ClbScreen> {
  late Future<List<Club>> _future;

  @override
  void initState() {
    super.initState();
    _future = ClubService.all();
  }

  void _reload() {
    setState(() {
      _future = ClubService.all();
    });
  }

  Color _catColor(String? cat) {
    switch (cat) {
      case 'Học thuật':  return AppColors.info;
      case 'Thể thao':   return AppColors.success;
      case 'Nghệ thuật': return const Color(0xFF7C3AED);
      default:           return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câu lạc bộ')),
      body: FutureBuilder<List<Club>>(
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
                icon: Icons.groups_outlined, message: 'Chưa có câu lạc bộ nào.');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, i) => _clubCard(list[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _clubCard(Club c) {
    final color = _catColor(c.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias, // Để InkWell bo góc
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClbDetailScreen(club: c),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  if (c.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.category!,
                          style: TextStyle(
                              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (c.description != null)
                Text(
                  c.description!,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${c.memberCount} thành viên',
                          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
