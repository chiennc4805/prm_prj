/// Thông báo / hộp thư – khớp entity Notification bên backend.
/// (Đặt tên NotificationItem để tránh trùng lớp Notification của Flutter.)
class NotificationItem {
  final int? id;
  final String title;
  final String content;
  final int? senderId;
  final String? senderName;
  final int? classId; // null = thông báo toàn trường
  final String? className;
  final String? createdAt; // ISO: 2026-07-01T19:04:07

  const NotificationItem({
    this.id,
    required this.title,
    required this.content,
    this.senderId,
    this.senderName,
    this.classId,
    this.className,
    this.createdAt,
  });

  bool get isSchoolWide => classId == null;

  /// "2026-07-01T19:04:07" → "01/07/2026 19:04"
  String get createdAtLabel {
    final raw = createdAt;
    if (raw == null || raw.length < 16) return '';
    final d = raw.substring(0, 10).split('-'); // [yyyy, MM, dd]
    final t = raw.substring(11, 16); // HH:mm
    return '${d[2]}/${d[1]}/${d[0]} $t';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as int?,
        title: json['title'] as String,
        content: json['content'] as String,
        senderId: json['senderId'] as int?,
        senderName: json['senderName'] as String?,
        classId: json['classId'] as int?,
        className: json['className'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    if (senderId != null) 'senderId': senderId,
    if (senderName != null) 'senderName': senderName,
    if (classId != null) 'classId': classId,
    if (className != null) 'className': className,
  };
}
