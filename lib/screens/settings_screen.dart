import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/calendar_invite.dart';
import '../providers/calendar_provider.dart';
import 'backend_health_check_screen.dart';
import 'join_calendar_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('تنظیمات'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: provider.isSignedIn
                    ? () => _confirmSignOut(context, provider)
                    : null,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAccountSection(context, provider),
              if (provider.isActiveCalendarOwner &&
                  provider.activeCalendarId != null) ...[
                const SizedBox(height: 16),
                const _SharingSection(),
              ],
              const SizedBox(height: 16),
              _buildThemeSection(context, provider),
              const SizedBox(height: 16),
              _buildDisplaySection(context, provider),
              const SizedBox(height: 16),
              _buildNotificationSection(context, provider),
              const SizedBox(height: 16),
              _buildCalendarSection(context, provider),
              const SizedBox(height: 16),
              _buildAboutSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ظاهر و تم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تم خودکار'),
              subtitle: const Text('تغییر خودکار بر اساس تنظیمات سیستم'),
              value: provider.settings.autoTheme,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(autoTheme: value),
                );
              },
            ),
            if (!provider.settings.autoTheme)
              SwitchListTile(
                title: const Text('حالت تاریک'),
                subtitle: const Text('استفاده از تم تاریک'),
                value: provider.settings.isDarkMode,
                onChanged: (value) {
                  provider.updateSettings(
                    provider.settings.copyWith(isDarkMode: value),
                  );
                },
              ),
            ListTile(
              title: const Text('رنگ اصلی'),
              subtitle: const Text('انتخاب رنگ اصلی اپلیکیشن'),
              leading: CircleAvatar(
                backgroundColor: Color(
                  int.parse(
                      provider.settings.primaryColor.replaceFirst('#', '0xFF')),
                ),
                radius: 12,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showColorPicker(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نمایش',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('اعداد فارسی'),
              subtitle: const Text('نمایش اعداد به صورت فارسی'),
              value: provider.settings.showPersianNumbers,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPersianNumbers: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش تقویم میلادی'),
              subtitle: const Text('نمایش همزمان تاریخ میلادی'),
              value: provider.settings.showGregorianCalendar,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showGregorianCalendar: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش تقویم قمری'),
              subtitle: const Text('نمایش همزمان تاریخ قمری'),
              value: provider.settings.showLunarCalendar,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showLunarCalendar: value),
                );
              },
            ),
            ListTile(
              title: const Text('نمای پیشفرض'),
              subtitle: Text(_getViewName(provider.settings.defaultView)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showViewSelector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
      BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اعلانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('فعالسازی اعلانات'),
              subtitle: const Text('دریافت اعلان برای رویدادها و یادآورها'),
              value: provider.settings.enableNotifications,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(enableNotifications: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
      BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تقویم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('نمایش مناسبتها'),
              subtitle: const Text('نمایش تعطیلات و مناسبتهای رسمی'),
              value: provider.settings.showHolidays,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showHolidays: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش رویدادها'),
              subtitle: const Text('نمایش رویدادهای شخصی در تقویم'),
              value: provider.settings.showEvents,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showEvents: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('اوقات شرعی'),
              subtitle: const Text('نمایش اوقات شرعی'),
              value: provider.settings.showPrayerTimes,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPrayerTimes: value),
                );
              },
            ),
            ListTile(
              title: const Text('موقعیت جغرافیایی'),
              subtitle: Text(provider.settings.location),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLocationSelector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'درباره برنامه',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('نسخه'),
              subtitle: const Text('۱.۰.۰'),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('توسعهدهنده'),
              subtitle: const Text('تیم توسعه تقویم فارسی'),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text('ارتباط با ما'),
              subtitle: const Text('ارسال بازخورد و پیشنهادات'),
              leading: const Icon(Icons.email),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showContactDialog(context),
            ),
            ListTile(
              title: const Text('Backend Health Check'),
              subtitle: const Text('View auth and backend sync status'),
              leading: const Icon(Icons.health_and_safety),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackendHealthCheckScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, CalendarProvider provider) {
    Color currentColor = Color(
      int.parse(provider.settings.primaryColor.replaceFirst('#', '0xFF')),
    );

    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('انتخاب رنگ'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                provider.updateSettings(
                  provider.settings.copyWith(
                    primaryColor:
                        '#${tempColor.value.toRadixString(16).substring(2)}',
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('تایید'),
            ),
          ],
        );
      },
    );
  }

  void _showViewSelector(BuildContext context, CalendarProvider provider) {
    const views = {
      'month': 'ماهانه',
      'week': 'هفتگی',
      'year': 'سالانه',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب نمای پیشفرض'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: views.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: provider.settings.defaultView,
                onChanged: (value) {
                  if (value != null) {
                    provider.updateSettings(
                      provider.settings.copyWith(defaultView: value),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLocationSelector(BuildContext context, CalendarProvider provider) {
    const locations = [
      'تهران',
      'مشهد',
      'اصفهان',
      'شیراز',
      'تبریز',
      'کرج',
      'قم',
      'اهواز',
      'کرمانشاه',
      'ارومیه',
      'رشت',
      'زاهدان',
      'همدان',
      'کرمان',
      'یزد',
      'اردبیل'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب شهر'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(locations[index]),
                  onTap: () {
                    provider.updateSettings(
                      provider.settings.copyWith(location: locations[index]),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ارتباط با ما'),
          content: const Text(
            'برای ارسال بازخورد، گزارش باگ یا پیشنهادات خود میتوانید با ما در ارتباط باشید.\n\nایمیل: support@persiancalendar.com\nتلگرام: @PersianCalendarSupport',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Status'),
              subtitle: Text(provider.accountStatusLabel),
            ),
            if (provider.isGuestUser)
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Upgrade to Google'),
                subtitle: const Text('Link this Guest account to Google'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _handleUpgradeToGoogle(context, provider),
              ),
            if (provider.isSignedIn && !provider.isGuestUser)
              ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text('Join calendar'),
                subtitle:
                    const Text('Enter invite code and join a shared calendar'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinCalendarScreen(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              subtitle: const Text('Sign out'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _confirmSignOut(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await provider.signOutCurrentUser();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $error')),
      );
    }
  }

  Future<void> _handleUpgradeToGoogle(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final previousUid = provider.currentUser?.uid;
    _showUpgradeProgress(context);

    try {
      final result = await provider.upgradeToGoogle(
        onExistingAccountConfirm: () =>
            _showExistingAccountWarningDialog(context),
      );
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;

      if (result.redirectStarted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redirecting to Google...')),
        );
        return;
      }

      if (result.alreadySignedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already signed in with Google.')),
        );
        return;
      }

      if (result.cancelledByUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Upgrade cancelled. You are still in Guest mode.')),
        );
        return;
      }

      if (result.signedIntoExistingAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Signed in to existing Google account. Guest data was not merged.'),
          ),
        );
      } else {
        final currentUid = provider.currentUser?.uid;
        final linkedSameUid = previousUid != null && previousUid == currentUid;
        debugPrint(
          'Google upgrade UID check: before=$previousUid after=$currentUid '
          'sameUid=$linkedSameUid',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              linkedSameUid
                  ? 'Upgraded to Google account. UID unchanged.'
                  : 'Upgraded to Google account.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatUpgradeError(error))),
      );
    }
  }

  void _showUpgradeProgress(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Flexible(child: Text('Upgrading account...')),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExistingAccountWarningDialog(BuildContext context) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account Already Exists'),
        content: const Text(
          'This Google account is already registered.\n'
          'If you continue, your current guest data will not be saved to that account.\n'
          'To keep your guest data, sign in with a new Google account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return decision ?? false;
  }

  String _getViewName(String view) {
    switch (view) {
      case 'month':
        return 'ماهانه';
      case 'week':
        return 'هفتگی';
      case 'year':
        return 'سالانه';
      default:
        return 'ماهانه';
    }
  }

  String _formatUpgradeError(Object error) {
    if (error is FirebaseAuthException) {
      final message = error.message;
      if (message != null && message.isNotEmpty) {
        return message;
      }

      switch (error.code) {
        case 'credential-already-in-use':
          return 'This Google account is already linked to another account.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'network-request-failed':
          return 'Network error. Please check your connection and try again.';
        default:
          return 'Google upgrade failed (${error.code}). Please try again.';
      }
    }

    return 'Upgrade failed: $error';
  }
}

class _SharingSection extends StatefulWidget {
  const _SharingSection();

  @override
  State<_SharingSection> createState() => _SharingSectionState();
}

class _SharingSectionState extends State<_SharingSection> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'viewer';
  bool _isCreating = false;
  String? _latestInviteCode;
  String? _revokingInviteId;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sharing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Invite email (optional)',
                    hintText: 'user@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text('viewer')),
                    DropdownMenuItem(value: 'editor', child: Text('editor')),
                  ],
                  onChanged: _isCreating
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreating
                        ? null
                        : () => _createInvite(context, provider),
                    child: Text(
                      _isCreating ? 'Creating...' : 'Create invite',
                    ),
                  ),
                ),
                if (_latestInviteCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.vpn_key),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            _latestInviteCode!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy code',
                          onPressed: () =>
                              _copyInviteCode(context, _latestInviteCode!),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Pending invites',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<CalendarInvite>>(
                  stream: provider.watchPendingInvitesForActiveCalendar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Failed to load invites: ${snapshot.error}');
                    }

                    final invites = snapshot.data ?? const <CalendarInvite>[];
                    if (invites.isEmpty) {
                      return const Text('No pending invites.');
                    }

                    return Column(
                      children: invites.map((invite) {
                        final isRevoking = _revokingInviteId == invite.inviteId;
                        final expiresText = invite.expiresAt == null
                            ? '-'
                            : _formatShortDate(invite.expiresAt!);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.mark_email_unread_outlined),
                          title: Text(invite.emailLower),
                          subtitle: Text(
                              'Role: ${invite.role}  Expires: $expiresText'),
                          trailing: IconButton(
                            tooltip: 'Revoke invite',
                            icon: isRevoking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.block),
                            onPressed: isRevoking
                                ? null
                                : () => _revokeInvite(
                                    context, provider, invite.inviteId),
                          ),
                        );
                      }).toList(growable: false),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createInvite(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final email = _emailController.text.trim();

    setState(() {
      _isCreating = true;
    });
    try {
      final inviteCode = await provider.createInvite(
        email: email,
        role: _selectedRole,
      );
      if (!mounted) return;
      setState(() {
        _latestInviteCode = inviteCode;
      });
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invite created. Share the code manually.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create invite: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _revokeInvite(
    BuildContext context,
    CalendarProvider provider,
    String inviteId,
  ) async {
    setState(() {
      _revokingInviteId = inviteId;
    });
    try {
      await provider.revokeInvite(inviteId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite revoked.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to revoke invite: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _revokingInviteId = null;
        });
      }
    }
  }

  Future<void> _copyInviteCode(BuildContext context, String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied.')),
    );
  }

  String _formatShortDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
