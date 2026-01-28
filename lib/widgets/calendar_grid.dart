import 'package:flutter/material.dart';
import '../models/jalali_date.dart';
import '../utils/calendar_utils.dart';

class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Function(int)? onDaySelected;
  final int? selectedDay;

  const CalendarGrid({
    Key? key,
    required this.year,
    required this.month,
    this.onDaySelected,
    this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarUtils.getDaysInMonth(year, month);
    final firstDayWeekday = CalendarUtils.getFirstDayOfMonth(year, month);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Weekday headers
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              'شنبه',
              'یکشنبه',
              'دوشنبه',
              'سه‌شنبه',
              'چهارشنبه',
              'پنج‌شنبه',
              'جمعه',
            ]
                .map((day) => Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar days
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              if (index < firstDayWeekday ||
                  index >= firstDayWeekday + daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = index - firstDayWeekday + 1;
              final isSelected = selectedDay == day;
              final isToday = _isToday(day);

              return GestureDetector(
                onTap: () => onDaySelected?.call(day),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.blue
                        : isToday
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      CalendarUtils.toPersianNumber(day),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    final todayJalali = JalaliDate.fromGregorian(now);
    return todayJalali.year == year &&
        todayJalali.month == month &&
        todayJalali.day == day;
  }
}
