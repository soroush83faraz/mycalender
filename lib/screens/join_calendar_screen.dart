import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/features.dart';
import '../providers/calendar_provider.dart';
import 'main_screen.dart';

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
    if (!Features.sharingEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Join calendar'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 40),
                const SizedBox(height: 12),
                const Text('Feature disabled'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              if (provider.isGuestUser) ...[
                const SizedBox(height: 12),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Guest calendars are local to guest mode. Signing in with Google won\'t bring them over.',
                    ),
                  ),
                ),
              ],
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                            final role = provider.roleForCalendar(calendar.id);
                            final isActive =
                                calendar.id == provider.activeCalendarId;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(calendar.title),
                              subtitle: Text(calendar.id),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoleBadge(role: role),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ],
                                ],
                              ),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainScreen(initialIndex: 0),
        ),
        (route) => false,
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
