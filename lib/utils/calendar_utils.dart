import '../models/jalali_date.dart';

class CalendarUtils {
  /// Get the first day of the month (0 = Saturday, 1 = Sunday, ..., 6 = Friday)
  static int getFirstDayOfMonth(int year, int month) {
    try {
      final jalali = JalaliDate(year: year, month: month, day: 1);
      final gregorian = jalali.toGregorian();
      return gregorianWeekdayToPersianIndex(gregorian.weekday);
    } catch (e) { 
      return 0; // Default to Saturday if conversion fails
    }
  }

  /// Convert Gregorian weekday index (Mon=1..Sun=7) to Persian index (Sat=0..Fri=6)
  static int gregorianWeekdayToPersianIndex(int weekday) {
    return (weekday + 2) % 7;
  }

  /// Get Persian weekday name directly from a Gregorian date
  static String getPersianWeekdayNameFromGregorian(DateTime date) {
    return JalaliDate.getWeekdayName(
      gregorianWeekdayToPersianIndex(date.weekday),
    );
  }

  /// Get the number of days in a Jalali month
  static int getDaysInMonth(int year, int month) {
    if (month >= 1 && month <= 6) {
      return 31;
    } else if (month >= 7 && month <= 11) {
      return 30;
    } else {
      // Month 12 (Esfand)
      return isLeapYear(year) ? 30 : 29;
    }
  }

  /// Check if a year is a leap year in Jalali calendar
  static bool isLeapYear(int year) {
    final cycle = year + 1474;
    final aux = ((cycle % 2820) + 474) % 2816;
    return (aux + 38) * 682 % 2816 < 682;
  }

  /// Convert Jalali date to Gregorian
  static DateTime toGregorian(JalaliDate jalali) {
    return jalali.toGregorian();
  }

  static bool isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get the Persian number representation
  static String toPersianNumber(dynamic number) {
    const Map<String, String> persianDigits = {
      '0': '۰',
      '1': '۱',
      '2': '۲',
      '3': '۳',
      '4': '۴',
      '5': '۵',
      '6': '۶',
      '7': '۷',
      '8': '۸',
      '9': '۹',
    };
    return number.toString().split('').map((e) => persianDigits[e] ?? e).join();
  }

  /// Convert Persian numbers to English
  static String toEnglishNumber(String persianNumber) {
    const Map<String, String> englishDigits = {
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };
    return persianNumber.split('').map((e) => englishDigits[e] ?? e).join();
  }

  /// Get Persian weekday name by index
  static String getPersianWeekdayName(int weekdayIndex) {
    const List<String> weekdays = [
      'شنبه', 'یکشنبه', 'دوشنبه', 'سهشنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'
    ];
    return weekdays[weekdayIndex % 7];
  }

  /// Format time in Persian
  static String formatPersianTime(DateTime dateTime) {
    return '${toPersianNumber(dateTime.hour)}:${toPersianNumber(dateTime.minute.toString().padLeft(2, '0'))}';
  }

  /// Get season name in Persian
  static String getSeasonName(int month) {
    if (month >= 1 && month <= 3) return 'بهار';
    if (month >= 4 && month <= 6) return 'تابستان';
    if (month >= 7 && month <= 9) return 'پاییز';
    return 'زمستان';
  }
}
