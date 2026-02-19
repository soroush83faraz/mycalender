import 'dart:ui';

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
  final bool usePersianNumbers;

  const ModernCalendarGrid({
    Key? key,
    required this.year,
    required this.month,
    this.selectedDate,
    this.onDaySelected,
    this.events = const [],
    this.holidays = const [],
    this.usePersianNumbers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarUtils.getDaysInMonth(year, month);
    final firstDayWeekday = CalendarUtils.getFirstDayOfMonth(year, month);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.lightBlueAccent.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            children: [
              _buildWeekdayHeaders(context),
              const SizedBox(height: 8),
              _buildCalendarDays(context, daysInMonth, firstDayWeekday),
            ],
          ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.66),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarDays(BuildContext context, int daysInMonth, int firstDayWeekday) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        if (index < firstDayWeekday || index >= firstDayWeekday + daysInMonth) {
          return const SizedBox.shrink();
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(context, isSelected, isToday, hasHoliday),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getDayBorderColor(context, isSelected, isToday),
            width: isSelected ? 1.3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.33),
                blurRadius: 16,
                spreadRadius: 1.5,
                offset: const Offset(0, 0),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                CalendarUtils.formatNumber(day, usePersian: usePersianNumbers),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                  color: _getDayTextColor(context, isSelected, isToday, hasHoliday),
                ),
              ),
            ),
            if (dayEvents.isNotEmpty)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (hasHoliday)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  width: 6,
                  height: 6,
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
      return Theme.of(context).colorScheme.primary.withOpacity(0.28);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.16);
    }
    if (hasHoliday) {
      return Colors.red.withOpacity(0.12);
    }
    return Colors.white.withOpacity(0.06);
  }

  Color _getDayBorderColor(BuildContext context, bool isSelected, bool isToday) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    }
    if (isToday) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.5);
    }
    return Colors.white.withOpacity(0.2);
  }

  Color _getDayTextColor(BuildContext context, bool isSelected, bool isToday, bool hasHoliday) {
    if (isSelected) {
      return Colors.white;
    }
    if (isToday) {
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.96);
    }
    if (hasHoliday) {
      return Colors.red.shade300;
    }
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.88);
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
