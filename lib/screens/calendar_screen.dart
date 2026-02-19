import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/calendar_provider.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../widgets/modern_calendar_grid.dart';
import '../widgets/weekly_calendar_grid.dart';
import '../widgets/yearly_calendar_grid.dart';
import '../widgets/event_list_widget.dart';
import '../widgets/holiday_widget.dart';
import '../services/prayer_times_service.dart';
import '../utils/calendar_utils.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        _buildMonthHeader(context, provider),
                        _buildCalendarGrid(context, provider),
                        if (provider.settings.showPrayerTimes &&
                            provider.selectedDate == null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildPrayerTimesCard(context, provider),
                          ),
                        if (provider.selectedDate != null)
                          _buildSelectedDateInfo(context, provider),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButtons(context, provider),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, CalendarProvider provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقویم فارسی',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.today, color: Colors.white),
                  onPressed: provider.goToToday,
                  tooltip: 'امروز',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.view_module, color: Colors.white),
                  onSelected: provider.setView,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'month', child: Text('نمای ماهانه')),
                    const PopupMenuItem(
                        value: 'week', child: Text('نمای هفتگی')),
                    const PopupMenuItem(
                        value: 'year', child: Text('نمای سالانه')),
                  ],
                ),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _getPreviousAction(provider),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(8),
            ),
          ),
          Column(
            children: [
              Text(
                _getHeaderTitle(provider),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              if (provider.currentView != 'year')
                Text(
                  CalendarUtils.formatNumber(
                    provider.currentDate.year,
                    usePersian: provider.settings.showPersianNumbers,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.7),
                  ),
                ),
              if (provider.currentView == 'year')
                TextButton(
                  onPressed: () {
                    final today = JalaliDate.fromGregorian(DateTime.now());
                    provider.setCurrentDate(today);
                  },
                  child: Text(
                    'امروز',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: _getNextAction(provider),
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle(CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return 'هفته';
      case 'year':
        return CalendarUtils.formatNumber(
          provider.currentDate.year,
          usePersian: provider.settings.showPersianNumbers,
        );
      case 'month':
      default:
        return provider.currentDate.getMonthName();
    }
  }

  VoidCallback? _getNextAction(CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return () {
          final currentGregorian = CalendarUtils.toGregorian(
              provider.selectedDate ?? provider.currentDate);
          final nextWeek = currentGregorian.add(const Duration(days: 7));
          final nextWeekJalali = JalaliDate.fromGregorian(nextWeek);
          provider.setCurrentDate(nextWeekJalali);
          if (provider.selectedDate != null) {
            provider.setSelectedDate(nextWeekJalali);
          }
        };
      case 'year':
        return () {
          provider.setCurrentDate(JalaliDate(
            year: provider.currentDate.year + 1,
            month: provider.currentDate.month,
            day: provider.currentDate.day,
          ));
        };
      case 'month':
      default:
        return provider.nextMonth;
    }
  }

  VoidCallback? _getPreviousAction(CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return () {
          final currentGregorian = CalendarUtils.toGregorian(
              provider.selectedDate ?? provider.currentDate);
          final previousWeek =
              currentGregorian.subtract(const Duration(days: 7));
          final previousWeekJalali = JalaliDate.fromGregorian(previousWeek);
          provider.setCurrentDate(previousWeekJalali);
          if (provider.selectedDate != null) {
            provider.setSelectedDate(previousWeekJalali);
          }
        };
      case 'year':
        return () {
          provider.setCurrentDate(JalaliDate(
            year: provider.currentDate.year - 1,
            month: provider.currentDate.month,
            day: provider.currentDate.day,
          ));
        };
      case 'month':
      default:
        return provider.previousMonth;
    }
  }

  Widget _buildCalendarGrid(BuildContext context, CalendarProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildCalendarByView(context, provider),
    );
  }

  Widget _buildCalendarByView(BuildContext context, CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        final holidays = provider.settings.showHolidays
            ? Holiday.getPersianHolidays()
            : const <Holiday>[];
        return WeeklyCalendarGrid(
          currentDate: provider.selectedDate ?? provider.currentDate,
          selectedDate: provider.selectedDate,
          onDaySelected: (year, month, day) {
            final selectedDate = JalaliDate(year: year, month: month, day: day);
            provider.setSelectedDate(selectedDate);
            provider
                .setCurrentDate(JalaliDate(year: year, month: month, day: 1));
          },
          events:
              provider.settings.showEvents ? provider.events : const <Event>[],
          holidays: holidays,
          usePersianNumbers: provider.settings.showPersianNumbers,
          showGregorianCalendar: provider.settings.showGregorianCalendar,
        );
      case 'year':
        final holidays = provider.settings.showHolidays
            ? Holiday.getPersianHolidays()
            : const <Holiday>[];
        return YearlyCalendarGrid(
          year: provider.currentDate.year,
          selectedDate: provider.selectedDate,
          onMonthSelected: (year, month) {
            provider
                .setCurrentDate(JalaliDate(year: year, month: month, day: 1));
            provider.setView('month');
          },
          events:
              provider.settings.showEvents ? provider.events : const <Event>[],
          holidays: holidays,
          usePersianNumbers: provider.settings.showPersianNumbers,
          showGregorianCalendar: provider.settings.showGregorianCalendar,
        );
      case 'month':
      default:
        final holidays = provider.settings.showHolidays
            ? Holiday.getHolidaysForMonth(provider.currentDate.month)
            : const <Holiday>[];
        return ModernCalendarGrid(
          year: provider.currentDate.year,
          month: provider.currentDate.month,
          selectedDate: provider.selectedDate,
          onDaySelected: (day) {
            final selectedDate = JalaliDate(
              year: provider.currentDate.year,
              month: provider.currentDate.month,
              day: day,
            );
            provider.setSelectedDate(selectedDate);
          },
          events:
              provider.settings.showEvents ? provider.events : const <Event>[],
          holidays: holidays,
          usePersianNumbers: provider.settings.showPersianNumbers,
          showGregorianCalendar: provider.settings.showGregorianCalendar,
        );
    }
  }

  Widget _buildSelectedDateInfo(
      BuildContext context, CalendarProvider provider) {
    final selectedDate = provider.selectedDate!;
    final events = provider.settings.showEvents
        ? provider.getEventsForDate(selectedDate)
        : const <Event>[];
    final holidays = provider.settings.showHolidays
        ? provider.getHolidaysForDate(selectedDate)
        : const <Holiday>[];
    final selectedGregorianDate = selectedDate.toGregorian();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تاریخ انتخاب شده',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${CalendarUtils.formatNumber(selectedDate.day, usePersian: provider.settings.showPersianNumbers)} ${selectedDate.getMonthName()} ${CalendarUtils.formatNumber(selectedDate.year, usePersian: provider.settings.showPersianNumbers)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (provider.settings.showGregorianCalendar) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${CalendarUtils.formatNumber(selectedGregorianDate.year, usePersian: provider.settings.showPersianNumbers)}/${CalendarUtils.formatNumber(selectedGregorianDate.month.toString().padLeft(2, '0'), usePersian: provider.settings.showPersianNumbers)}/${CalendarUtils.formatNumber(selectedGregorianDate.day.toString().padLeft(2, '0'), usePersian: provider.settings.showPersianNumbers)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.75),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    JalaliDate.getWeekdayName(
                      CalendarUtils.gregorianWeekdayToPersianIndex(
                        selectedGregorianDate.weekday,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (holidays.isNotEmpty) HolidayWidget(holidays: holidays),
          if (events.isNotEmpty) EventListWidget(events: events),
          if (provider.settings.showPrayerTimes)
            _buildPrayerTimesCard(context, provider),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard(
      BuildContext context, CalendarProvider provider) {
    final targetDate =
        (provider.selectedDate ?? provider.currentDate).toGregorian();
    final prayerTimes = PrayerTimesService.calculate(
      date: targetDate,
      cityName: provider.settings.location,
    );

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اوقات شرعی (${provider.settings.location})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${targetDate.year}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            ...prayerTimes.times.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(entry.key),
                    const SizedBox(width: 12),
                    Text(
                      CalendarUtils.formatNumber(
                        entry.value == null
                            ? '--:--'
                            : '${entry.value!.hour.toString().padLeft(2, '0')}:${entry.value!.minute.toString().padLeft(2, '0')}',
                        usePersian: provider.settings.showPersianNumbers,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(
      BuildContext context, CalendarProvider provider) {
    final canEdit = provider.activeMembershipRole != 'viewer';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'add_event',
          onPressed: canEdit
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEventScreen(
                        selectedDate: provider.selectedDate,
                      ),
                    ),
                  );
                }
              : null,
          tooltip: canEdit ? null : 'Viewer access: cannot add events',
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.small(
          heroTag: 'today',
          onPressed: provider.goToToday,
          child: const Icon(Icons.today),
        ),
      ],
    );
  }
}
