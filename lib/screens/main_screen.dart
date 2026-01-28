import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../screens/calendar_screen.dart';
import '../screens/events_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/responsive_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const EventsScreen(),
    const ToolsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month, size: 40),
                    selectedIcon: Icon(Icons.calendar_month, size: 36),
                    label: Text('تقویم', style: TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event, size: 40),
                    selectedIcon: Icon(Icons.event, size: 36),
                    label: Text('رویدادها', style: TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calculate, size: 40),
                    selectedIcon: Icon(Icons.calculate, size: 36),
                    label: Text('ابزارها', style: TextStyle(fontSize: 16)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings, size: 40),
                    selectedIcon: Icon(Icons.settings, size: 36),
                    label: Text('تنظیمات', style: TextStyle(fontSize: 16)),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'تقویم',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'رویدادها',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'ابزارها',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}