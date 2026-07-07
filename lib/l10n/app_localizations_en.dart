// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Persian Calendar';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navEvents => 'Events';

  @override
  String get navTools => 'Tools';

  @override
  String get navSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get past => 'Past';

  @override
  String get week => 'Week';

  @override
  String get monthlyView => 'Monthly view';

  @override
  String get weeklyView => 'Weekly view';

  @override
  String get yearlyView => 'Yearly view';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get yearly => 'Yearly';

  @override
  String get selectedDate => 'Selected date';

  @override
  String prayerTimesFor(String city) {
    return 'Prayer times ($city)';
  }

  @override
  String get currentLocation => 'Current location';

  @override
  String daysLeft(String count) {
    return '$count days left';
  }

  @override
  String daysPassed(String count) {
    return '$count days ago';
  }

  @override
  String get daysRemainingLabel => 'days left';

  @override
  String get searchEvents => 'Search events...';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get addEventHint => 'Tap the + button to add a new event';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryOther => 'Other';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get saveEvent => 'Save Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get deleteEventConfirm => 'Are you sure you want to delete this event?';

  @override
  String get eventTitle => 'Event title';

  @override
  String get enterEventTitle => 'Please enter the event title';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get dateAndTime => 'Date & time';

  @override
  String get category => 'Category';

  @override
  String get eventColor => 'Event color';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderSubtitle => 'Get a notification for this event';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get notSelected => 'Not selected';

  @override
  String get selectColor => 'Pick a color';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get continueLabel => 'Continue';

  @override
  String failedToSaveEvent(String error) {
    return 'Failed to save event: $error';
  }

  @override
  String failedToDeleteEvent(String error) {
    return 'Failed to delete event: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String signOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get appearanceTheme => 'Appearance & theme';

  @override
  String get autoTheme => 'Auto theme';

  @override
  String get autoThemeSub => 'Follow the system setting';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSub => 'Use the dark theme';

  @override
  String get primaryColor => 'Primary color';

  @override
  String get primaryColorSub => 'Choose the app accent color';

  @override
  String get display => 'Display';

  @override
  String get persianNumbers => 'Persian numerals';

  @override
  String get persianNumbersSub => 'Show numbers as Persian digits';

  @override
  String get showGregorian => 'Show Gregorian dates';

  @override
  String get showGregorianSub => 'Display Gregorian dates alongside';

  @override
  String get defaultView => 'Default view';

  @override
  String get selectDefaultView => 'Choose default view';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'Choose the app language';

  @override
  String get persianLang => 'فارسی';

  @override
  String get englishLang => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get enableNotificationsSub => 'Get alerts for events and reminders';

  @override
  String get calendarSection => 'Calendar';

  @override
  String get showHolidays => 'Show occasions';

  @override
  String get showHolidaysSub => 'Show holidays and official occasions';

  @override
  String get showEvents => 'Show events';

  @override
  String get showEventsSub => 'Show your events on the calendar';

  @override
  String get prayerTimes => 'Prayer times';

  @override
  String get prayerTimesSub => 'Show daily prayer times';

  @override
  String get useDeviceLocation => 'Use device location';

  @override
  String get useDeviceLocationSub => 'Compute prayer times from your position';

  @override
  String get updateLocation => 'Update location';

  @override
  String get noLocationSaved => 'No location saved yet';

  @override
  String savedLocation(String coords) {
    return 'Saved location: $coords';
  }

  @override
  String get selectCity => 'Choose a city';

  @override
  String get locationUpdated => 'Location updated successfully';

  @override
  String get locationFailed => 'Could not access location; the selected city will be used';

  @override
  String get aboutApp => 'About';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'Persian Calendar Team';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactUsSub => 'Send feedback and suggestions';

  @override
  String get contactBody => 'Send us your feedback, bug reports or suggestions.\n\nEmail: support@persiancalendar.com\nTelegram: @PersianCalendarSupport';

  @override
  String get account => 'Account';

  @override
  String get accountStatus => 'Status';

  @override
  String get upgradeToGoogle => 'Upgrade to Google';

  @override
  String get upgradeToGoogleSub => 'Link this guest account to Google';

  @override
  String get googleSync => 'Sync with Google Calendar';

  @override
  String get googleSyncSub => 'Two-way event sync with your Google Calendar';

  @override
  String get syncing => 'Syncing with Google Calendar...';

  @override
  String syncDone(String imported, String exported) {
    return 'Sync finished: $imported imported, $exported exported';
  }

  @override
  String get syncFailed => 'Sync failed. Make sure the Google Calendar API is enabled and access was granted.';

  @override
  String get tools => 'Tools';

  @override
  String get occasions => 'Occasions';

  @override
  String get occasionsSub => 'Browse and search official, religious, ancient and world occasions';

  @override
  String get searchOccasion => 'Search occasions...';

  @override
  String get noResults => 'No results';

  @override
  String get dayOff => 'Holiday';

  @override
  String get catOfficial => 'Official';

  @override
  String get catReligious => 'Religious';

  @override
  String get catAncient => 'Ancient';

  @override
  String get catInternational => 'World';

  @override
  String get dateConverter => 'Date converter';

  @override
  String get dateConverterSub => 'Convert between Jalali, Gregorian and Hijri';

  @override
  String get ageCalculator => 'Age calculator';

  @override
  String get ageCalculatorSub => 'Compute age from birth date';

  @override
  String get dateDifference => 'Date difference';

  @override
  String get dateDifferenceSub => 'Compute the span between two dates';

  @override
  String get countdown => 'Countdown';

  @override
  String get countdownSub => 'Days remaining until an event';

  @override
  String get nowruzMoment => 'Nowruz moment';

  @override
  String get nowruzMomentSub => 'Exact time of the new year';

  @override
  String get worldClock => 'World clock';

  @override
  String get worldClockSub => 'Time in cities around the world';

  @override
  String get jalaliCalendar => 'Jalali (Solar Hijri)';

  @override
  String get gregorianCalendar => 'Gregorian';

  @override
  String get hijriCalendar => 'Hijri (Lunar)';

  @override
  String get selectDate => 'Pick a date';

  @override
  String get selectGregorianDate => 'Pick a Gregorian date';

  @override
  String get fromGregorian => 'From Gregorian';

  @override
  String get fromJalali => 'From Jalali';

  @override
  String get convertFromJalali => 'Convert from Jalali';

  @override
  String get yearLabel => 'Year';

  @override
  String get monthLabel => 'Month';

  @override
  String get dayLabel => 'Day';

  @override
  String get enterNumericDate => 'Enter year, month and day as numbers.';

  @override
  String get monthRangeError => 'Month must be between 1 and 12.';

  @override
  String dayRangeError(String max) {
    return 'Day must be between 1 and $max for this month.';
  }

  @override
  String get selectBirthDate => 'Pick birth date';

  @override
  String get birthDateSelected => 'Birth date selected';

  @override
  String get yourAge => 'Your age';

  @override
  String get ageDifference => 'Age difference';

  @override
  String ageResult(String years, String months, String days) {
    return '$years years, $months months, $days days';
  }

  @override
  String get selectFirstDate => 'Pick first date';

  @override
  String get firstDateSelected => 'First date';

  @override
  String get selectSecondDate => 'Pick second date';

  @override
  String get secondDateSelected => 'Second date';

  @override
  String get calculationResult => 'Result';

  @override
  String distanceDays(String days) {
    return 'Span: $days days';
  }

  @override
  String equivalentYearsMonths(String years, String months) {
    return 'Equivalent: $years years and $months months';
  }

  @override
  String get selectTargetDate => 'Pick target date';

  @override
  String get targetDateSelected => 'Target date selected';

  @override
  String targetDate(String date) {
    return 'Target date: $date';
  }

  @override
  String get loadError => 'Failed to load data';

  @override
  String nowruzYear(String year) {
    return 'Nowruz $year';
  }

  @override
  String get todayIsNowruz => 'Today is Nowruz!';

  @override
  String hoursAndMinutes(String hours, String minutes) {
    return '$hours hours and $minutes minutes';
  }

  @override
  String exactMoment(String date) {
    return 'Exact moment: $date';
  }

  @override
  String daysCount(String count) {
    return '$count days';
  }

  @override
  String get welcomeTitle => 'Persian Calendar';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get redirectingToGoogle => 'Redirecting to Google...';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String guestSignInFailed(String error) {
    return 'Guest sign-in failed: $error';
  }

  @override
  String get guestDiscardWarningTitle => 'Continue with Google';

  @override
  String get guestDiscardWarningBody => 'Guest calendars and events will stay in Guest mode and will not be moved to Google.';

  @override
  String get viewerCannotAdd => 'Viewer access: cannot add events';

  @override
  String moreItems(String count) {
    return '+$count more';
  }

  @override
  String get noEventsForDay => 'No events for this day';

  @override
  String get viewMonthShort => 'Month';

  @override
  String get viewWeekShort => 'Week';

  @override
  String get viewYearShort => 'Year';

  @override
  String get compass => 'Compass';

  @override
  String get compassSub => 'Qibla direction and north';

  @override
  String get qiblaDirection => 'Qibla direction';

  @override
  String get facingQibla => 'You are facing the qibla';

  @override
  String get compassNotAvailable => 'Compass sensor is not available on this device';

  @override
  String get compassCalibrationHint => 'For better accuracy, move your phone in a figure-8 motion and keep it away from metal objects';

  @override
  String basedOnLocation(String location) {
    return 'Based on location: $location';
  }

  @override
  String get cardinalNorth => 'N';

  @override
  String get cardinalEast => 'E';

  @override
  String get cardinalSouth => 'S';

  @override
  String get cardinalWest => 'W';

  @override
  String get checkForUpdates => 'Check for updates';
}
