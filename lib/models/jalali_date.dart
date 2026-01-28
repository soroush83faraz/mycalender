class JalaliDate {
  int year;
  int month;
  int day;

  JalaliDate({required this.year, required this.month, required this.day});

  /// Convert Gregorian date to Jalali date
  static JalaliDate fromGregorian(DateTime gregorian) {
    int gy = gregorian.year;
    int gm = gregorian.month;
    int gd = gregorian.day;

    int jy, jm, jd;
    
    if (gy <= 1600) {
      jy = 0; jm = 1; jd = 1;
    } else {
      jy = 979;
      gy -= 1600;
      
      int totalDays = 365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400) - 80 + gd;
      
      List<int> monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (((gy + 1600) % 4 == 0 && (gy + 1600) % 100 != 0) || (gy + 1600) % 400 == 0) {
        monthDays[1] = 29;
      }
      
      for (int i = 0; i < gm - 1; i++) {
        totalDays += monthDays[i];
      }
      
      jy += 33 * (totalDays ~/ 12053);
      totalDays %= 12053;
      
      jy += 4 * (totalDays ~/ 1461);
      totalDays %= 1461;
      
      if (totalDays >= 366) {
        jy += (totalDays - 1) ~/ 365;
        totalDays = (totalDays - 1) % 365;
      }
      
      if (totalDays < 186) {
        jm = 1 + totalDays ~/ 31;
        jd = 1 + (totalDays % 31);
      } else {
        jm = 7 + (totalDays - 186) ~/ 30;
        jd = 1 + ((totalDays - 186) % 30);
      }
    }
    
    return JalaliDate(year: jy, month: jm, day: jd);
  }

  /// Get the name of the month in Persian
  String getMonthName() {
    const List<String> monthNames = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];
    return monthNames[month - 1];
  }

  /// Get the name of the weekday in Persian
  static String getWeekdayName(int weekday) {
    const List<String> weekdayNames = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سهشنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ];
    return weekdayNames[weekday % 7];
  }

  @override
  String toString() => '$year/$month/$day';
  
  /// Convert Jalali to Gregorian
  DateTime toGregorian() {
    int jy = year;
    int jm = month;
    int jd = day;
    
    int totalDays = 365 * jy + ((jy + 33) ~/ 128) * 683 + ((jy + 33) % 128) ~/ 4 * 1461 + (((jy + 33) % 128) % 4) * 365;
    
    for (int i = 1; i < jm; i++) {
      if (i <= 6) {
        totalDays += 31;
      } else if (i <= 11) {
        totalDays += 30;
      } else {
        totalDays += ((jy % 33 * 8 + (jy % 33 + 3) ~/ 4) % 128 < 29) ? 29 : 30;
      }
    }
    
    totalDays += jd + 1948321;
    
    int gy = 1600 + 400 * ((totalDays - 1721426) ~/ 146097);
    totalDays = (totalDays - 1721426) % 146097;
    
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
    if ((gy % 4 == 0 && gy % 100 != 0) || gy % 400 == 0) monthDays[1] = 29;
    
    int gm = 1;
    while (totalDays >= monthDays[gm - 1]) {
      totalDays -= monthDays[gm - 1];
      gm++;
    }
    
    return DateTime(gy, gm, totalDays + 1);
  }
}