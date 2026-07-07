import '../models/jalali_date.dart';

class DateConversionService {
  // Convert Jalali to Gregorian. Delegates to the single verified conversion
  // in JalaliDate so every part of the app produces identical dates.
  static DateTime jalaliToGregorian(JalaliDate jalali) {
    return jalali.toGregorian();
  }

  // Convert Gregorian to Lunar (Hijri)
  static Map<String, int> gregorianToHijri(DateTime gregorian) {
    int gy = gregorian.year;
    int gm = gregorian.month;
    int gd = gregorian.day;

    // Calculate Julian Day Number
    int a = (14 - gm) ~/ 12;
    int y = gy - a;
    int m = gm + 12 * a - 3;
    int jd = gd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 + 1721119;

    // Convert to Hijri
    int l = jd - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    int hm = (24 * l) ~/ 709;
    int hd = l - (709 * hm) ~/ 24;
    int hy = 30 * n + j - 30;

    return {'year': hy, 'month': hm, 'day': hd};
  }

  // Get Hijri month names
  static List<String> getHijriMonthNames() => [
    'محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاول', 'جمادی الثانی',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذی القعده', 'ذی الحجه'
  ];

  // Calculate age
  static Map<String, int> calculateAge(DateTime birthDate, DateTime currentDate) {
    int years = currentDate.year - birthDate.year;
    int months = currentDate.month - birthDate.month;
    int days = currentDate.day - birthDate.day;

    if (days < 0) {
      months--;
      days += DateTime(currentDate.year, currentDate.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  // Calculate difference between two dates
  static Map<String, int> dateDifference(DateTime date1, DateTime date2) {
    Duration diff = date2.difference(date1);
    int totalDays = diff.inDays.abs();
    int years = totalDays ~/ 365;
    int months = (totalDays % 365) ~/ 30;

    return {'years': years, 'months': months, 'days': totalDays};
  }

  // A Jalali year is leap when it has 366 days; derived from the same
  // conversion the rest of the app uses (the 2820-cycle formula previously
  // here disagreed with it for years like 1403/1404).
  static bool isJalaliLeapYear(int year) {
    final startOfYear = JalaliDate(year: year, month: 1, day: 1).toGregorian();
    final startOfNextYear =
        JalaliDate(year: year + 1, month: 1, day: 1).toGregorian();
    return startOfNextYear.difference(startOfYear).inDays == 366;
  }

  static bool isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}