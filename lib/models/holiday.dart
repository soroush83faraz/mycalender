import '../services/date_conversion_service.dart';
import '../utils/calendar_utils.dart';
import 'jalali_date.dart';

/// A calendar occasion.
///
/// The [month]/[day] are interpreted according to [calendarType]:
///  - `jalali`    → fixed Persian-calendar date (Nowruz, national days, ancient
///    festivals). Same Jalali date every year.
///  - `hijri`     → Islamic lunar date (Eid, Ashura, ...). These drift ~11 days
///    each solar year, so they are resolved dynamically per displayed year.
///  - `gregorian` → fixed Gregorian date (international days).
///
/// [isDayOff] marks an official day off (shown in red on the grid), as opposed
/// to a cultural/international occasion that is only marked with a colored dot.
class Holiday {
  final String name;
  final int month;
  final int day;
  final String type; // 'official' | 'religious' | 'ancient' | 'international'
  final String description;
  final String calendarType; // 'jalali' | 'hijri' | 'gregorian'
  final bool isDayOff;

  const Holiday({
    required this.name,
    required this.month,
    required this.day,
    required this.type,
    this.description = '',
    this.calendarType = 'jalali',
    this.isDayOff = true,
  });

  Holiday _resolvedTo(int jMonth, int jDay) => Holiday(
        name: name,
        month: jMonth,
        day: jDay,
        type: type,
        description: description,
        calendarType: 'jalali',
        isDayOff: isDayOff,
      );

  // ── Master catalogue ──────────────────────────────────────────────────────
  static const List<Holiday> all = [
    // ── Official (fixed Jalali, day off) ──
    Holiday(name: 'نوروز', month: 1, day: 1, type: 'official', description: 'آغاز سال نو'),
    Holiday(name: 'عید نوروز', month: 1, day: 2, type: 'official'),
    Holiday(name: 'عید نوروز', month: 1, day: 3, type: 'official'),
    Holiday(name: 'عید نوروز', month: 1, day: 4, type: 'official'),
    Holiday(name: 'روز جمهوری اسلامی', month: 1, day: 12, type: 'official'),
    Holiday(name: 'روز طبیعت', month: 1, day: 13, type: 'official', description: 'سیزده‌بدر'),
    Holiday(name: 'رحلت امام خمینی', month: 3, day: 14, type: 'official'),
    Holiday(name: 'قیام ۱۵ خرداد', month: 3, day: 15, type: 'official'),
    Holiday(name: 'پیروزی انقلاب اسلامی', month: 11, day: 22, type: 'official'),
    Holiday(name: 'ملی‌شدن صنعت نفت', month: 12, day: 29, type: 'official'),

    // ── Religious (Hijri lunar, day off) ──
    Holiday(name: 'تاسوعای حسینی', month: 1, day: 9, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'عاشورای حسینی', month: 1, day: 10, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'اربعین حسینی', month: 2, day: 20, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'رحلت پیامبر و شهادت امام حسن', month: 2, day: 28, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'شهادت امام رضا', month: 2, day: 30, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'شهادت امام حسن عسکری', month: 3, day: 8, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'میلاد پیامبر و امام صادق', month: 3, day: 17, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'شهادت حضرت فاطمه', month: 6, day: 3, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'ولادت امام علی', month: 7, day: 13, type: 'religious', calendarType: 'hijri', isDayOff: false),
    Holiday(name: 'مبعث رسول اکرم', month: 7, day: 27, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'ولادت امام زمان', month: 8, day: 15, type: 'religious', calendarType: 'hijri', isDayOff: false),
    Holiday(name: 'شهادت امام علی', month: 9, day: 21, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'عید سعید فطر', month: 10, day: 1, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'تعطیل عید فطر', month: 10, day: 2, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'شهادت امام صادق', month: 10, day: 25, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'عید سعید قربان', month: 12, day: 10, type: 'religious', calendarType: 'hijri'),
    Holiday(name: 'عید سعید غدیر خم', month: 12, day: 18, type: 'religious', calendarType: 'hijri'),

    // ── Ancient / Persian festivals (fixed Jalali, not a day off) ──
    Holiday(name: 'جشن سده', month: 11, day: 10, type: 'ancient', description: 'جشن میانه زمستان', isDayOff: false),
    Holiday(name: 'چهارشنبه‌سوری', month: 12, day: 24, type: 'ancient', description: 'آخرین چهارشنبه سال', isDayOff: false),
    Holiday(name: 'جشن تیرگان', month: 4, day: 13, type: 'ancient', description: 'جشن آب و باران', isDayOff: false),
    Holiday(name: 'جشن مهرگان', month: 7, day: 16, type: 'ancient', description: 'جشن مهر و دوستی', isDayOff: false),
    Holiday(name: 'شب یلدا', month: 9, day: 30, type: 'ancient', description: 'شب چله؛ بلندترین شب سال', isDayOff: false),

    // ── International (fixed Gregorian, not a day off) ──
    Holiday(name: 'سال نو میلادی', month: 1, day: 1, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی زبان مادری', month: 2, day: 21, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی زن', month: 3, day: 8, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی بهداشت', month: 4, day: 7, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی زمین', month: 4, day: 22, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی کارگر', month: 5, day: 1, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی محیط زیست', month: 6, day: 5, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی صلح', month: 9, day: 21, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی معلم', month: 10, day: 5, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی کودک', month: 11, day: 20, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'روز جهانی حقوق بشر', month: 12, day: 10, type: 'international', calendarType: 'gregorian', isDayOff: false),
    Holiday(name: 'کریسمس', month: 12, day: 25, type: 'international', calendarType: 'gregorian', isDayOff: false),
  ];

  /// Occasions that fall on a specific Jalali date (resolving lunar/gregorian
  /// ones for that exact day).
  static List<Holiday> occurrencesOnDate(JalaliDate date) {
    final g = date.toGregorian();
    final h = DateConversionService.gregorianToHijri(g);
    final result = <Holiday>[];
    for (final o in all) {
      bool match;
      switch (o.calendarType) {
        case 'hijri':
          match = o.month == h['month'] && o.day == h['day'];
          break;
        case 'gregorian':
          match = o.month == g.month && o.day == g.day;
          break;
        default:
          match = o.month == date.month && o.day == date.day;
      }
      if (match) result.add(o._resolvedTo(date.month, date.day));
    }
    return result;
  }

  /// All occasions within a Jalali month, each resolved to its actual Jalali
  /// day-of-month so the grid can mark it. Handles lunar/gregorian drift.
  static List<Holiday> occurrencesForJalaliMonth(int jYear, int jMonth) {
    final days = CalendarUtils.getDaysInMonth(jYear, jMonth);
    final result = <Holiday>[];
    for (var day = 1; day <= days; day++) {
      result.addAll(occurrencesOnDate(
        JalaliDate(year: jYear, month: jMonth, day: day),
      ));
    }
    return result;
  }

  /// All occasions across a whole Jalali year (used for browsing/search).
  static List<Holiday> occurrencesForJalaliYear(int jYear) {
    final result = <Holiday>[];
    for (var m = 1; m <= 12; m++) {
      for (final h in occurrencesForJalaliMonth(jYear, m)) {
        result.add(h);
      }
    }
    return result;
  }
}
