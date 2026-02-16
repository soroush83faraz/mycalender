import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calendar_provider.dart';

class JoinCalendarScreen extends StatefulWidget {
  const JoinCalendarScreen({Key? key}) : super(key: key);

  @override
  State<JoinCalendarScreen> createState() => _JoinCalendarScreenState();
}

class _JoinCalendarScreenState extends State<JoinCalendarScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _isJoining = false;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Join calendar'),
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
              if (provider.isGuestUser)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Please upgrade to Google to join shared calendars.',
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join with invite code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _inviteCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Invite code',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isJoining
                                ? null
                                : () => _joinCalendar(context, provider),
                            child: Text(_isJoining ? 'Joining...' : 'Join'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No calendars found.'),
                        )
                      else
                        Column(
                          children: provider.calendars.map((calendar) {
                            final isActive =
                                calendar.id == provider.activeCalendarId;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(calendar.title),
                              subtitle: Text(calendar.id),
                              trailing: isActive
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                              onTap: () =>
                                  provider.setActiveCalendar(calendar.id),
                            );
                          }).toList(growable: false),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _joinCalendar(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invite code.')),
      );
      return;
    }
    if (provider.isGuestUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upgrade to Google to join shared calendars.'),
        ),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });
    try {
      await provider.acceptInvite(inviteCode);
      if (!mounted) return;
      _inviteCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar joined successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyInviteError(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
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
    } catch (_) {
      // refreshCloudNow already updates provider error state.
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _friendlyInviteError(String rawError) {
    final error = rawError.toLowerCase();
    if (error.contains('already joined')) {
      return 'Already joined.';
    }
    if (error.contains('expired')) {
      return 'This invite has expired.';
    }
    if (error.contains('revoked')) {
      return 'This invite has been revoked.';
    }
    if (error.contains('google')) {
      return 'Please upgrade to Google to join shared calendars.';
    }
    if (error.contains('invalid')) {
      return 'Invite code is invalid for your account.';
    }
    return rawError;
  }
}
