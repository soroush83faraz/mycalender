// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'تقویم فارسی';

  @override
  String get navCalendar => 'تقویم';

  @override
  String get navEvents => 'رویدادها';

  @override
  String get navTools => 'ابزارها';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get today => 'امروز';

  @override
  String get tomorrow => 'فردا';

  @override
  String get past => 'گذشته';

  @override
  String get week => 'هفته';

  @override
  String get monthlyView => 'نمای ماهانه';

  @override
  String get weeklyView => 'نمای هفتگی';

  @override
  String get yearlyView => 'نمای سالانه';

  @override
  String get monthly => 'ماهانه';

  @override
  String get weekly => 'هفتگی';

  @override
  String get yearly => 'سالانه';

  @override
  String get selectedDate => 'تاریخ انتخاب شده';

  @override
  String prayerTimesFor(String city) {
    return 'اوقات شرعی ($city)';
  }

  @override
  String get currentLocation => 'موقعیت فعلی';

  @override
  String daysLeft(String count) {
    return '$count روز مانده';
  }

  @override
  String daysPassed(String count) {
    return '$count روز گذشته';
  }

  @override
  String get daysRemainingLabel => 'روز مانده';

  @override
  String get searchEvents => 'جستجو در رویدادها...';

  @override
  String get noEventsFound => 'هیچ رویدادی یافت نشد';

  @override
  String get addEventHint => 'برای افزودن رویداد جدید روی دکمه + کلیک کنید';

  @override
  String get categoryAll => 'همه';

  @override
  String get categoryPersonal => 'شخصی';

  @override
  String get categoryWork => 'کاری';

  @override
  String get categoryFamily => 'خانوادگی';

  @override
  String get categoryHealth => 'سلامت';

  @override
  String get categoryEducation => 'آموزشی';

  @override
  String get categoryOther => 'سایر';

  @override
  String get addEvent => 'افزودن رویداد';

  @override
  String get editEvent => 'ویرایش رویداد';

  @override
  String get saveEvent => 'ذخیره رویداد';

  @override
  String get deleteEvent => 'حذف رویداد';

  @override
  String get deleteEventConfirm => 'آیا مطمئن هستید که می‌خواهید این رویداد را حذف کنید؟';

  @override
  String get eventTitle => 'عنوان رویداد';

  @override
  String get enterEventTitle => 'لطفا عنوان رویداد را وارد کنید';

  @override
  String get descriptionOptional => 'توضیحات (اختیاری)';

  @override
  String get dateAndTime => 'تاریخ و زمان';

  @override
  String get category => 'دسته‌بندی';

  @override
  String get eventColor => 'رنگ رویداد';

  @override
  String get reminder => 'یادآوری';

  @override
  String get reminderSubtitle => 'دریافت اعلان برای این رویداد';

  @override
  String get reminderTime => 'زمان یادآوری';

  @override
  String get notSelected => 'انتخاب نشده';

  @override
  String get selectColor => 'انتخاب رنگ';

  @override
  String get cancel => 'لغو';

  @override
  String get confirm => 'تایید';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'بستن';

  @override
  String get continueLabel => 'ادامه';

  @override
  String failedToSaveEvent(String error) {
    return 'ذخیره رویداد ناموفق بود: $error';
  }

  @override
  String failedToDeleteEvent(String error) {
    return 'حذف رویداد ناموفق بود: $error';
  }

  @override
  String get settings => 'تنظیمات';

  @override
  String get signOut => 'خروج از حساب';

  @override
  String get signOutConfirm => 'آیا مطمئن هستید که می‌خواهید خارج شوید؟';

  @override
  String signOutFailed(String error) {
    return 'خروج ناموفق بود: $error';
  }

  @override
  String get appearanceTheme => 'ظاهر و تم';

  @override
  String get autoTheme => 'تم خودکار';

  @override
  String get autoThemeSub => 'تغییر خودکار بر اساس تنظیمات سیستم';

  @override
  String get darkMode => 'حالت تاریک';

  @override
  String get darkModeSub => 'استفاده از تم تاریک';

  @override
  String get primaryColor => 'رنگ اصلی';

  @override
  String get primaryColorSub => 'انتخاب رنگ اصلی اپلیکیشن';

  @override
  String get display => 'نمایش';

  @override
  String get persianNumbers => 'اعداد فارسی';

  @override
  String get persianNumbersSub => 'نمایش اعداد به صورت فارسی';

  @override
  String get showGregorian => 'نمایش تقویم میلادی';

  @override
  String get showGregorianSub => 'نمایش همزمان تاریخ میلادی';

  @override
  String get defaultView => 'نمای پیش‌فرض';

  @override
  String get selectDefaultView => 'انتخاب نمای پیش‌فرض';

  @override
  String get language => 'زبان';

  @override
  String get languageSub => 'انتخاب زبان برنامه';

  @override
  String get persianLang => 'فارسی';

  @override
  String get englishLang => 'English';

  @override
  String get notifications => 'اعلانات';

  @override
  String get enableNotifications => 'فعالسازی اعلانات';

  @override
  String get enableNotificationsSub => 'دریافت اعلان برای رویدادها و یادآورها';

  @override
  String get calendarSection => 'تقویم';

  @override
  String get showHolidays => 'نمایش مناسبت‌ها';

  @override
  String get showHolidaysSub => 'نمایش تعطیلات و مناسبت‌های رسمی';

  @override
  String get showEvents => 'نمایش رویدادها';

  @override
  String get showEventsSub => 'نمایش رویدادهای شخصی در تقویم';

  @override
  String get prayerTimes => 'اوقات شرعی';

  @override
  String get prayerTimesSub => 'نمایش اوقات شرعی';

  @override
  String get useDeviceLocation => 'استفاده از موقعیت دستگاه';

  @override
  String get useDeviceLocationSub => 'محاسبه اوقات شرعی بر اساس موقعیت فعلی';

  @override
  String get updateLocation => 'به‌روزرسانی موقعیت';

  @override
  String get noLocationSaved => 'موقعیتی ثبت نشده است';

  @override
  String savedLocation(String coords) {
    return 'موقعیت ثبت‌شده: $coords';
  }

  @override
  String get selectCity => 'انتخاب شهر';

  @override
  String get locationUpdated => 'موقعیت با موفقیت به‌روزرسانی شد';

  @override
  String get locationFailed => 'دسترسی به موقعیت امکان‌پذیر نشد؛ از شهر انتخابی استفاده می‌شود';

  @override
  String get aboutApp => 'درباره برنامه';

  @override
  String get version => 'نسخه';

  @override
  String get developer => 'توسعه‌دهنده';

  @override
  String get developerName => 'تیم توسعه تقویم فارسی';

  @override
  String get contactUs => 'ارتباط با ما';

  @override
  String get contactUsSub => 'ارسال بازخورد و پیشنهادات';

  @override
  String get contactBody => 'برای ارسال بازخورد، گزارش باگ یا پیشنهادات خود می‌توانید با ما در ارتباط باشید.\n\nایمیل: support@persiancalendar.com\nتلگرام: @PersianCalendarSupport';

  @override
  String get account => 'حساب کاربری';

  @override
  String get accountStatus => 'وضعیت';

  @override
  String get upgradeToGoogle => 'ارتقا به حساب گوگل';

  @override
  String get upgradeToGoogleSub => 'اتصال این حساب مهمان به گوگل';

  @override
  String get googleSync => 'همگام‌سازی با Google Calendar';

  @override
  String get googleSyncSub => 'ورود و خروج دوطرفه رویدادها با تقویم گوگل';

  @override
  String get syncing => 'در حال همگام‌سازی با Google Calendar...';

  @override
  String syncDone(String imported, String exported) {
    return 'همگام‌سازی انجام شد: $imported ورودی، $exported خروجی';
  }

  @override
  String get syncFailed => 'همگام‌سازی ناموفق بود. مطمئن شوید Google Calendar API فعال و دسترسی داده شده است.';

  @override
  String get tools => 'ابزارها';

  @override
  String get occasions => 'مناسبت‌ها';

  @override
  String get occasionsSub => 'مرور و جستجوی مناسبت‌های رسمی، مذهبی، باستانی و جهانی';

  @override
  String get searchOccasion => 'جستجوی مناسبت...';

  @override
  String get noResults => 'موردی یافت نشد';

  @override
  String get dayOff => 'تعطیل';

  @override
  String get catOfficial => 'رسمی';

  @override
  String get catReligious => 'مذهبی';

  @override
  String get catAncient => 'باستانی';

  @override
  String get catInternational => 'جهانی';

  @override
  String get dateConverter => 'تبدیل تاریخ';

  @override
  String get dateConverterSub => 'تبدیل بین تقویم شمسی، میلادی و قمری';

  @override
  String get ageCalculator => 'محاسبه سن';

  @override
  String get ageCalculatorSub => 'محاسبه سن بر اساس تاریخ تولد';

  @override
  String get dateDifference => 'اختلاف دو تاریخ';

  @override
  String get dateDifferenceSub => 'محاسبه فاصله زمانی بین دو تاریخ';

  @override
  String get countdown => 'روزشمار';

  @override
  String get countdownSub => 'شمارش روزهای باقیمانده تا رویداد';

  @override
  String get nowruzMoment => 'لحظه سال تحویل';

  @override
  String get nowruzMomentSub => 'نمایش زمان دقیق سال تحویل';

  @override
  String get worldClock => 'ساعت جهانی';

  @override
  String get worldClockSub => 'نمایش ساعت شهرهای مختلف جهان';

  @override
  String get jalaliCalendar => 'شمسی (هجری شمسی)';

  @override
  String get gregorianCalendar => 'میلادی (گریگوری)';

  @override
  String get hijriCalendar => 'قمری (هجری قمری)';

  @override
  String get selectDate => 'انتخاب تاریخ';

  @override
  String get selectGregorianDate => 'انتخاب تاریخ میلادی';

  @override
  String get fromGregorian => 'مبدا میلادی';

  @override
  String get fromJalali => 'مبدا شمسی';

  @override
  String get convertFromJalali => 'تبدیل از شمسی';

  @override
  String get yearLabel => 'سال';

  @override
  String get monthLabel => 'ماه';

  @override
  String get dayLabel => 'روز';

  @override
  String get enterNumericDate => 'سال، ماه و روز را به صورت عددی وارد کنید.';

  @override
  String get monthRangeError => 'ماه باید بین 1 تا 12 باشد.';

  @override
  String dayRangeError(String max) {
    return 'روز برای این ماه باید بین 1 تا $max باشد.';
  }

  @override
  String get selectBirthDate => 'انتخاب تاریخ تولد';

  @override
  String get birthDateSelected => 'تاریخ تولد انتخاب شده';

  @override
  String get yourAge => 'سن شما';

  @override
  String get ageDifference => 'اختلاف سن';

  @override
  String ageResult(String years, String months, String days) {
    return '$years سال، $months ماه، $days روز';
  }

  @override
  String get selectFirstDate => 'انتخاب تاریخ اول';

  @override
  String get firstDateSelected => 'تاریخ اول';

  @override
  String get selectSecondDate => 'انتخاب تاریخ دوم';

  @override
  String get secondDateSelected => 'تاریخ دوم';

  @override
  String get calculationResult => 'نتیجه محاسبه';

  @override
  String distanceDays(String days) {
    return 'فاصله: $days روز';
  }

  @override
  String equivalentYearsMonths(String years, String months) {
    return 'معادل: $years سال و $months ماه';
  }

  @override
  String get selectTargetDate => 'انتخاب تاریخ هدف';

  @override
  String get targetDateSelected => 'تاریخ هدف انتخاب شده';

  @override
  String targetDate(String date) {
    return 'تاریخ هدف: $date';
  }

  @override
  String get loadError => 'خطا در بارگیری اطلاعات';

  @override
  String nowruzYear(String year) {
    return 'نوروز $year';
  }

  @override
  String get todayIsNowruz => 'امروز نوروز!';

  @override
  String hoursAndMinutes(String hours, String minutes) {
    return '$hours ساعت و $minutes دقیقه';
  }

  @override
  String exactMoment(String date) {
    return 'لحظه دقیق: $date';
  }

  @override
  String daysCount(String count) {
    return '$count روز';
  }

  @override
  String get welcomeTitle => 'تقویم فارسی';

  @override
  String get continueWithGoogle => 'ورود با گوگل';

  @override
  String get continueAsGuest => 'ورود به عنوان مهمان';

  @override
  String get redirectingToGoogle => 'در حال انتقال به گوگل...';

  @override
  String googleSignInFailed(String error) {
    return 'ورود با گوگل ناموفق بود: $error';
  }

  @override
  String guestSignInFailed(String error) {
    return 'ورود مهمان ناموفق بود: $error';
  }

  @override
  String get guestDiscardWarningTitle => 'ورود با گوگل';

  @override
  String get guestDiscardWarningBody => 'تقویم‌ها و رویدادهای حالت مهمان در همان حالت باقی می‌مانند و به حساب گوگل منتقل نمی‌شوند.';

  @override
  String get viewerCannotAdd => 'دسترسی مشاهده‌گر: امکان افزودن رویداد نیست';

  @override
  String moreItems(String count) {
    return '$count+ مورد دیگر';
  }

  @override
  String get noEventsForDay => 'رویدادی برای این روز ثبت نشده است';

  @override
  String get viewMonthShort => 'ماه';

  @override
  String get viewWeekShort => 'هفته';

  @override
  String get viewYearShort => 'سال';

  @override
  String get compass => 'قطب‌نما';

  @override
  String get compassSub => 'جهت قبله و شمال';

  @override
  String get qiblaDirection => 'جهت قبله';

  @override
  String get facingQibla => 'رو به قبله هستید';

  @override
  String get compassNotAvailable => 'حسگر قطب‌نما در این دستگاه در دسترس نیست';

  @override
  String get compassCalibrationHint => 'برای دقت بیشتر، گوشی را چند بار به شکل ∞ حرکت دهید و از اجسام فلزی دور نگه دارید';

  @override
  String basedOnLocation(String location) {
    return 'بر اساس موقعیت: $location';
  }

  @override
  String get cardinalNorth => 'شمال';

  @override
  String get cardinalEast => 'شرق';

  @override
  String get cardinalSouth => 'جنوب';

  @override
  String get cardinalWest => 'غرب';

  @override
  String get checkForUpdates => 'بررسی به‌روزرسانی';
}
