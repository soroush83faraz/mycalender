import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar/models/jalali_date.dart';
import 'package:persian_calendar/services/date_conversion_service.dart';
import 'package:persian_calendar/utils/calendar_utils.dart';

void main() {
  group('Jalali <-> Gregorian reference dates', () {
    // Known equivalences (official Iranian calendar).
    const cases = <List<int>>[
      // [jy, jm, jd, gy, gm, gd]
      [1400, 1, 1, 2021, 3, 21],
      [1401, 1, 1, 2022, 3, 21],
      [1402, 1, 1, 2023, 3, 21],
      [1403, 1, 1, 2024, 3, 20],
      [1404, 1, 1, 2025, 3, 21],
      [1405, 1, 1, 2026, 3, 21],
      [1403, 12, 30, 2025, 3, 20], // 1403 is leap: Esfand has 30 days
      [1404, 12, 29, 2026, 3, 20], // 1404 is not leap
      [1404, 6, 31, 2025, 9, 22], // last day of Shahrivar
      [1404, 7, 1, 2025, 9, 23], // first day of Mehr
      [1405, 4, 12, 2026, 7, 3],
      [1357, 11, 22, 1979, 2, 11],
      [1300, 1, 1, 1921, 3, 21],
      [1450, 1, 1, 2071, 3, 21],
    ];

    for (final c in cases) {
      test('${c[0]}/${c[1]}/${c[2]} <-> ${c[3]}-${c[4]}-${c[5]}', () {
        final jalali = JalaliDate(year: c[0], month: c[1], day: c[2]);
        final gregorian = jalali.toGregorian();
        expect(gregorian.year, c[3]);
        expect(gregorian.month, c[4]);
        expect(gregorian.day, c[5]);

        final back = JalaliDate.fromGregorian(DateTime(c[3], c[4], c[5]));
        expect(back.year, c[0]);
        expect(back.month, c[1]);
        expect(back.day, c[2]);
      });
    }
  });

  test('DateConversionService.jalaliToGregorian matches JalaliDate', () {
    final jalali = JalaliDate(year: 1405, month: 4, day: 12);
    expect(
      DateConversionService.jalaliToGregorian(jalali),
      DateTime(2026, 7, 3),
    );
  });

  test('round-trip is lossless for every day of 1390..1420', () {
    for (var year = 1390; year <= 1420; year++) {
      for (var month = 1; month <= 12; month++) {
        final days = CalendarUtils.getDaysInMonth(year, month);
        for (var day = 1; day <= days; day++) {
          final jalali = JalaliDate(year: year, month: month, day: day);
          final g = jalali.toGregorian();
          final back = JalaliDate.fromGregorian(g);
          expect('${back.year}/${back.month}/${back.day}',
              '$year/$month/$day',
              reason: 'round-trip failed for $year/$month/$day via $g');
        }
      }
    }
  });

  test('consecutive Jalali days map to consecutive Gregorian days', () {
    // Compare calendar dates in UTC so historical Iran DST transitions in the
    // local timezone cannot skew the day arithmetic.
    DateTime asUtcDate(DateTime d) => DateTime.utc(d.year, d.month, d.day);
    var previous =
        asUtcDate(JalaliDate(year: 1395, month: 1, day: 1).toGregorian());
    for (var year = 1395; year <= 1410; year++) {
      for (var month = 1; month <= 12; month++) {
        final days = CalendarUtils.getDaysInMonth(year, month);
        for (var day = 1; day <= days; day++) {
          if (year == 1395 && month == 1 && day == 1) continue;
          final g = asUtcDate(
              JalaliDate(year: year, month: month, day: day).toGregorian());
          expect(g.difference(previous).inDays, 1,
              reason: '$year/$month/$day is not exactly one day after '
                  'the previous date (got $g after $previous)');
          previous = g;
        }
      }
    }
  });

  test('leap years agree between service and calendar utils', () {
    // 1399 and 1403 are leap; 1400-1402, 1404, 1405 are not.
    expect(DateConversionService.isJalaliLeapYear(1399), isTrue);
    expect(DateConversionService.isJalaliLeapYear(1403), isTrue);
    expect(DateConversionService.isJalaliLeapYear(1404), isFalse);
    expect(DateConversionService.isJalaliLeapYear(1405), isFalse);
    for (var year = 1370; year <= 1440; year++) {
      expect(DateConversionService.isJalaliLeapYear(year),
          CalendarUtils.isLeapYear(year),
          reason: 'leap-year mismatch for $year');
    }
  });
}
