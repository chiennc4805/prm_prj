/// Đơn xin nghỉ học – khớp entity LeaveRequest bên backend.
/// status: PENDING | APPROVED | REJECTED
class LeaveRequest {
  final int? id;
  final int studentId;
  final String studentCode;
  final String studentName;
  final String? className;
  final String leaveType; // ABSENT, LATE, EARLY, OTHER
  final String? title;
  final String fromDate; // yyyy-MM-dd
  final String toDate;
  final String? timeValue; // HH:mm
  final String reason;
  final String status;
  final int? createdById;
  final int? reviewedById;

  const LeaveRequest({
    this.id,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    this.className,
    this.leaveType = 'ABSENT',
    this.title,
    required this.fromDate,
    required this.toDate,
    this.timeValue,
    required this.reason,
    this.status = 'PENDING',
    this.createdById,
    this.reviewedById,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
    id: json['id'] as int?,
    studentId: json['studentId'] as int,
    studentCode: json['studentCode'] as String,
    studentName: json['studentName'] as String,
    className: json['className'] as String?,
    leaveType: (json['leaveType'] as String? ?? 'ABSENT').trim().toUpperCase(),
    title: json['title'] as String?,
    fromDate: json['fromDate'] as String,
    toDate: json['toDate'] as String,
    timeValue: json['timeValue'] as String?,
    reason: json['reason'] as String,
    status: (json['status'] as String).trim().toUpperCase(),
    createdById: json['createdById'] as int?,
    reviewedById: json['reviewedById'] as int?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'studentId': studentId,
    'studentCode': studentCode,
    'studentName': studentName,
    if (className != null) 'className': className,
    'leaveType': leaveType,
    if (title != null) 'title': title,
    'fromDate': fromDate,
    'toDate': toDate,
    if (timeValue != null) 'timeValue': timeValue,
    'reason': reason,
    'status': status,
    if (createdById != null) 'createdById': createdById,
  };

  static String label(String status) {
    switch (status) {
      case 'PENDING_PARENT':
        return 'Chờ Phụ huynh duyệt';
      case 'PENDING_TEACHER':
        return 'Chờ GVCN duyệt';
      case 'PENDING_SCHOOL':
        return 'Chờ Nhà trường duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'PENDING':
        return 'Chờ duyệt';
      default:
        return status;
    }
  }
}
