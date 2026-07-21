/// Lớp học – khớp entity SchoolClass bên backend.
class SchoolClass {
  final int id;
  final String name;
  final String academicYear;
  final int? homeroomTeacherId;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.academicYear,
    this.homeroomTeacherId,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) => SchoolClass(
    id: json['id'] as int,
    name: json['name'] as String,
    academicYear: json['academicYear'] as String,
    homeroomTeacherId: json['homeroomTeacherId'] as int?,
  );
}
