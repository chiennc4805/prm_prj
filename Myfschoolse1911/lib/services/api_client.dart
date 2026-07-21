// ============================================================
// api_client.dart
// Lớp gọi HTTP dùng chung cho toàn app → Spring Boot REST API.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Ngoại lệ API có kèm mã trạng thái + thông điệp.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  // 10.0.2.2 = localhost của máy host khi chạy trên Android Emulator.
  // - Thiết bị Android thật: đổi thành IP LAN của máy chạy backend (vd 192.168.1.x)
  // - Chrome/Web/Windows desktop: dùng 'http://localhost:8080'
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // ── GET trả về danh sách JSON ──────────────────────────────────────
  static Future<List<dynamic>> getList(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    _ensureOk(res);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  // ── GET trả về 1 object JSON ───────────────────────────────────────
  static Future<Map<String, dynamic>> getObject(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    _ensureOk(res);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // ── POST ───────────────────────────────────────────────────────────
  static Future<dynamic> post(String path, Object body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _ensureOk(res);
    if (res.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ── PUT ────────────────────────────────────────────────────────────
  static Future<dynamic> put(String path, Object body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _ensureOk(res);
    if (res.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ── DELETE ─────────────────────────────────────────────────────────
  static Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    _ensureOk(res);
  }

  /// Kiểm tra status; ném ApiException nếu không thành công.
  static void _ensureOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String msg = 'Lỗi máy chủ (${res.statusCode})';
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
      }
    } catch (_) {
      /* body không phải JSON */
    }
    throw ApiException(res.statusCode, msg);
  }
}
