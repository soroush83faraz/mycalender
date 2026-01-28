class Holiday {
  final String name;
  final int month;
  final int day;
  final String type; // 'official', 'religious', 'international', 'ancient'
  final String description;
  final bool isFixed;

  Holiday({
    required this.name,
    required this.month,
    required this.day,
    required this.type,
    this.description = '',
    this.isFixed = true,
  });

  static List<Holiday> getPersianHolidays() => [
    // Official holidays
    Holiday(name: 'نوروز', month: 1, day: 1, type: 'official', description: 'آغاز سال نو'),
    Holiday(name: 'دومین روز نوروز', month: 1, day: 2, type: 'official'),
    Holiday(name: 'سومین روز نوروز', month: 1, day: 3, type: 'official'),
    Holiday(name: 'چهارمین روز نوروز', month: 1, day: 4, type: 'official'),
    Holiday(name: 'روز طبیعت', month: 1, day: 13, type: 'official', description: 'سیزده بدر'),
    Holiday(name: 'رحلت امام خمینی', month: 3, day: 14, type: 'religious'),
    Holiday(name: 'قیام ۱۵ خرداد', month: 3, day: 15, type: 'official'),
    Holiday(name: 'شهادت امام علی', month: 4, day: 21, type: 'religious'),
    Holiday(name: 'عید فطر', month: 4, day: 22, type: 'religious'),
    Holiday(name: 'تعطیل عید فطر', month: 4, day: 23, type: 'religious'),
    Holiday(name: 'شهادت امام صادق', month: 5, day: 25, type: 'religious'),
    Holiday(name: 'عید قربان', month: 6, day: 29, type: 'religious'),
    Holiday(name: 'عید غدیر خم', month: 7, day: 7, type: 'religious'),
    Holiday(name: 'تاسوعا', month: 7, day: 28, type: 'religious'),
    Holiday(name: 'عاشورا', month: 7, day: 29, type: 'religious'),
    Holiday(name: 'اربعین حسینی', month: 9, day: 8, type: 'religious'),
    Holiday(name: 'رحلت پیامبر و شهادت امام حسن', month: 9, day: 28, type: 'religious'),
    Holiday(name: 'شهادت امام رضا', month: 10, day: 29, type: 'religious'),
    Holiday(name: 'میلاد پیامبر و امام صادق', month: 11, day: 17, type: 'religious'),
    Holiday(name: 'پیروزی انقلاب اسلامی', month: 11, day: 22, type: 'official'),
    Holiday(name: 'روز ملی شدن صنعت نفت', month: 12, day: 29, type: 'official'),
    
    // Ancient Persian holidays
    Holiday(name: 'جشن تیرگان', month: 4, day: 13, type: 'ancient', description: 'جشن آب و باران'),
    Holiday(name: 'جشن مهرگان', month: 7, day: 16, type: 'ancient', description: 'جشن مهر و دوستی'),
    Holiday(name: 'شب یلدا', month: 9, day: 30, type: 'ancient', description: 'شب چله - طولانی‌ترین شب سال'),
    Holiday(name: 'جشن سده', month: 11, day: 10, type: 'ancient', description: 'جشن میانه زمستان'),
    Holiday(name: 'چهارشنبه سوری', month: 12, day: 25, type: 'ancient', description: 'آخرین چهارشنبه سال'),
  ];

  static List<Holiday> getHolidaysForMonth(int month) =>
      getPersianHolidays().where((h) => h.month == month).toList();
}