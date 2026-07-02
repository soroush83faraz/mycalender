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
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    // Matches the surface-style app bars used across the rest of the app
    // (styling comes from AppTheme.appBarTheme).
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      title: Text(l10n.appTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.today_outlined),
          onPressed: provider.goToToday,
          tooltip: l10n.today,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.view_module_outlined),
          onSelected: provider.setView,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'month', child: Text(l10n.monthlyView)),
            PopupMenuItem(value: 'week', child: Text(l10n.weeklyView)),
            PopupMenuItem(value: 'year', child: Text(l10n.yearlyView)),
          ],
        ),
        const SizedBox(width: 4),
      ],
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
                _getHeaderTitle(context, provider),
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
                    AppLocalizations.of(context).today,
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

  String _getHeaderTitle(BuildContext context, CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return AppLocalizations.of(context).week;
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
        final base = provider.selectedDate ?? provider.currentDate;
        final holidays = provider.settings.showHolidays
            ? [
                ...Holiday.occurrencesForJalaliMonth(base.year, base.month),
                if (base.month > 1)
                  ...Holiday.occurrencesForJalaliMonth(base.year, base.month - 1),
                if (base.month < 12)
                  ...Holiday.occurrencesForJalaliMonth(base.year, base.month + 1),
              ]
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
            ? Holiday.occurrencesForJalaliYear(provider.currentDate.year)
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
            ? Holiday.occurrencesForJalaliMonth(
                provider.currentDate.year, provider.currentDate.month)
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
                        AppLocalizations.of(context).selectedDate,
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
    final s = provider.settings;
    final useCoords =
        s.useDeviceLocation && s.latitude != null && s.longitude != null;
    final prayerTimes = useCoords
        ? PrayerTimesService.calculate(
            date: targetDate,
            latitude: s.latitude,
            longitude: s.longitude,
            utcOffsetHours: DateTime.now().timeZoneOffset.inMinutes / 60.0,
          )
        : PrayerTimesService.calculate(
            date: targetDate,
            cityName: s.location,
          );

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).prayerTimesFor(prayerTimes.cityName),
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
          tooltip: canEdit ? null : AppLocalizations.of(context).viewerCannotAdd,
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
