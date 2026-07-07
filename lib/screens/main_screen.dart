import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/calendar_screen.dart';
import '../screens/events_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/responsive_helper.dart';
import '../widgets/update_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const EventsScreen(),
    const ToolsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Silently check for a new APK release once the UI is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) checkForUpdateAndPrompt(context, silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // compact → bottom navigation bar; medium/expanded → navigation rail.
    if (ResponsiveHelper.isCompact(context)) {
      return Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_outlined),
              selectedIcon: const Icon(Icons.event),
              label: l10n.navEvents,
            ),
            NavigationDestination(
              icon: const Icon(Icons.widgets_outlined),
              selectedIcon: const Icon(Icons.widgets),
              label: l10n.navTools,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings,
            ),
          ],
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            minWidth: 76,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: scheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: Text(l10n.navCalendar),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.event_outlined),
                selectedIcon: const Icon(Icons.event),
                label: Text(l10n.navEvents),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.widgets_outlined),
                selectedIcon: const Icon(Icons.widgets),
                label: Text(l10n.navTools),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(l10n.navSettings),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }
}
