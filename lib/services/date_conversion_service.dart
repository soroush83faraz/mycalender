import '../models/jalali_date.dart';

class DateConversionService {
  // Convert Jalali to Gregorian
  static DateTime jalaliToGregorian(JalaliDate jalali) {
    int jy = jalali.year;
    int jm = jalali.month;
    int jd = jalali.day;

    int totalDays = 365 * jy + ((jy + 1474) ~/ 2820) * 1029983;
    totalDays += (((jy + 1474) % 2820 + 474) ~/ 2816) * 682;
    
    for (int i = 1; i < jm; i++) {
      if (i <= 6) totalDays += 31;
      else if (i <= 11) totalDays += 30;
      else totalDays += isJalaliLeapYear(jy) ? 30 : 29;
    }
    totalDays += jd - 1;

    // Convert to Gregorian
    totalDays += 227015; // Epoch difference
    
    int gy = 1600 + 400 * (totalDays ~/ 146097);
    totalDays %= 146097;
    
    if (totalDays >= 36525) {
      totalDays--;
      gy += 100 * (totalDays ~/ 36524);
      totalDays %= 36524;
      if (totalDays >= 365) totalDays++;
    }
    
    gy += 4 * (totalDays ~/ 1461);
    totalDays %= 1461;
    
    if (totalDays >= 366) {
      totalDays--;
      gy += totalDays ~/ 365;
      totalDays %= 365;
    }
    
    List<int> monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (isGregorianLeapYear(gy)) monthDays[1] = 29;
    
    int gm = 1;
    while (totalDays >= monthDays[gm - 1]) {
      totalDays -= monthDays[gm - 1];
      gm++;
    }
    
    return DateTime(gy, gm, totalDays + 1);
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

  static bool isJalaliLeapYear(int year) {
    final cycle = year + 1474;
    final aux = ((cycle % 2820) + 474) % 2816;
    return (aux + 38) * 682 % 2816 < 682;
  }

  static bool isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}