class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDate;
  final String location;
  final bool allDay;
  final String timezone;
  final String category;
  final bool hasReminder;
  final DateTime? reminderTime;
  final String color;
  final String? cloudId;
  final String? calendarId;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.endDate,
    this.location = '',
    this.allDay = false,
    this.timezone = '',
    this.category = 'personal',
    this.hasReminder = false,
    this.reminderTime,
    this.color = '#2196F3',
    this.cloudId,
    this.calendarId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    String? location,
    bool? allDay,
    String? timezone,
    String? category,
    bool? hasReminder,
    DateTime? reminderTime,
    String? color,
    String? cloudId,
    String? calendarId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      allDay: allDay ?? this.allDay,
      timezone: timezone ?? this.timezone,
      category: category ?? this.category,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      color: color ?? this.color,
      cloudId: cloudId ?? this.cloudId,
      calendarId: calendarId ?? this.calendarId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'location': location,
    'allDay': allDay,
    'timezone': timezone,
    'category': category,
    'hasReminder': hasReminder,
    'reminderTime': reminderTime?.toIso8601String(),
    'color': color,
    'cloudId': cloudId,
    'calendarId': calendarId,
    'createdBy': createdBy,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    date: DateTime.parse(json['date']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    location: json['location'] ?? '',
    allDay: json['allDay'] ?? false,
    timezone: json['timezone'] ?? '',
    category: json['category'] ?? 'personal',
    hasReminder: json['hasReminder'] ?? false,
    reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
    color: json['color'] ?? '#2196F3',
    cloudId: json['cloudId'],
    calendarId: json['calendarId'],
    createdBy: json['createdBy'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
}
