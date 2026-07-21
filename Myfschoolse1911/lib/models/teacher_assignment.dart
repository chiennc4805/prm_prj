class TeacherAssignment {
  final int classId;
  final String className;
  final String subject;
  final String semester;
  final String academicYear;

  TeacherAssignment({
    required this.classId,
    required this.className,
    required this.subject,
    required this.semester,
    required this.academicYear,
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> json) {
    return TeacherAssignment(
      classId: json['classId'] as int,
      className: json['className'] as String,
      subject: json['subject'] as String,
      semester: json['semester'] as String,
      academicYear: json['academicYear'] as String,
    );
  }
}
