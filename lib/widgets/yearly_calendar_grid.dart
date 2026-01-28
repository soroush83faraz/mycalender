import 'package:flutter/material.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../utils/calendar_utils.dart';

class YearlyCalendarGrid extends StatelessWidget {
  final int year;
  final JalaliDate? selectedDate;
  final Function(int, int)? onMonthSelected;
  final List<Event> events;
  final List<Holiday> holidays;

  const YearlyCalendarGrid({
    Key? key,
    required this.year,
    this.selectedDate,
    this.onMonthSelected,
    this.events = const [],
    this.holidays = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        return _buildMonthCard(context, month);
      },
    );
  }

  Widget _buildMonthCard(BuildContext context, int month) {
    final monthName = JalaliDate(year: year, month: month, day: 1).getMonthName();
    final daysInMonth = CalendarUtils.getDaysInMonth(year, month);
    final firstDayWeekday = CalendarUtils.getFirstDayOfMonth(year, month);
    final monthEvents = _getEventsForMonth(month);
    final monthHolidays = Holiday.getHolidaysForMonth(month);
    final isCurrentMonth = selectedDate?.year == year && selectedDate?.month == month;
    
    return Card(
      elevation: isCurrentMonth ? 3 : 1,
      color: isCurrentMonth ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => onMonthSelected?.call(year, month),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCurrentMonth 
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _buildMiniCalendar(context, month, daysInMonth, firstDayWeekday),
              ),
              if (monthEvents.isNotEmpty || monthHolidays.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (monthEvents.isNotEmpty) ...[
                        Icon(
                          Icons.event,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          CalendarUtils.toPersianNumber(monthEvents.length),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                      if (monthEvents.isNotEmpty && monthHolidays.isNotEmpty)
                        const SizedBox(width: 8),
                      if (monthHolidays.isNotEmpty) ...[
                        Icon(
                          Icons.celebration,
                          size: 12,
                          color: Colors.red,
                        ),
                        Text(
                          CalendarUtils.toPersianNumber(monthHolidays.length),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(BuildContext context, int month, int daysInMonth, int firstDayWeekday) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: 35,
        itemBuilder: (context, index) {
          if (index < firstDayWeekday || index >= firstDayWeekday + daysInMonth) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
                ),
              ),
            );
          }

          final day = index - firstDayWeekday + 1;
          final isToday = _isToday(month, day);
          final isSelected = selectedDate?.year == year && 
                            selectedDate?.month == month && 
                            selectedDate?.day == day;
          
          return Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : null,
              border: Border(
                right: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                CalendarUtils.toPersianNumber(day),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isToday(int month, int day) {
    final now = DateTime.now();
    final todayJalali = JalaliDate.fromGregorian(now);
    return todayJalali.year == year &&
        todayJalali.month == month &&
        todayJalali.day == day;
  }

  List<Event> _getEventsForMonth(int month) {
    return events.where((event) {
      final eventJalali = JalaliDate.fromGregorian(event.date);
      return eventJalali.year == year && eventJalali.month == month;
    }).toList();
  }
}