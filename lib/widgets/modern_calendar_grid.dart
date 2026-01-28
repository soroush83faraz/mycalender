import 'package:flutter/material.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../utils/calendar_utils.dart';

class ModernCalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final JalaliDate? selectedDate;
  final Function(int)? onDaySelected;
  final List<Event> events;
  final List<Holiday> holidays;

  const ModernCalendarGrid({
    Key? key,
    required this.year,
    required this.month,
    this.selectedDate,
    this.onDaySelected,
    this.events = const [],
    this.holidays = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarUtils.getDaysInMonth(year, month);
    final firstDayWeekday = CalendarUtils.getFirstDayOfMonth(year, month);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildWeekdayHeaders(context),
            const SizedBox(height: 8),
            _buildCalendarDays(context, daysInMonth, firstDayWeekday),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    
    return Row(
      children: weekdays.map((day) => 
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildCalendarDays(BuildContext context, int daysInMonth, int firstDayWeekday) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 35, // 5 weeks * 7 days
      itemBuilder: (context, index) {
        if (index < firstDayWeekday || index >= firstDayWeekday + daysInMonth) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
            ),
          );
        }

        final day = index - firstDayWeekday + 1;
        return _buildDayCell(context, day);
      },
    );
  }

  Widget _buildDayCell(BuildContext context, int day) {
    final isSelected = selectedDate?.year == year && 
                      selectedDate?.month == month && 
                      selectedDate?.day == day;
    final isToday = _isToday(day);
    final dayEvents = _getEventsForDay(day);
    final dayHolidays = holidays.where((h) => h.day == day).toList();
    final hasHoliday = dayHolidays.isNotEmpty;
    
    return GestureDetector(
      onTap: () => onDaySelected?.call(day),
      child: Container(
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(context, isSelected, isToday, hasHoliday),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                CalendarUtils.toPersianNumber(day),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                  color: _getDayTextColor(context, isSelected, isToday, hasHoliday),
                ),
              ),
            ),
            if (dayEvents.isNotEmpty)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (hasHoliday)
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getHolidayColor(dayHolidays.first.type),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDayBackgroundColor(BuildContext context, bool isSelected, bool isToday, bool hasHoliday) {
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

  Color _getDayTextColor(BuildContext context, bool isSelected, bool isToday, bool hasHoliday) {
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

  bool _isToday(int day) {
    final now = DateTime.now();
    final todayJalali = JalaliDate.fromGregorian(now);
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
}