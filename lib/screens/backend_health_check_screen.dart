import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calendar_provider.dart';

class BackendHealthCheckScreen extends StatelessWidget {
  const BackendHealthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final backendMode = provider.dataModeStatus;
        final calendarTitle = provider.activeCalendarTitle ?? '-';
        final calendarId = provider.activeCalendarId ?? '(none)';
        final cloudCount = provider.isSignedIn ? provider.cloudEventCount : null;
        final selectedCalendarExists = provider.selectedCalendarExists ? 'yes' : 'no';
        final membershipExists = provider.selectedCalendarMembershipExists
            ? 'yes'
            : 'no';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Backend Health Check'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Auth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Signed in: ${provider.isSignedIn ? 'yes' : 'no'}'),
                      const SizedBox(height: 4),
                      Text('UID: ${user?.uid ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('Email: ${user?.email ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Mode: $backendMode'),
                      const SizedBox(height: 4),
                      Text(
                        'Last Firestore error: ${provider.lastFirestoreError ?? '-'}',
                      ),
                      const SizedBox(height: 4),
                      Text('Selected calendar id: $calendarId'),
                      const SizedBox(height: 4),
                      Text('Selected calendar exists: $selectedCalendarExists'),
                      const SizedBox(height: 4),
                      Text('Membership doc exists: $membershipExists'),
                      const SizedBox(height: 4),
                      Text('Selected calendar title: $calendarTitle'),
                      const SizedBox(height: 4),
                      Text('Cloud calendars count: ${provider.cloudCalendarsCount}'),
                      const SizedBox(height: 4),
                      Text('Local events count: ${provider.localEventCount}'),
                      const SizedBox(height: 4),
                      Text('Cloud events count: ${cloudCount ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.isSignedIn
                    ? () => _forceSyncLocalToCloud(context, provider)
                    : null,
                child: const Text('Force Sync Local -> Cloud'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: provider.isSignedIn
                    ? () => _refreshCloudNow(context, provider)
                    : null,
                child: const Text('Refresh Cloud Now'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmClearLocalCache(context, provider),
                child: const Text('Clear Local Cache'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _forceSyncLocalToCloud(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    try {
      await provider.forceSyncLocalToCloud();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local events synced to cloud.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $error')),
      );
    }
  }

  Future<void> _confirmClearLocalCache(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Cache'),
        content: const Text(
          'This will remove locally cached events on this device. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await provider.clearLocalCache();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local cache cleared.')),
    );
  }

  Future<void> _refreshCloudNow(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    try {
      await provider.refreshCloudNow();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud refresh triggered.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refresh failed: $error')),
      );
    }
  }
}
