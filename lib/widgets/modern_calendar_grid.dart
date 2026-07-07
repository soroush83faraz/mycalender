import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../utils/calendar_utils.dart';

/// Month grid in two densities:
///
/// * dense (phones): compact square cells — day number, thin colored event
///   bars underneath, holiday tinting, red Fridays.
/// * expanded (desktop): Google-Calendar-style full-height cells with the day
///   number in the corner and titled chips for holidays/events.
class ModernCalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final JalaliDate? selectedDate;
  final Function(int)? onDaySelected;
  final List<Event> events;
  final List<Holiday> holidays;
  final bool usePersianNumbers;
  final bool showGregorianCalendar;

  /// When true the grid fills the available height with large detail cells.
  final bool expanded;

  const ModernCalendarGrid({
    Key? key,
    required this.year,
    required this.month,
    this.selectedDate,
    this.onDaySelected,
    this.events = const [],
    this.holidays = const [],
    this.usePersianNumbers = true,
    this.showGregorianCalendar = false,
    this.expanded = false,
  }) : super(key: key);

  static const List<String> _weekdayShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarUtils.getDaysInMonth(year, month);
    final firstDayWeekday = CalendarUtils.getFirstDayOfMonth(year, month);
    return expanded
        ? _buildExpanded(context, daysInMonth, firstDayWeekday)
        : _buildDense(context, daysInMonth, firstDayWeekday);
  }

  // ───────────────────────── dense (phone) ─────────────────────────

  Widget _buildDense(
      BuildContext context, int daysInMonth, int firstDayWeekday) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: Column(
        children: [
          _buildWeekdayHeaders(context, dense: true),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.92,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _weekCount(daysInMonth, firstDayWeekday) * 7,
            itemBuilder: (context, index) {
              if (index < firstDayWeekday ||
                  index >= firstDayWeekday + daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = index - firstDayWeekday + 1;
              final isFriday = index % 7 == 6;
              return _buildDenseCell(context, day, isFriday);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDenseCell(BuildContext context, int day, bool isFriday) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _isSelected(day);
    final isToday = _isToday(day);
    final dayEvents = _getEventsForDay(day);
    final dayHolidays = holidays.where((h) => h.day == day).toList();
    final hasDayOff = dayHolidays.any((h) => h.isDayOff);
    final gregorianDate =
        JalaliDate(year: year, month: month, day: day).toGregorian();

    final Color background;
    final Color numberColor;
    if (isSelected) {
      background = scheme.primary.withValues(alpha: 0.14);
      numberColor = scheme.primary;
    } else if (hasDayOff) {
      background = Colors.red.withValues(alpha: 0.09);
      numberColor = Colors.red.shade400;
    } else {
      background = Colors.transparent;
      numberColor = (isFriday || hasDayOff)
          ? Colors.red.shade400
          : scheme.onSurface.withValues(alpha: 0.85);
    }

    return InkWell(
      onTap: () => onDaySelected?.call(day),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: scheme.primary, width: 1.4)
              : null,
        ),
        child: Stack(
          children: [
            // Day number dead-center in the cell; today gets the classic
            // filled-circle treatment.
            Center(
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  CalendarUtils.formatNumber(day,
                      usePersian: usePersianNumbers),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isToday ? scheme.onPrimary : numberColor,
                  ),
                ),
              ),
            ),
            // Thin colored bars along the bottom — one per event (max 2).
            if (dayEvents.isNotEmpty)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in dayEvents.take(2))
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 22,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _eventColor(e, scheme),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            if (showGregorianCalendar)
              Positioned(
                top: 3,
                left: 5,
                child: Text(
                  CalendarUtils.formatNumber(gregorianDate.day,
                      usePersian: usePersianNumbers),
                  style: TextStyle(
                    fontSize: 9,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            if (dayHolidays.isNotEmpty)
              Positioned(
                bottom: 3,
                right: 5,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _holidayColor(dayHolidays.first.type),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── expanded (desktop) ────────────────────────

  Widget _buildExpanded(
      BuildContext context, int daysInMonth, int firstDayWeekday) {
    final scheme = Theme.of(context).colorScheme;
    final weeks = _weekCount(daysInMonth, firstDayWeekday);
    final hairline = BorderSide(
      color: scheme.outlineVariant.withValues(alpha: 0.45),
      width: 1,
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildWeekdayHeaders(context, dense: false),
          Divider(height: 1, color: hairline.color),
          for (var week = 0; week < weeks; week++)
            Expanded(
              child: Row(
                children: [
                  for (var weekday = 0; weekday < 7; weekday++)
                    Expanded(
                      child: _buildExpandedCell(
                        context,
                        week * 7 + weekday,
                        firstDayWeekday,
                        daysInMonth,
                        isFriday: weekday == 6,
                        drawTop: week > 0,
                        drawStart: weekday > 0,
                        hairline: hairline,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedCell(
    BuildContext context,
    int index,
    int firstDayWeekday,
    int daysInMonth, {
    required bool isFriday,
    required bool drawTop,
    required bool drawStart,
    required BorderSide hairline,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final border = Border(
      top: drawTop ? hairline : BorderSide.none,
      // In RTL, `start` renders on the right automatically via Directionality;
      // BorderDirectional handles this.
    );

    final outOfMonth =
        index < firstDayWeekday || index >= firstDayWeekday + daysInMonth;

    final decoration = BoxDecoration(
      border: border,
      color: outOfMonth
          ? scheme.surfaceContainerLowest.withValues(alpha: 0.6)
          : null,
    );

    Widget withStartBorder(Widget child) => Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: drawStart ? hairline : BorderSide.none,
            ),
          ),
          child: child,
        );

    if (outOfMonth) {
      return withStartBorder(Container(decoration: decoration));
    }

    final day = index - firstDayWeekday + 1;
    final isSelected = _isSelected(day);
    final isToday = _isToday(day);
    final dayEvents = _getEventsForDay(day);
    final dayHolidays = holidays.where((h) => h.day == day).toList();
    final hasDayOff = dayHolidays.any((h) => h.isDayOff);
    final gregorianDate =
        JalaliDate(year: year, month: month, day: day).toGregorian();

    final numberColor = isToday
        ? scheme.onPrimary
        : hasDayOff || isFriday
            ? Colors.red.shade400
            : scheme.onSurface.withValues(alpha: 0.85);

    return withStartBorder(
      InkWell(
        onTap: () => onDaySelected?.call(day),
        child: Container(
          decoration: decoration.copyWith(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.08)
                : hasDayOff
                    ? Colors.red.withValues(alpha: 0.05)
                    : null,
          ),
          padding: const EdgeInsets.all(5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // How many 19px chip rows fit under the 26px number row?
              final slots =
                  ((constraints.maxHeight - 28) / 19).floor().clamp(0, 6);
              final chips = <Widget>[];
              var used = 0;

              for (final h in dayHolidays) {
                if (used >= slots) break;
                chips.add(_expandedChip(
                  context,
                  label: h.name,
                  color: _holidayColor(h.type),
                  filled: h.isDayOff,
                ));
                used++;
              }
              for (final e in dayEvents) {
                if (used >= slots) break;
                chips.add(_expandedChip(
                  context,
                  label: e.title,
                  color: _eventColor(e, scheme),
                ));
                used++;
              }
              final overflow =
                  (dayHolidays.length + dayEvents.length) - used;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: isToday
                            ? BoxDecoration(
                                color: scheme.primary, shape: BoxShape.circle)
                            : null,
                        child: Text(
                          CalendarUtils.formatNumber(day,
                              usePersian: usePersianNumbers),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: numberColor,
                          ),
                        ),
                      ),
                      if (showGregorianCalendar)
                        Text(
                          CalendarUtils.formatNumber(gregorianDate.day,
                              usePersian: usePersianNumbers),
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ...chips,
                  if (overflow > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        AppLocalizations.of(context).moreItems(
                          CalendarUtils.formatNumber(overflow,
                              usePersian: usePersianNumbers),
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _expandedChip(
    BuildContext context, {
    required String label,
    required Color color,
    bool filled = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 17,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsetsDirectional.only(start: 5, end: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.88) : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
        border: filled
            ? null
            : BorderDirectional(
                start: BorderSide(color: color, width: 2.5),
              ),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : scheme.onSurface.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  // ───────────────────────── shared bits ─────────────────────────

  Widget _buildWeekdayHeaders(BuildContext context, {required bool dense}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: dense
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: dense ? 6 : 0),
                child: Text(
                  dense ? _weekdayShort[i] : JalaliDate.getWeekdayName(i),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: dense ? 12.5 : 12,
                    color: i == 6
                        ? Colors.red.shade400
                        : scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _weekCount(int daysInMonth, int firstDayWeekday) =>
      ((firstDayWeekday + daysInMonth) / 7).ceil();

  bool _isSelected(int day) =>
      selectedDate?.year == year &&
      selectedDate?.month == month &&
      selectedDate?.day == day;

  bool _isToday(int day) {
    final todayJalali = JalaliDate.fromGregorian(DateTime.now());
    return todayJalali.year == year &&
        todayJalali.month == month &&
        todayJalali.day == day;
  }

  List<Event> _getEventsForDay(int day) {
    return events.where((event) {
      final eventJalali = JalaliDate.fromGregorian(event.date);
      return eventJalali.year == year &&
          eventJalali.month == month &&
          eventJalali.day == day;
    }).toList();
  }

  Color _eventColor(Event e, ColorScheme scheme) {
    try {
      return Color(int.parse(e.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return scheme.secondary;
    }
  }

  Color _holidayColor(String type) {
    switch (type) {
      case 'official':
        return Colors.red;
      case 'religious':
        return Colors.green;
      case 'ancient':
        return Colors.orange;
      case 'international':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
