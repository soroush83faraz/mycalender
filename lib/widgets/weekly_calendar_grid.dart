import 'package:flutter/material.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../utils/calendar_utils.dart';

class WeeklyCalendarGrid extends StatelessWidget {
  final JalaliDate currentDate;
  final JalaliDate? selectedDate;
  final Function(int, int, int)? onDaySelected;
  final List<Event> events;
  final List<Holiday> holidays;
  final bool usePersianNumbers;
  final bool showGregorianCalendar;

  const WeeklyCalendarGrid({
    Key? key,
    required this.currentDate,
    this.selectedDate,
    this.onDaySelected,
    this.events = const [],
    this.holidays = const [],
    this.usePersianNumbers = true,
    this.showGregorianCalendar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildWeekdayHeaders(context),
            const SizedBox(height: 8),
            _buildWeekDays(context, weekDays),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWeekDays(BuildContext context, List<JalaliDate> weekDays) {
    return Row(
      children: weekDays
          .map(
            (date) => Expanded(
              child: _buildDayCell(context, date),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayCell(BuildContext context, JalaliDate date) {
    final isSelected = selectedDate?.year == date.year &&
        selectedDate?.month == date.month &&
        selectedDate?.day == date.day;
    final isToday = _isToday(date);
    final dayEvents = _getEventsForDay(date);
    final dayHolidays = holidays
        .where((h) => h.month == date.month && h.day == date.day)
        .toList();
    final hasHoliday = dayHolidays.isNotEmpty;
    final hasDayOff = dayHolidays.any((h) => h.isDayOff);
    final gregorianDate = date.toGregorian();

    return GestureDetector(
      onTap: () => onDaySelected?.call(date.year, date.month, date.day),
      child: Container(
        height: 68,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              _getDayBackgroundColor(context, isSelected, isToday, hasDayOff),
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              CalendarUtils.formatNumber(
                date.day,
                usePersian: usePersianNumbers,
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    _getDayTextColor(context, isSelected, isToday, hasDayOff),
              ),
            ),
            if (showGregorianCalendar)
              Text(
                CalendarUtils.formatNumber(
                  gregorianDate.day,
                  usePersian: usePersianNumbers,
                ),
                style: TextStyle(
                  fontSize: 10,
                  color:
                      _getDayTextColor(context, isSelected, isToday, hasDayOff)
                          .withOpacity(0.75),
                ),
              ),
            if (dayEvents.isNotEmpty || hasHoliday)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dayEvents.isNotEmpty)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (dayEvents.isNotEmpty && hasHoliday)
                    const SizedBox(width: 2),
                  if (hasHoliday)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getHolidayColor(dayHolidays.first.type),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<JalaliDate> _getWeekDays() {
    final gregorianDate = CalendarUtils.toGregorian(currentDate);
    final weekday = gregorianDate.weekday; // 1 = Monday, 7 = Sunday
    final persianWeekday =
        (weekday + 1) % 7; // Convert to Persian weekday (0 = Saturday)

    final startOfWeek = gregorianDate.subtract(Duration(days: persianWeekday));

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return JalaliDate.fromGregorian(date);
    });
  }

  bool _isToday(JalaliDate date) {
    final now = DateTime.now();
    final todayJalali = JalaliDate.fromGregorian(now);
    return todayJalali.year == date.year &&
        todayJalali.month == date.month &&
        todayJalali.day == date.day;
  }

  List<Event> _getEventsForDay(JalaliDate date) {
    return events.where((event) {
      final eventJalali = JalaliDate.fromGregorian(event.date);
      return eventJalali.year == date.year &&
          eventJalali.month == date.month &&
          eventJalali.day == date.day;
    }).toList();
  }

  Color _getDayBackgroundColor(
      BuildContext context, bool isSelected, bool isToday, bool hasHoliday) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }
    if (hasHoliday) {
      return Colors.red.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(
      BuildContext context, bool isSelected, bool isToday, bool hasHoliday) {
    if (isSelected) {
      return Colors.white;
    }
    if (hasHoliday) {
      return Colors.red;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getHolidayColor(String type) {
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
