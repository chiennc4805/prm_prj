/// Lịch học / thời khóa biểu (LichHoc) – khớp entity Schedule bên backend.
class Schedule {
  final int id;
  final int classId;
  final int dayOrder; // 2=Thứ 2 ... 7=Thứ 7, 8=CN
  final int period;
  final String subject;
  final String? room;
  final String? teacherName;
  final String? startTime;
  final String? endTime;

  const Schedule({
    required this.id,
    required this.classId,
    required this.dayOrder,
    required this.period,
    required this.subject,
    this.room,
    this.teacherName,
    this.startTime,
    this.endTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'] as int,
    classId: json['classId'] as int,
    dayOrder: json['dayOrder'] as int,
    period: json['period'] as int,
    subject: json['subject'] as String,
    room: json['room'] as String?,
    teacherName: json['teacherName'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
  );

  /// Nhãn thứ trong tuần.
  static String dayLabel(int dayOrder) {
    switch (dayOrder) {
      case 2:
        return 'Thứ 2';
      case 3:
        return 'Thứ 3';
      case 4:
        return 'Thứ 4';
      case 5:
        return 'Thứ 5';
      case 6:
        return 'Thứ 6';
      case 7:
        return 'Thứ 7';
      case 8:
        return 'Chủ nhật';
      default:
        return 'Thứ $dayOrder';
    }
  }
}
