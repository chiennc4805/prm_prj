/// Điểm / sổ liên lạc – khớp entity Grade bên backend.
class Grade {
  final int? id;
  final int studentId;
  final String studentCode;
  final String studentName;
  final String subject;
  final String? regularScores;
  final double? midtermScore;
  final double? finalScore;
  final double? averageScore;
  final String gradeLetter;
  final String semester;
  final String academicYear;
  final String teacherName;
  final List<GradeItem> items;

  const Grade({
    this.id,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.subject,
    this.regularScores,
    this.midtermScore,
    this.finalScore,
    this.averageScore,
    required this.gradeLetter,
    required this.semester,
    required this.academicYear,
    required this.teacherName,
    this.items = const [],
  });

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
    id: json['id'] as int?,
    studentId: json['studentId'] as int,
    studentCode: json['studentCode'] as String,
    studentName: json['studentName'] as String,
    subject: json['subject'] as String,
    regularScores: json['regularScores'] as String?,
    midtermScore: json['midtermScore'] != null
        ? (json['midtermScore'] as num).toDouble()
        : null,
    finalScore: json['finalScore'] != null
        ? (json['finalScore'] as num).toDouble()
        : null,
    averageScore: json['averageScore'] != null
        ? (json['averageScore'] as num).toDouble()
        : null,
    gradeLetter: (json['gradeLetter'] ?? '') as String,
    semester: json['semester'] as String,
    academicYear: json['academicYear'] as String,
    teacherName: json['teacherName'] as String,
    items: (json['items'] as List<dynamic>? ?? const [])
        .map((e) => GradeItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'studentId': studentId,
    'studentCode': studentCode,
    'studentName': studentName,
    'subject': subject,
    'regularScores': regularScores,
    'midtermScore': midtermScore,
    'finalScore': finalScore,
    'averageScore': averageScore,
    'gradeLetter': gradeLetter,
    'semester': semester,
    'academicYear': academicYear,
    'teacherName': teacherName,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class GradeItem {
  final int? id;
  final String name;
  final double score;
  final double weight;
  const GradeItem({
    this.id,
    required this.name,
    required this.score,
    required this.weight,
  });
  factory GradeItem.fromJson(Map<String, dynamic> json) => GradeItem(
    id: json['id'] as int?,
    name: json['name'] as String,
    score: (json['score'] as num).toDouble(),
    weight: (json['weight'] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'weight': weight,
  };
}
