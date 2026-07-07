import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'تقویم فارسی'**
  String get appTitle;

  /// No description provided for @navCalendar.
  ///
  /// In fa, this message translates to:
  /// **'تقویم'**
  String get navCalendar;

  /// No description provided for @navEvents.
  ///
  /// In fa, this message translates to:
  /// **'رویدادها'**
  String get navEvents;

  /// No description provided for @navTools.
  ///
  /// In fa, this message translates to:
  /// **'ابزارها'**
  String get navTools;

  /// No description provided for @navSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get navSettings;

  /// No description provided for @today.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In fa, this message translates to:
  /// **'فردا'**
  String get tomorrow;

  /// No description provided for @past.
  ///
  /// In fa, this message translates to:
  /// **'گذشته'**
  String get past;

  /// No description provided for @week.
  ///
  /// In fa, this message translates to:
  /// **'هفته'**
  String get week;

  /// No description provided for @monthlyView.
  ///
  /// In fa, this message translates to:
  /// **'نمای ماهانه'**
  String get monthlyView;

  /// No description provided for @weeklyView.
  ///
  /// In fa, this message translates to:
  /// **'نمای هفتگی'**
  String get weeklyView;

  /// No description provided for @yearlyView.
  ///
  /// In fa, this message translates to:
  /// **'نمای سالانه'**
  String get yearlyView;

  /// No description provided for @monthly.
  ///
  /// In fa, this message translates to:
  /// **'ماهانه'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In fa, this message translates to:
  /// **'هفتگی'**
  String get weekly;

  /// No description provided for @yearly.
  ///
  /// In fa, this message translates to:
  /// **'سالانه'**
  String get yearly;

  /// No description provided for @selectedDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ انتخاب شده'**
  String get selectedDate;

  /// No description provided for @prayerTimesFor.
  ///
  /// In fa, this message translates to:
  /// **'اوقات شرعی ({city})'**
  String prayerTimesFor(String city);

  /// No description provided for @currentLocation.
  ///
  /// In fa, this message translates to:
  /// **'موقعیت فعلی'**
  String get currentLocation;

  /// No description provided for @daysLeft.
  ///
  /// In fa, this message translates to:
  /// **'{count} روز مانده'**
  String daysLeft(String count);

  /// No description provided for @daysPassed.
  ///
  /// In fa, this message translates to:
  /// **'{count} روز گذشته'**
  String daysPassed(String count);

  /// No description provided for @daysRemainingLabel.
  ///
  /// In fa, this message translates to:
  /// **'روز مانده'**
  String get daysRemainingLabel;

  /// No description provided for @searchEvents.
  ///
  /// In fa, this message translates to:
  /// **'جستجو در رویدادها...'**
  String get searchEvents;

  /// No description provided for @noEventsFound.
  ///
  /// In fa, this message translates to:
  /// **'هیچ رویدادی یافت نشد'**
  String get noEventsFound;

  /// No description provided for @addEventHint.
  ///
  /// In fa, this message translates to:
  /// **'برای افزودن رویداد جدید روی دکمه + کلیک کنید'**
  String get addEventHint;

  /// No description provided for @categoryAll.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get categoryAll;

  /// No description provided for @categoryPersonal.
  ///
  /// In fa, this message translates to:
  /// **'شخصی'**
  String get categoryPersonal;

  /// No description provided for @categoryWork.
  ///
  /// In fa, this message translates to:
  /// **'کاری'**
  String get categoryWork;

  /// No description provided for @categoryFamily.
  ///
  /// In fa, this message translates to:
  /// **'خانوادگی'**
  String get categoryFamily;

  /// No description provided for @categoryHealth.
  ///
  /// In fa, this message translates to:
  /// **'سلامت'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In fa, this message translates to:
  /// **'آموزشی'**
  String get categoryEducation;

  /// No description provided for @categoryOther.
  ///
  /// In fa, this message translates to:
  /// **'سایر'**
  String get categoryOther;

  /// No description provided for @addEvent.
  ///
  /// In fa, this message translates to:
  /// **'افزودن رویداد'**
  String get addEvent;

  /// No description provided for @editEvent.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش رویداد'**
  String get editEvent;

  /// No description provided for @saveEvent.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره رویداد'**
  String get saveEvent;

  /// No description provided for @deleteEvent.
  ///
  /// In fa, this message translates to:
  /// **'حذف رویداد'**
  String get deleteEvent;

  /// No description provided for @deleteEventConfirm.
  ///
  /// In fa, this message translates to:
  /// **'آیا مطمئن هستید که می‌خواهید این رویداد را حذف کنید؟'**
  String get deleteEventConfirm;

  /// No description provided for @eventTitle.
  ///
  /// In fa, this message translates to:
  /// **'عنوان رویداد'**
  String get eventTitle;

  /// No description provided for @enterEventTitle.
  ///
  /// In fa, this message translates to:
  /// **'لطفا عنوان رویداد را وارد کنید'**
  String get enterEventTitle;

  /// No description provided for @descriptionOptional.
  ///
  /// In fa, this message translates to:
  /// **'توضیحات (اختیاری)'**
  String get descriptionOptional;

  /// No description provided for @dateAndTime.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ و زمان'**
  String get dateAndTime;

  /// No description provided for @category.
  ///
  /// In fa, this message translates to:
  /// **'دسته‌بندی'**
  String get category;

  /// No description provided for @eventColor.
  ///
  /// In fa, this message translates to:
  /// **'رنگ رویداد'**
  String get eventColor;

  /// No description provided for @reminder.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری'**
  String get reminder;

  /// No description provided for @reminderSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'دریافت اعلان برای این رویداد'**
  String get reminderSubtitle;

  /// No description provided for @reminderTime.
  ///
  /// In fa, this message translates to:
  /// **'زمان یادآوری'**
  String get reminderTime;

  /// No description provided for @notSelected.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب نشده'**
  String get notSelected;

  /// No description provided for @selectColor.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب رنگ'**
  String get selectColor;

  /// No description provided for @cancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fa, this message translates to:
  /// **'تایید'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get close;

  /// No description provided for @continueLabel.
  ///
  /// In fa, this message translates to:
  /// **'ادامه'**
  String get continueLabel;

  /// No description provided for @failedToSaveEvent.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره رویداد ناموفق بود: {error}'**
  String failedToSaveEvent(String error);

  /// No description provided for @failedToDeleteEvent.
  ///
  /// In fa, this message translates to:
  /// **'حذف رویداد ناموفق بود: {error}'**
  String failedToDeleteEvent(String error);

  /// No description provided for @settings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In fa, this message translates to:
  /// **'خروج از حساب'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In fa, this message translates to:
  /// **'آیا مطمئن هستید که می‌خواهید خارج شوید؟'**
  String get signOutConfirm;

  /// No description provided for @signOutFailed.
  ///
  /// In fa, this message translates to:
  /// **'خروج ناموفق بود: {error}'**
  String signOutFailed(String error);

  /// No description provided for @appearanceTheme.
  ///
  /// In fa, this message translates to:
  /// **'ظاهر و تم'**
  String get appearanceTheme;

  /// No description provided for @autoTheme.
  ///
  /// In fa, this message translates to:
  /// **'تم خودکار'**
  String get autoTheme;

  /// No description provided for @autoThemeSub.
  ///
  /// In fa, this message translates to:
  /// **'تغییر خودکار بر اساس تنظیمات سیستم'**
  String get autoThemeSub;

  /// No description provided for @darkMode.
  ///
  /// In fa, this message translates to:
  /// **'حالت تاریک'**
  String get darkMode;

  /// No description provided for @darkModeSub.
  ///
  /// In fa, this message translates to:
  /// **'استفاده از تم تاریک'**
  String get darkModeSub;

  /// No description provided for @primaryColor.
  ///
  /// In fa, this message translates to:
  /// **'رنگ اصلی'**
  String get primaryColor;

  /// No description provided for @primaryColorSub.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب رنگ اصلی اپلیکیشن'**
  String get primaryColorSub;

  /// No description provided for @display.
  ///
  /// In fa, this message translates to:
  /// **'نمایش'**
  String get display;

  /// No description provided for @persianNumbers.
  ///
  /// In fa, this message translates to:
  /// **'اعداد فارسی'**
  String get persianNumbers;

  /// No description provided for @persianNumbersSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش اعداد به صورت فارسی'**
  String get persianNumbersSub;

  /// No description provided for @showGregorian.
  ///
  /// In fa, this message translates to:
  /// **'نمایش تقویم میلادی'**
  String get showGregorian;

  /// No description provided for @showGregorianSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش همزمان تاریخ میلادی'**
  String get showGregorianSub;

  /// No description provided for @defaultView.
  ///
  /// In fa, this message translates to:
  /// **'نمای پیش‌فرض'**
  String get defaultView;

  /// No description provided for @selectDefaultView.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب نمای پیش‌فرض'**
  String get selectDefaultView;

  /// No description provided for @language.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب زبان برنامه'**
  String get languageSub;

  /// No description provided for @persianLang.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get persianLang;

  /// No description provided for @englishLang.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get englishLang;

  /// No description provided for @notifications.
  ///
  /// In fa, this message translates to:
  /// **'اعلانات'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In fa, this message translates to:
  /// **'فعالسازی اعلانات'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsSub.
  ///
  /// In fa, this message translates to:
  /// **'دریافت اعلان برای رویدادها و یادآورها'**
  String get enableNotificationsSub;

  /// No description provided for @calendarSection.
  ///
  /// In fa, this message translates to:
  /// **'تقویم'**
  String get calendarSection;

  /// No description provided for @showHolidays.
  ///
  /// In fa, this message translates to:
  /// **'نمایش مناسبت‌ها'**
  String get showHolidays;

  /// No description provided for @showHolidaysSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش تعطیلات و مناسبت‌های رسمی'**
  String get showHolidaysSub;

  /// No description provided for @showEvents.
  ///
  /// In fa, this message translates to:
  /// **'نمایش رویدادها'**
  String get showEvents;

  /// No description provided for @showEventsSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش رویدادهای شخصی در تقویم'**
  String get showEventsSub;

  /// No description provided for @prayerTimes.
  ///
  /// In fa, this message translates to:
  /// **'اوقات شرعی'**
  String get prayerTimes;

  /// No description provided for @prayerTimesSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش اوقات شرعی'**
  String get prayerTimesSub;

  /// No description provided for @useDeviceLocation.
  ///
  /// In fa, this message translates to:
  /// **'استفاده از موقعیت دستگاه'**
  String get useDeviceLocation;

  /// No description provided for @useDeviceLocationSub.
  ///
  /// In fa, this message translates to:
  /// **'محاسبه اوقات شرعی بر اساس موقعیت فعلی'**
  String get useDeviceLocationSub;

  /// No description provided for @updateLocation.
  ///
  /// In fa, this message translates to:
  /// **'به‌روزرسانی موقعیت'**
  String get updateLocation;

  /// No description provided for @noLocationSaved.
  ///
  /// In fa, this message translates to:
  /// **'موقعیتی ثبت نشده است'**
  String get noLocationSaved;

  /// No description provided for @savedLocation.
  ///
  /// In fa, this message translates to:
  /// **'موقعیت ثبت‌شده: {coords}'**
  String savedLocation(String coords);

  /// No description provided for @selectCity.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب شهر'**
  String get selectCity;

  /// No description provided for @locationUpdated.
  ///
  /// In fa, this message translates to:
  /// **'موقعیت با موفقیت به‌روزرسانی شد'**
  String get locationUpdated;

  /// No description provided for @locationFailed.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی به موقعیت امکان‌پذیر نشد؛ از شهر انتخابی استفاده می‌شود'**
  String get locationFailed;

  /// No description provided for @aboutApp.
  ///
  /// In fa, this message translates to:
  /// **'درباره برنامه'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In fa, this message translates to:
  /// **'نسخه'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In fa, this message translates to:
  /// **'توسعه‌دهنده'**
  String get developer;

  /// No description provided for @developerName.
  ///
  /// In fa, this message translates to:
  /// **'تیم توسعه تقویم فارسی'**
  String get developerName;

  /// No description provided for @contactUs.
  ///
  /// In fa, this message translates to:
  /// **'ارتباط با ما'**
  String get contactUs;

  /// No description provided for @contactUsSub.
  ///
  /// In fa, this message translates to:
  /// **'ارسال بازخورد و پیشنهادات'**
  String get contactUsSub;

  /// No description provided for @contactBody.
  ///
  /// In fa, this message translates to:
  /// **'برای ارسال بازخورد، گزارش باگ یا پیشنهادات خود می‌توانید با ما در ارتباط باشید.\n\nایمیل: support@persiancalendar.com\nتلگرام: @PersianCalendarSupport'**
  String get contactBody;

  /// No description provided for @account.
  ///
  /// In fa, this message translates to:
  /// **'حساب کاربری'**
  String get account;

  /// No description provided for @accountStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت'**
  String get accountStatus;

  /// No description provided for @upgradeToGoogle.
  ///
  /// In fa, this message translates to:
  /// **'ارتقا به حساب گوگل'**
  String get upgradeToGoogle;

  /// No description provided for @upgradeToGoogleSub.
  ///
  /// In fa, this message translates to:
  /// **'اتصال این حساب مهمان به گوگل'**
  String get upgradeToGoogleSub;

  /// No description provided for @googleSync.
  ///
  /// In fa, this message translates to:
  /// **'همگام‌سازی با Google Calendar'**
  String get googleSync;

  /// No description provided for @googleSyncSub.
  ///
  /// In fa, this message translates to:
  /// **'ورود و خروج دوطرفه رویدادها با تقویم گوگل'**
  String get googleSyncSub;

  /// No description provided for @syncing.
  ///
  /// In fa, this message translates to:
  /// **'در حال همگام‌سازی با Google Calendar...'**
  String get syncing;

  /// No description provided for @syncDone.
  ///
  /// In fa, this message translates to:
  /// **'همگام‌سازی انجام شد: {imported} ورودی، {exported} خروجی'**
  String syncDone(String imported, String exported);

  /// No description provided for @syncFailed.
  ///
  /// In fa, this message translates to:
  /// **'همگام‌سازی ناموفق بود. مطمئن شوید Google Calendar API فعال و دسترسی داده شده است.'**
  String get syncFailed;

  /// No description provided for @tools.
  ///
  /// In fa, this message translates to:
  /// **'ابزارها'**
  String get tools;

  /// No description provided for @occasions.
  ///
  /// In fa, this message translates to:
  /// **'مناسبت‌ها'**
  String get occasions;

  /// No description provided for @occasionsSub.
  ///
  /// In fa, this message translates to:
  /// **'مرور و جستجوی مناسبت‌های رسمی، مذهبی، باستانی و جهانی'**
  String get occasionsSub;

  /// No description provided for @searchOccasion.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی مناسبت...'**
  String get searchOccasion;

  /// No description provided for @noResults.
  ///
  /// In fa, this message translates to:
  /// **'موردی یافت نشد'**
  String get noResults;

  /// No description provided for @dayOff.
  ///
  /// In fa, this message translates to:
  /// **'تعطیل'**
  String get dayOff;

  /// No description provided for @catOfficial.
  ///
  /// In fa, this message translates to:
  /// **'رسمی'**
  String get catOfficial;

  /// No description provided for @catReligious.
  ///
  /// In fa, this message translates to:
  /// **'مذهبی'**
  String get catReligious;

  /// No description provided for @catAncient.
  ///
  /// In fa, this message translates to:
  /// **'باستانی'**
  String get catAncient;

  /// No description provided for @catInternational.
  ///
  /// In fa, this message translates to:
  /// **'جهانی'**
  String get catInternational;

  /// No description provided for @dateConverter.
  ///
  /// In fa, this message translates to:
  /// **'تبدیل تاریخ'**
  String get dateConverter;

  /// No description provided for @dateConverterSub.
  ///
  /// In fa, this message translates to:
  /// **'تبدیل بین تقویم شمسی، میلادی و قمری'**
  String get dateConverterSub;

  /// No description provided for @ageCalculator.
  ///
  /// In fa, this message translates to:
  /// **'محاسبه سن'**
  String get ageCalculator;

  /// No description provided for @ageCalculatorSub.
  ///
  /// In fa, this message translates to:
  /// **'محاسبه سن بر اساس تاریخ تولد'**
  String get ageCalculatorSub;

  /// No description provided for @dateDifference.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف دو تاریخ'**
  String get dateDifference;

  /// No description provided for @dateDifferenceSub.
  ///
  /// In fa, this message translates to:
  /// **'محاسبه فاصله زمانی بین دو تاریخ'**
  String get dateDifferenceSub;

  /// No description provided for @countdown.
  ///
  /// In fa, this message translates to:
  /// **'روزشمار'**
  String get countdown;

  /// No description provided for @countdownSub.
  ///
  /// In fa, this message translates to:
  /// **'شمارش روزهای باقیمانده تا رویداد'**
  String get countdownSub;

  /// No description provided for @nowruzMoment.
  ///
  /// In fa, this message translates to:
  /// **'لحظه سال تحویل'**
  String get nowruzMoment;

  /// No description provided for @nowruzMomentSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش زمان دقیق سال تحویل'**
  String get nowruzMomentSub;

  /// No description provided for @worldClock.
  ///
  /// In fa, this message translates to:
  /// **'ساعت جهانی'**
  String get worldClock;

  /// No description provided for @worldClockSub.
  ///
  /// In fa, this message translates to:
  /// **'نمایش ساعت شهرهای مختلف جهان'**
  String get worldClockSub;

  /// No description provided for @jalaliCalendar.
  ///
  /// In fa, this message translates to:
  /// **'شمسی (هجری شمسی)'**
  String get jalaliCalendar;

  /// No description provided for @gregorianCalendar.
  ///
  /// In fa, this message translates to:
  /// **'میلادی (گریگوری)'**
  String get gregorianCalendar;

  /// No description provided for @hijriCalendar.
  ///
  /// In fa, this message translates to:
  /// **'قمری (هجری قمری)'**
  String get hijriCalendar;

  /// No description provided for @selectDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ'**
  String get selectDate;

  /// No description provided for @selectGregorianDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ میلادی'**
  String get selectGregorianDate;

  /// No description provided for @fromGregorian.
  ///
  /// In fa, this message translates to:
  /// **'مبدا میلادی'**
  String get fromGregorian;

  /// No description provided for @fromJalali.
  ///
  /// In fa, this message translates to:
  /// **'مبدا شمسی'**
  String get fromJalali;

  /// No description provided for @convertFromJalali.
  ///
  /// In fa, this message translates to:
  /// **'تبدیل از شمسی'**
  String get convertFromJalali;

  /// No description provided for @yearLabel.
  ///
  /// In fa, this message translates to:
  /// **'سال'**
  String get yearLabel;

  /// No description provided for @monthLabel.
  ///
  /// In fa, this message translates to:
  /// **'ماه'**
  String get monthLabel;

  /// No description provided for @dayLabel.
  ///
  /// In fa, this message translates to:
  /// **'روز'**
  String get dayLabel;

  /// No description provided for @enterNumericDate.
  ///
  /// In fa, this message translates to:
  /// **'سال، ماه و روز را به صورت عددی وارد کنید.'**
  String get enterNumericDate;

  /// No description provided for @monthRangeError.
  ///
  /// In fa, this message translates to:
  /// **'ماه باید بین 1 تا 12 باشد.'**
  String get monthRangeError;

  /// No description provided for @dayRangeError.
  ///
  /// In fa, this message translates to:
  /// **'روز برای این ماه باید بین 1 تا {max} باشد.'**
  String dayRangeError(String max);

  /// No description provided for @selectBirthDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ تولد'**
  String get selectBirthDate;

  /// No description provided for @birthDateSelected.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد انتخاب شده'**
  String get birthDateSelected;

  /// No description provided for @yourAge.
  ///
  /// In fa, this message translates to:
  /// **'سن شما'**
  String get yourAge;

  /// No description provided for @ageDifference.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف سن'**
  String get ageDifference;

  /// No description provided for @ageResult.
  ///
  /// In fa, this message translates to:
  /// **'{years} سال، {months} ماه، {days} روز'**
  String ageResult(String years, String months, String days);

  /// No description provided for @selectFirstDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ اول'**
  String get selectFirstDate;

  /// No description provided for @firstDateSelected.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ اول'**
  String get firstDateSelected;

  /// No description provided for @selectSecondDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ دوم'**
  String get selectSecondDate;

  /// No description provided for @secondDateSelected.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ دوم'**
  String get secondDateSelected;

  /// No description provided for @calculationResult.
  ///
  /// In fa, this message translates to:
  /// **'نتیجه محاسبه'**
  String get calculationResult;

  /// No description provided for @distanceDays.
  ///
  /// In fa, this message translates to:
  /// **'فاصله: {days} روز'**
  String distanceDays(String days);

  /// No description provided for @equivalentYearsMonths.
  ///
  /// In fa, this message translates to:
  /// **'معادل: {years} سال و {months} ماه'**
  String equivalentYearsMonths(String years, String months);

  /// No description provided for @selectTargetDate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تاریخ هدف'**
  String get selectTargetDate;

  /// No description provided for @targetDateSelected.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ هدف انتخاب شده'**
  String get targetDateSelected;

  /// No description provided for @targetDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ هدف: {date}'**
  String targetDate(String date);

  /// No description provided for @loadError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگیری اطلاعات'**
  String get loadError;

  /// No description provided for @nowruzYear.
  ///
  /// In fa, this message translates to:
  /// **'نوروز {year}'**
  String nowruzYear(String year);

  /// No description provided for @todayIsNowruz.
  ///
  /// In fa, this message translates to:
  /// **'امروز نوروز!'**
  String get todayIsNowruz;

  /// No description provided for @hoursAndMinutes.
  ///
  /// In fa, this message translates to:
  /// **'{hours} ساعت و {minutes} دقیقه'**
  String hoursAndMinutes(String hours, String minutes);

  /// No description provided for @exactMoment.
  ///
  /// In fa, this message translates to:
  /// **'لحظه دقیق: {date}'**
  String exactMoment(String date);

  /// No description provided for @daysCount.
  ///
  /// In fa, this message translates to:
  /// **'{count} روز'**
  String daysCount(String count);

  /// No description provided for @welcomeTitle.
  ///
  /// In fa, this message translates to:
  /// **'تقویم فارسی'**
  String get welcomeTitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با گوگل'**
  String get continueWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In fa, this message translates to:
  /// **'ورود به عنوان مهمان'**
  String get continueAsGuest;

  /// No description provided for @redirectingToGoogle.
  ///
  /// In fa, this message translates to:
  /// **'در حال انتقال به گوگل...'**
  String get redirectingToGoogle;

  /// No description provided for @googleSignInFailed.
  ///
  /// In fa, this message translates to:
  /// **'ورود با گوگل ناموفق بود: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @guestSignInFailed.
  ///
  /// In fa, this message translates to:
  /// **'ورود مهمان ناموفق بود: {error}'**
  String guestSignInFailed(String error);

  /// No description provided for @guestDiscardWarningTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با گوگل'**
  String get guestDiscardWarningTitle;

  /// No description provided for @guestDiscardWarningBody.
  ///
  /// In fa, this message translates to:
  /// **'تقویم‌ها و رویدادهای حالت مهمان در همان حالت باقی می‌مانند و به حساب گوگل منتقل نمی‌شوند.'**
  String get guestDiscardWarningBody;

  /// No description provided for @viewerCannotAdd.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی مشاهده‌گر: امکان افزودن رویداد نیست'**
  String get viewerCannotAdd;

  /// No description provided for @moreItems.
  ///
  /// In fa, this message translates to:
  /// **'{count}+ مورد دیگر'**
  String moreItems(String count);

  /// No description provided for @noEventsForDay.
  ///
  /// In fa, this message translates to:
  /// **'رویدادی برای این روز ثبت نشده است'**
  String get noEventsForDay;

  /// No description provided for @viewMonthShort.
  ///
  /// In fa, this message translates to:
  /// **'ماه'**
  String get viewMonthShort;

  /// No description provided for @viewWeekShort.
  ///
  /// In fa, this message translates to:
  /// **'هفته'**
  String get viewWeekShort;

  /// No description provided for @viewYearShort.
  ///
  /// In fa, this message translates to:
  /// **'سال'**
  String get viewYearShort;

  /// No description provided for @compass.
  ///
  /// In fa, this message translates to:
  /// **'قطب‌نما'**
  String get compass;

  /// No description provided for @compassSub.
  ///
  /// In fa, this message translates to:
  /// **'جهت قبله و شمال'**
  String get compassSub;

  /// No description provided for @qiblaDirection.
  ///
  /// In fa, this message translates to:
  /// **'جهت قبله'**
  String get qiblaDirection;

  /// No description provided for @facingQibla.
  ///
  /// In fa, this message translates to:
  /// **'رو به قبله هستید'**
  String get facingQibla;

  /// No description provided for @compassNotAvailable.
  ///
  /// In fa, this message translates to:
  /// **'حسگر قطب‌نما در این دستگاه در دسترس نیست'**
  String get compassNotAvailable;

  /// No description provided for @compassCalibrationHint.
  ///
  /// In fa, this message translates to:
  /// **'برای دقت بیشتر، گوشی را چند بار به شکل ∞ حرکت دهید و از اجسام فلزی دور نگه دارید'**
  String get compassCalibrationHint;

  /// No description provided for @basedOnLocation.
  ///
  /// In fa, this message translates to:
  /// **'بر اساس موقعیت: {location}'**
  String basedOnLocation(String location);

  /// No description provided for @cardinalNorth.
  ///
  /// In fa, this message translates to:
  /// **'شمال'**
  String get cardinalNorth;

  /// No description provided for @cardinalEast.
  ///
  /// In fa, this message translates to:
  /// **'شرق'**
  String get cardinalEast;

  /// No description provided for @cardinalSouth.
  ///
  /// In fa, this message translates to:
  /// **'جنوب'**
  String get cardinalSouth;

  /// No description provided for @cardinalWest.
  ///
  /// In fa, this message translates to:
  /// **'غرب'**
  String get cardinalWest;

  /// No description provided for @checkForUpdates.
  ///
  /// In fa, this message translates to:
  /// **'بررسی به‌روزرسانی'**
  String get checkForUpdates;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
