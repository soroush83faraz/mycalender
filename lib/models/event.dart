class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final bool hasReminder;
  final DateTime? reminderTime;
  final String color;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.category = 'personal',
    this.hasReminder = false,
    this.reminderTime,
    this.color = '#2196F3',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'category': category,
    'hasReminder': hasReminder,
    'reminderTime': reminderTime?.toIso8601String(),
    'color': color,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    date: DateTime.parse(json['date']),
    category: json['category'] ?? 'personal',
    hasReminder: json['hasReminder'] ?? false,
    reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
    color: json['color'] ?? '#2196F3',
  );
}