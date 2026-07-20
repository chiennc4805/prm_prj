/// Câu lạc bộ (CLB) – khớp entity Club bên backend.
class Club {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final String? meetingTime;
  final String? location;
  final String? contact;
  final int memberCount;

  const Club({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.meetingTime,
    this.location,
    this.contact,
    this.memberCount = 0,
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        meetingTime: json['meetingTime'] as String?,
        location: json['location'] as String?,
        contact: json['contact'] as String?,
        memberCount: (json['memberCount'] ?? 0) as int,
      );
}
