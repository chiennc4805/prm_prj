// ============================================================
// su_kien_screen.dart – SuKien: danh sách sự kiện của trường.
// ============================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../widgets/ui_helpers.dart';
import 'su_kien_detail_screen.dart';

class SuKienScreen extends StatefulWidget {
  const SuKienScreen({super.key});

  @override
  State<SuKienScreen> createState() => _SuKienScreenState();
}

class _SuKienScreenState extends State<SuKienScreen> {
  late Future<List<Event>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventService.all();
  }

  void _reload() {
    setState(() {
      _future = EventService.all();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sự kiện')),
      body: FutureBuilder<List<Event>>(
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
              icon: Icons.event_busy_outlined,
              message: 'Chưa có sự kiện nào.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, i) => _eventCard(list[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _eventCard(Event e) {
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
              builder: (context) => SuKienDetailScreen(event: e),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon lịch mặc định
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin bên phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${e.eventDate}${e.eventTime != null ? ' • ${e.eventTime}' : ''}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
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
