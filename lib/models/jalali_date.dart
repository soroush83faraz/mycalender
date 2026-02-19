class JalaliDate {
  int year;
  int month;
  int day;

  JalaliDate({required this.year, required this.month, required this.day});

  /// Convert Gregorian date to Jalali date
  static JalaliDate fromGregorian(DateTime gregorian) {
    int gy = gregorian.year - 1600;
    int gm = gregorian.month - 1;
    int gd = gregorian.day - 1;

    final gdm = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    int gDayNo =
        365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400);

    for (int i = 0; i < gm; i++) {
      gDayNo += gdm[i];
    }

    final isLeapGregorian = ((gy + 1600) % 4 == 0 && (gy + 1600) % 100 != 0) ||
        ((gy + 1600) % 400 == 0);
    if (gm > 1 && isLeapGregorian) {
      gDayNo++;
    }
    gDayNo += gd;

    int jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    int jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    final jdm = <int>[31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    int jm = 0;
    while (jm < 11 && jDayNo >= jdm[jm]) {
      jDayNo -= jdm[jm];
      jm++;
    }

    return JalaliDate(year: jy, month: jm + 1, day: jDayNo + 1);
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
    int jy = year - 979;
    int jm = month - 1;
    int jd = day - 1;

    final jdm = <int>[31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    int jDayNo = 365 * jy + (jy ~/ 33) * 8 + ((jy % 33) + 3) ~/ 4;

    for (int i = 0; i < jm; i++) {
      jDayNo += jdm[i];
    }
    jDayNo += jd;

    int gDayNo = jDayNo + 79;
    int gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;

    bool leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;

      if (gDayNo >= 365) {
        gDayNo++;
      } else {
        leap = false;
      }
    }

    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;

    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }

    final gdm = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (leap) {
      gdm[1] = 29;
    }

    int gm = 0;
    while (gm < 11 && gDayNo >= gdm[gm]) {
      gDayNo -= gdm[gm];
      gm++;
    }

    return DateTime(gy, gm + 1, gDayNo + 1);
  }
}
