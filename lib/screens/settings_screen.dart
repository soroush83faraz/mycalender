import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../services/notification_service.dart';
import 'backend_health_check_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.signOut,
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appearanceTheme,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.autoTheme),
              subtitle: Text(l10n.autoThemeSub),
              value: provider.settings.autoTheme,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(autoTheme: value),
                );
              },
            ),
            if (!provider.settings.autoTheme)
              SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.darkModeSub),
                value: provider.settings.isDarkMode,
                onChanged: (value) {
                  provider.updateSettings(
                    provider.settings.copyWith(isDarkMode: value),
                  );
                },
              ),
            ListTile(
              title: Text(l10n.primaryColor),
              subtitle: Text(l10n.primaryColorSub),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.display,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.persianNumbers),
              subtitle: Text(l10n.persianNumbersSub),
              value: provider.settings.showPersianNumbers,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPersianNumbers: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.showGregorian),
              subtitle: Text(l10n.showGregorianSub),
              value: provider.settings.showGregorianCalendar,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showGregorianCalendar: value),
                );
              },
            ),
            ListTile(
              title: Text(l10n.defaultView),
              subtitle: Text(_getViewName(context, provider.settings.defaultView)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showViewSelector(context, provider),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(
                provider.settings.language == 'en'
                    ? l10n.englishLang
                    : l10n.persianLang,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageSelector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
      BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notifications,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.enableNotifications),
              subtitle: Text(l10n.enableNotificationsSub),
              value: provider.settings.enableNotifications,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(enableNotifications: value),
                );
                if (value) NotificationService.requestPermission();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
      BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.calendarSection,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.showHolidays),
              subtitle: Text(l10n.showHolidaysSub),
              value: provider.settings.showHolidays,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showHolidays: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.showEvents),
              subtitle: Text(l10n.showEventsSub),
              value: provider.settings.showEvents,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showEvents: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.prayerTimes),
              subtitle: Text(l10n.prayerTimesSub),
              value: provider.settings.showPrayerTimes,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPrayerTimes: value),
                );
                if (value &&
                    provider.settings.useDeviceLocation &&
                    provider.settings.latitude == null) {
                  _refreshLocation(context, provider, silent: true);
                }
              },
            ),
            SwitchListTile(
              title: Text(l10n.useDeviceLocation),
              subtitle: Text(l10n.useDeviceLocationSub),
              value: provider.settings.useDeviceLocation,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(useDeviceLocation: value),
                );
                if (value) _refreshLocation(context, provider, silent: true);
              },
            ),
            if (provider.settings.useDeviceLocation)
              ListTile(
                leading: const Icon(Icons.my_location),
                title: Text(l10n.updateLocation),
                subtitle: Text(
                  provider.settings.latitude != null
                      ? l10n.savedLocation(
                          '${provider.settings.latitude!.toStringAsFixed(3)}, '
                          '${provider.settings.longitude!.toStringAsFixed(3)}')
                      : l10n.noLocationSaved,
                ),
                trailing: const Icon(Icons.refresh),
                onTap: () => _refreshLocation(context, provider),
              )
            else
              ListTile(
                title: Text(l10n.selectCity),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutApp,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.version),
              subtitle: const Text('۱.۰.۰'),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: Text(l10n.developer),
              subtitle: Text(l10n.developerName),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: Text(l10n.contactUs),
              subtitle: Text(l10n.contactUsSub),
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
    final l10n = AppLocalizations.of(context);
    Color currentColor = Color(
      int.parse(provider.settings.primaryColor.replaceFirst('#', '0xFF')),
    );

    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: Text(l10n.selectColor),
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
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                provider.updateSettings(
                  provider.settings.copyWith(
                    primaryColor:
                        '#${tempColor.toARGB32().toRadixString(16).substring(2)}',
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    final languages = {
      'fa': l10n.persianLang,
      'en': l10n.englishLang,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: provider.settings.language,
                onChanged: (value) {
                  if (value != null) {
                    provider.updateSettings(
                      provider.settings.copyWith(language: value),
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

  void _showViewSelector(BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    final views = {
      'month': l10n.monthly,
      'week': l10n.weekly,
      'year': l10n.yearly,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectDefaultView),
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
    final l10n = AppLocalizations.of(context);
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
          title: Text(l10n.selectCity),
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

  Future<void> _refreshLocation(
    BuildContext context,
    CalendarProvider provider, {
    bool silent = false,
  }) async {
    final ok = await provider.refreshDeviceLocation();
    if (!context.mounted || silent && ok) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.locationUpdated : l10n.locationFailed),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.contactUs),
          content: Text(l10n.contactBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection(BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.account,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.accountStatus),
              subtitle: Text(provider.accountStatusLabel),
            ),
            if (provider.isGuestUser)
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: Text(l10n.upgradeToGoogle),
                subtitle: Text(l10n.upgradeToGoogleSub),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _handleUpgradeToGoogle(context, provider),
              ),
            if (provider.isSignedIn && !provider.isGuestUser)
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l10n.googleSync),
                subtitle: Text(l10n.googleSyncSub),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _syncGoogleCalendar(context, provider),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncGoogleCalendar(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Flexible(child: Text(l10n.syncing)),
          ],
        ),
      ),
    );

    final result = await provider.syncWithGoogleCalendar();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? l10n.syncDone(
                  result.imported.toString(),
                  result.exported.toString(),
                )
              : l10n.syncFailed,
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    CalendarProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.signOut),
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
        SnackBar(content: Text(l10n.signOutFailed(error.toString()))),
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

  String _getViewName(BuildContext context, String view) {
    final l10n = AppLocalizations.of(context);
    switch (view) {
      case 'month':
        return l10n.monthly;
      case 'week':
        return l10n.weekly;
      case 'year':
        return l10n.yearly;
      default:
        return l10n.monthly;
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
