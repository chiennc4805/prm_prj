/// Học sinh – khớp entity Student bên backend.
class Student {
  final int id;
  final String studentCode;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final int? classId;
  final int? parentId;
  final String? className;

  const Student({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.classId,
    this.parentId,
    this.className,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as int,
    studentCode: json['studentCode'] as String,
    fullName: json['fullName'] as String,
    dateOfBirth: json['dateOfBirth'] as String?,
    gender: json['gender'] as String?,
    classId: json['classId'] as int?,
    parentId: json['parentId'] as int?,
    className: json['className'] as String?,
  );
}
