import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/features.dart';
import '../providers/calendar_provider.dart';
import 'join_calendar_screen.dart';

class ManageCalendarsScreen extends StatefulWidget {
  const ManageCalendarsScreen({Key? key}) : super(key: key);

  @override
  State<ManageCalendarsScreen> createState() => _ManageCalendarsScreenState();
}

class _ManageCalendarsScreenState extends State<ManageCalendarsScreen> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage calendars'),
            actions: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh calendars',
                onPressed: _isRefreshing
                    ? null
                    : () => _refreshCalendars(context, provider),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.lastFirestoreError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Failed to load calendars: ${provider.lastFirestoreError}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My calendars',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (provider.calendars.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            provider.isGuestUser
                                ? 'No calendars found in guest mode.'
                                : 'No calendars yet. Create one or join with a code.',
                          ),
                        )
                      else
                        Column(
                          children: provider.calendars.map((calendar) {
                            final isSelected =
                                calendar.id == provider.activeCalendarId;
                            final role = provider.roleForCalendar(calendar.id);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(calendar.title),
                              subtitle: Text(calendar.id),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoleBadge(role: role),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () => _selectCalendar(
                                context,
                                provider,
                                calendar.id,
                                calendar.title,
                              ),
                            );
                          }).toList(growable: false),
                        ),
                    ],
                  ),
                ),
              ),
              if (Features.sharingEnabled && !provider.isGuestUser) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join with invite code'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinCalendarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectCalendar(
    BuildContext context,
    CalendarProvider provider,
    String calendarId,
    String title,
  ) async {
    try {
      await provider.setActiveCalendar(calendarId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected calendar: $title')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to switch calendar: $error')),
      );
    }
  }

  Future<void> _refreshCalendars(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await provider.refreshCloudNow();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final normalizedRole = role.toLowerCase();
    final color = switch (normalizedRole) {
      'owner' => Colors.deepOrange,
      'editor' => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalizedRole,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
