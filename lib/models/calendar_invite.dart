class CalendarInvite {
  const CalendarInvite({
    required this.inviteId,
    required this.calendarId,
    required this.emailLower,
    required this.role,
    required this.createdBy,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  final String inviteId;
  final String calendarId;
  final String emailLower;
  final String role;
  final String createdBy;
  final String status;
  final DateTime? createdAt;
  final DateTime? expiresAt;
}
