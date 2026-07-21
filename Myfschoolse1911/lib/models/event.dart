/// Sự kiện (SuKien) – khớp entity Event bên backend.
class Event {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String eventDate; // yyyy-MM-dd
  final String? eventTime;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.eventDate,
    this.eventTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    location: json['location'] as String?,
    eventDate: json['eventDate'] as String,
    eventTime: json['eventTime'] as String?,
  );
}
