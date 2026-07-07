import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../widgets/modern_calendar_grid.dart';
import '../widgets/weekly_calendar_grid.dart';
import '../widgets/yearly_calendar_grid.dart';
import '../widgets/event_list_widget.dart';
import '../widgets/holiday_widget.dart';
import '../widgets/day_details_panel.dart';
import '../widgets/prayer_times_card.dart';
import '../utils/calendar_utils.dart';
import '../utils/responsive_helper.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return ResponsiveHelper.isExpanded(context)
            ? _buildExpandedLayout(context, provider)
            : _buildCompactLayout(context, provider);
      },
    );
  }

  // ═══════════════════════ expanded (desktop) ═══════════════════════

  Widget _buildExpandedLayout(BuildContext context, CalendarProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildDesktopToolbar(context, provider),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(child: _buildDesktopBody(context, provider)),
              ],
            ),
          ),
          VerticalDivider(
            width: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          SizedBox(
            width: ResponsiveHelper.detailsPanelWidth,
            child: const DayDetailsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopToolbar(
      BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final canEdit = provider.activeMembershipRole != 'viewer';

    // The arrow points in the direction of travel: "‹" (left) always goes to
    // the previous month, "›" (right) always to the next month. The pair is
    // locked to LTR below so "‹" stays physically left and "›" right, whatever
    // the app's text direction.
    final leftChevron = IconButton.filledTonal(
      onPressed: _getPreviousAction(provider),
      icon: const Icon(Icons.chevron_left, size: 22),
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 38),
        padding: EdgeInsets.zero,
      ),
    );
    final rightChevron = IconButton.filledTonal(
      onPressed: _getNextAction(provider),
      icon: const Icon(Icons.chevron_right, size: 22),
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 38),
        padding: EdgeInsets.zero,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          // Lock the arrow pair to LTR so "‹" is physically on the left and
          // "›" on the right, regardless of the app's text direction.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leftChevron,
                const SizedBox(width: 6),
                rightChevron,
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _getHeaderTitle(context, provider) +
                (provider.currentView != 'year'
                    ? ' ${CalendarUtils.formatNumber(provider.currentDate.year, usePersian: provider.settings.showPersianNumbers)}'
                    : ''),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: provider.goToToday,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: Text(l10n.today,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'month', label: Text(l10n.viewMonthShort)),
              ButtonSegment(value: 'week', label: Text(l10n.viewWeekShort)),
              ButtonSegment(value: 'year', label: Text(l10n.viewYearShort)),
            ],
            selected: {provider.currentView},
            onSelectionChanged: (s) => provider.setView(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: canEdit
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEventScreen(
                          selectedDate: provider.selectedDate,
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addEvent),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context, CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AdaptiveContent(
            maxWidth: 900,
            child: _buildWeekGrid(context, provider),
          ),
        );
      case 'year':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AdaptiveContent(
            maxWidth: 1100,
            child: _buildYearGrid(context, provider),
          ),
        );
      case 'month':
      default:
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: _buildMonthGrid(context, provider, expanded: true),
        );
    }
  }

  // ═══════════════════════ compact (phone/tablet) ═══════════════════════

  Widget _buildCompactLayout(BuildContext context, CalendarProvider provider) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, provider),
          SliverToBoxAdapter(
            child: AdaptiveContent(
              child: Column(
                children: [
                  _buildMonthHeader(context, provider),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCalendarByView(context, provider),
                  ),
                  if (provider.settings.showPrayerTimes &&
                      provider.selectedDate == null)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: PrayerTimesCard(),
                    ),
                  if (provider.selectedDate != null)
                    _buildSelectedDateInfo(context, provider),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(context, provider),
    );
  }

  Widget _buildAppBar(BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
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
    final scheme = Theme.of(context).colorScheme;

    // The arrow points in the direction of travel: "‹" (left) always goes to
    // the previous month, "›" (right) always to the next month. The pair is
    // locked to LTR below so "‹" stays physically left and "›" right, whatever
    // the app's text direction.
    final leftChevron = IconButton(
      onPressed: _getPreviousAction(provider),
      icon: Icon(Icons.chevron_left,
          color: scheme.onSurface.withValues(alpha: 0.7)),
    );
    final rightChevron = IconButton(
      onPressed: _getNextAction(provider),
      icon: Icon(Icons.chevron_right,
          color: scheme.onSurface.withValues(alpha: 0.7)),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      // Lock to LTR so "‹" stays physically on the left and "›" on the right;
      // the title column is wrapped back to RTL so its text aligns naturally.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leftChevron,
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Text(
                    _getHeaderTitle(context, provider),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (provider.currentView != 'year')
                    Text(
                      CalendarUtils.formatNumber(
                        provider.currentDate.year,
                        usePersian: provider.settings.showPersianNumbers,
                      ),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurface.withValues(alpha: 0.55),
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            rightChevron,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════ shared pieces ═══════════════════════

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

  Widget _buildCalendarByView(BuildContext context, CalendarProvider provider) {
    switch (provider.currentView) {
      case 'week':
        return _buildWeekGrid(context, provider);
      case 'year':
        return _buildYearGrid(context, provider);
      case 'month':
      default:
        return _buildMonthGrid(context, provider, expanded: false);
    }
  }

  Widget _buildMonthGrid(BuildContext context, CalendarProvider provider,
      {required bool expanded}) {
    final holidays = provider.settings.showHolidays
        ? Holiday.occurrencesForJalaliMonth(
            provider.currentDate.year, provider.currentDate.month)
        : const <Holiday>[];
    return ModernCalendarGrid(
      year: provider.currentDate.year,
      month: provider.currentDate.month,
      selectedDate: provider.selectedDate,
      expanded: expanded,
      onDaySelected: (day) {
        provider.setSelectedDate(JalaliDate(
          year: provider.currentDate.year,
          month: provider.currentDate.month,
          day: day,
        ));
      },
      events: provider.settings.showEvents ? provider.events : const <Event>[],
      holidays: holidays,
      usePersianNumbers: provider.settings.showPersianNumbers,
      showGregorianCalendar: provider.settings.showGregorianCalendar,
    );
  }

  Widget _buildWeekGrid(BuildContext context, CalendarProvider provider) {
    final holidays = provider.settings.showHolidays
        ? Holiday.occurrencesForJalaliYear(provider.currentDate.year)
        : const <Holiday>[];
    return WeeklyCalendarGrid(
      currentDate: provider.selectedDate ?? provider.currentDate,
      selectedDate: provider.selectedDate,
      onDaySelected: (year, month, day) {
        final selectedDate = JalaliDate(year: year, month: month, day: day);
        provider.setSelectedDate(selectedDate);
        provider.setCurrentDate(JalaliDate(year: year, month: month, day: 1));
      },
      events: provider.settings.showEvents ? provider.events : const <Event>[],
      holidays: holidays,
      usePersianNumbers: provider.settings.showPersianNumbers,
      showGregorianCalendar: provider.settings.showGregorianCalendar,
    );
  }

  Widget _buildYearGrid(BuildContext context, CalendarProvider provider) {
    final holidays = provider.settings.showHolidays
        ? Holiday.occurrencesForJalaliYear(provider.currentDate.year)
        : const <Holiday>[];
    return YearlyCalendarGrid(
      year: provider.currentDate.year,
      selectedDate: provider.selectedDate,
      onMonthSelected: (year, month) {
        provider.setCurrentDate(JalaliDate(year: year, month: month, day: 1));
        provider.setView('month');
      },
      events: provider.settings.showEvents ? provider.events : const <Event>[],
      holidays: holidays,
      usePersianNumbers: provider.settings.showPersianNumbers,
      showGregorianCalendar: provider.settings.showGregorianCalendar,
    );
  }

  Widget _buildSelectedDateInfo(
      BuildContext context, CalendarProvider provider) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
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
                      Icon(Icons.calendar_today,
                          size: 18, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.selectedDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${CalendarUtils.formatNumber(selectedDate.day, usePersian: provider.settings.showPersianNumbers)} ${selectedDate.getMonthName()} ${CalendarUtils.formatNumber(selectedDate.year, usePersian: provider.settings.showPersianNumbers)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (provider.settings.showGregorianCalendar) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${CalendarUtils.formatNumber(selectedGregorianDate.year, usePersian: provider.settings.showPersianNumbers)}/${CalendarUtils.formatNumber(selectedGregorianDate.month.toString().padLeft(2, '0'), usePersian: provider.settings.showPersianNumbers)}/${CalendarUtils.formatNumber(selectedGregorianDate.day.toString().padLeft(2, '0'), usePersian: provider.settings.showPersianNumbers)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface.withValues(alpha: 0.75),
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
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (holidays.isNotEmpty) HolidayWidget(holidays: holidays),
          if (events.isNotEmpty) EventListWidget(events: events),
          if (provider.settings.showPrayerTimes)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: PrayerTimesCard(),
            ),
        ],
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
          tooltip:
              canEdit ? null : AppLocalizations.of(context).viewerCannotAdd,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'today',
          onPressed: provider.goToToday,
          child: const Icon(Icons.today),
        ),
      ],
    );
  }
}
