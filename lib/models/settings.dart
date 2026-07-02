class AppSettings {
  final String language;
  final bool isDarkMode;
  final bool autoTheme;
  final String primaryColor;
  final bool showHolidays;
  final bool showEvents;
  final bool enableNotifications;
  final String defaultView; // 'month', 'week', 'year'
  final bool showPersianNumbers;
  final bool showLunarCalendar;
  final bool showGregorianCalendar;
  final String location;
  final bool showPrayerTimes;
  final bool useDeviceLocation;
  final double? latitude;
  final double? longitude;

  AppSettings({
    this.language = 'fa',
    this.isDarkMode = false,
    this.autoTheme = true,
    this.primaryColor = '#2196F3',
    this.showHolidays = true,
    this.showEvents = true,
    this.enableNotifications = true,
    this.defaultView = 'month',
    this.showPersianNumbers = true,
    this.showLunarCalendar = false,
    this.showGregorianCalendar = false,
    this.location = 'Tehran',
    this.showPrayerTimes = false,
    this.useDeviceLocation = true,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'language': language,
    'isDarkMode': isDarkMode,
    'autoTheme': autoTheme,
    'primaryColor': primaryColor,
    'showHolidays': showHolidays,
    'showEvents': showEvents,
    'enableNotifications': enableNotifications,
    'defaultView': defaultView,
    'showPersianNumbers': showPersianNumbers,
    'showLunarCalendar': showLunarCalendar,
    'showGregorianCalendar': showGregorianCalendar,
    'location': location,
    'showPrayerTimes': showPrayerTimes,
    'useDeviceLocation': useDeviceLocation,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    language: json['language'] ?? 'fa',
    isDarkMode: json['isDarkMode'] ?? false,
    autoTheme: json['autoTheme'] ?? true,
    primaryColor: json['primaryColor'] ?? '#2196F3',
    showHolidays: json['showHolidays'] ?? true,
    showEvents: json['showEvents'] ?? true,
    enableNotifications: json['enableNotifications'] ?? true,
    defaultView: json['defaultView'] ?? 'month',
    showPersianNumbers: json['showPersianNumbers'] ?? true,
    showLunarCalendar: json['showLunarCalendar'] ?? false,
    showGregorianCalendar: json['showGregorianCalendar'] ?? false,
    location: json['location'] ?? 'Tehran',
    showPrayerTimes: json['showPrayerTimes'] ?? false,
    useDeviceLocation: json['useDeviceLocation'] ?? true,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  AppSettings copyWith({
    String? language,
    bool? isDarkMode,
    bool? autoTheme,
    String? primaryColor,
    bool? showHolidays,
    bool? showEvents,
    bool? enableNotifications,
    String? defaultView,
    bool? showPersianNumbers,
    bool? showLunarCalendar,
    bool? showGregorianCalendar,
    String? location,
    bool? showPrayerTimes,
    bool? useDeviceLocation,
    double? latitude,
    double? longitude,
  }) => AppSettings(
    language: language ?? this.language,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    autoTheme: autoTheme ?? this.autoTheme,
    primaryColor: primaryColor ?? this.primaryColor,
    showHolidays: showHolidays ?? this.showHolidays,
    showEvents: showEvents ?? this.showEvents,
    enableNotifications: enableNotifications ?? this.enableNotifications,
    defaultView: defaultView ?? this.defaultView,
    showPersianNumbers: showPersianNumbers ?? this.showPersianNumbers,
    showLunarCalendar: showLunarCalendar ?? this.showLunarCalendar,
    showGregorianCalendar: showGregorianCalendar ?? this.showGregorianCalendar,
    location: location ?? this.location,
    showPrayerTimes: showPrayerTimes ?? this.showPrayerTimes,
    useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );
}