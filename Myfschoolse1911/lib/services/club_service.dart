// ============================================================
// club_service.dart – API câu lạc bộ (CLB).
// ============================================================

import '../models/club.dart';
import 'api_client.dart';

class ClubService {
  static Future<List<Club>> all() async {
    final list = await ApiClient.getList('/api/clubs');
    return list.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }
}
