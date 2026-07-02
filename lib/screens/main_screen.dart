import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/calendar_screen.dart';
import '../screens/events_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/responsive_helper.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (ResponsiveHelper.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 150,
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.calendar_month, size: 40),
                    selectedIcon: const Icon(Icons.calendar_month, size: 36),
                    label: Text(l10n.navCalendar,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.event, size: 40),
                    selectedIcon: const Icon(Icons.event, size: 36),
                    label: Text(l10n.navEvents,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.calculate, size: 40),
                    selectedIcon: const Icon(Icons.calculate, size: 36),
                    label: Text(l10n.navTools,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings, size: 40),
                    selectedIcon: const Icon(Icons.settings, size: 36),
                    label: Text(l10n.navSettings,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event),
            label: l10n.navEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate),
            label: l10n.navTools,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
