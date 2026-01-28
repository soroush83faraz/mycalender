import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar/models/jalali_date.dart';
import 'package:persian_calendar/utils/calendar_utils.dart';

void main() {
  group('Jalali Calendar Tests', () {
    test('Jalali date conversion should work correctly', () {
      // Test converting a known date
      final gregorian = DateTime(2024, 1, 1);
      final jalali = JalaliDate.fromGregorian(gregorian);
      
      expect(jalali.year, 1402);
      expect(jalali.month, 10);
      expect(jalali.day, 11);
    });

    test('Month names should be in Persian', () {
      final jalali = JalaliDate(year: 1403, month: 1, day: 1);
      expect(jalali.getMonthName(), 'فروردین');
    });

    test('Days in month calculation should be correct', () {
      // First 6 months have 31 days
      expect(CalendarUtils.getDaysInMonth(1403, 1), 31);
      expect(CalendarUtils.getDaysInMonth(1403, 6), 31);
      
      // Months 7-11 have 30 days
      expect(CalendarUtils.getDaysInMonth(1403, 7), 30);
      expect(CalendarUtils.getDaysInMonth(1403, 11), 30);
      
      // Month 12 depends on leap year
      expect(CalendarUtils.getDaysInMonth(1403, 12), 30); // Leap year
      expect(CalendarUtils.getDaysInMonth(1402, 12), 29); // Non-leap year
    });

    test('Persian number conversion should work', () {
      expect(CalendarUtils.toPersianNumber(1403), '۱۴۰۳');
      expect(CalendarUtils.toPersianNumber(25), '۲۵');
    });

    test('Weekday names should be in Persian', () {
      expect(JalaliDate.getWeekdayName(0), 'شنبه');
      expect(JalaliDate.getWeekdayName(6), 'جمعه');
    });
  });
}