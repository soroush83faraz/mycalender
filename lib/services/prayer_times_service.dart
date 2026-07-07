import 'dart:math' as math;

class PrayerTimesResult {
  final String cityName;
  final DateTime date;
  final Map<String, DateTime?> times;

  const PrayerTimesResult({
    required this.cityName,
    required this.date,
    required this.times,
  });
}

class _CityCoordinate {
  final String name;
  final double latitude;
  final double longitude;
  final List<String> aliases;

  const _CityCoordinate({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.aliases,
  });
}

class PrayerTimesService {
  static const double _iranUtcOffsetHours = 3.5;
  static const List<_CityCoordinate> _cities = <_CityCoordinate>[
    _CityCoordinate(
      name: 'تهران',
      latitude: 35.6892,
      longitude: 51.3890,
      aliases: <String>['tehran'],
    ),
    _CityCoordinate(
      name: 'مشهد',
      latitude: 36.2605,
      longitude: 59.6168,
      aliases: <String>['mashhad'],
    ),
    _CityCoordinate(
      name: 'اصفهان',
      latitude: 32.6546,
      longitude: 51.6680,
      aliases: <String>['isfahan', 'esfahan'],
    ),
    _CityCoordinate(
      name: 'شیراز',
      latitude: 29.5918,
      longitude: 52.5837,
      aliases: <String>['shiraz'],
    ),
    _CityCoordinate(
      name: 'تبریز',
      latitude: 38.0962,
      longitude: 46.2738,
      aliases: <String>['tabriz'],
    ),
    _CityCoordinate(
      name: 'کرج',
      latitude: 35.8400,
      longitude: 50.9391,
      aliases: <String>['karaj'],
    ),
    _CityCoordinate(
      name: 'قم',
      latitude: 34.6416,
      longitude: 50.8746,
      aliases: <String>['qom', 'ghom'],
    ),
    _CityCoordinate(
      name: 'اهواز',
      latitude: 31.3183,
      longitude: 48.6706,
      aliases: <String>['ahvaz'],
    ),
    _CityCoordinate(
      name: 'کرمانشاه',
      latitude: 34.3142,
      longitude: 47.0650,
      aliases: <String>['kermanshah'],
    ),
    _CityCoordinate(
      name: 'ارومیه',
      latitude: 37.5527,
      longitude: 45.0761,
      aliases: <String>['urmia', 'orumiyeh'],
    ),
    _CityCoordinate(
      name: 'رشت',
      latitude: 37.2808,
      longitude: 49.5832,
      aliases: <String>['rasht'],
    ),
    _CityCoordinate(
      name: 'زاهدان',
      latitude: 29.4963,
      longitude: 60.8629,
      aliases: <String>['zahedan'],
    ),
    _CityCoordinate(
      name: 'همدان',
      latitude: 34.7983,
      longitude: 48.5148,
      aliases: <String>['hamedan', 'hamadan'],
    ),
    _CityCoordinate(
      name: 'کرمان',
      latitude: 30.2839,
      longitude: 57.0834,
      aliases: <String>['kerman'],
    ),
    _CityCoordinate(
      name: 'یزد',
      latitude: 31.8974,
      longitude: 54.3569,
      aliases: <String>['yazd'],
    ),
    _CityCoordinate(
      name: 'اردبیل',
      latitude: 38.2498,
      longitude: 48.2933,
      aliases: <String>['ardabil', 'ardebil'],
    ),
  ];

  /// Computes prayer times (Tehran / Institute of Geophysics convention).
  ///
  /// If [latitude]/[longitude] are supplied (e.g. from device GPS) they are
  /// used directly; otherwise the coordinates of [cityName] are used. When
  /// coordinates are supplied, pass [utcOffsetHours] for the correct local
  /// clock (defaults to Iran's +3.5 when omitted).
  static PrayerTimesResult calculate({
    required DateTime date,
    String cityName = 'تهران',
    double? latitude,
    double? longitude,
    double? utcOffsetHours,
    String? label,
  }) {
    final bool useCoords = latitude != null && longitude != null;
    final city = _resolveCity(cityName);
    final double lat = useCoords ? latitude : city.latitude;
    final double lon = useCoords ? longitude : city.longitude;
    final double offset = utcOffsetHours ?? _iranUtcOffsetHours;
    final localDate = DateTime(date.year, date.month, date.day);

    final fajr = _timeForSolarZenith(
      date: localDate,
      latitude: lat,
      longitude: lon,
      zenithDegrees: 108.0,
      isMorning: true,
      offset: offset,
    );
    final sunrise = _timeForSolarZenith(
      date: localDate,
      latitude: lat,
      longitude: lon,
      zenithDegrees: 90.833,
      isMorning: true,
      offset: offset,
    );
    final dhuhr = _solarNoon(
      date: localDate,
      longitude: lon,
      offset: offset,
    );
    final sunset = _timeForSolarZenith(
      date: localDate,
      latitude: lat,
      longitude: lon,
      zenithDegrees: 90.833,
      isMorning: false,
      offset: offset,
    );
    final maghrib =
        sunset == null ? null : sunset.add(const Duration(minutes: 12));

    return PrayerTimesResult(
      cityName: label ?? (useCoords ? 'موقعیت فعلی' : city.name),
      date: localDate,
      times: <String, DateTime?>{
        'اذان صبح': fajr,
        'طلوع خورشید': sunrise,
        'اذان ظهر': dhuhr,
        'غروب خورشید': sunset,
        'اذان مغرب': maghrib,
      },
    );
  }

  /// City names available for manual selection in settings.
  static List<String> get cityNames =>
      _cities.map((c) => c.name).toList(growable: false);

  /// Latitude/longitude of a known city (falls back to Tehran), for features
  /// like the qibla compass that need coordinates without GPS.
  static ({double latitude, double longitude, String name}) coordinatesForCity(
      String cityName) {
    final city = _resolveCity(cityName);
    return (latitude: city.latitude, longitude: city.longitude, name: city.name);
  }

  static _CityCoordinate _resolveCity(String rawCityName) {
    final normalized = _normalize(rawCityName);
    for (final city in _cities) {
      if (_normalize(city.name) == normalized) return city;
      for (final alias in city.aliases) {
        if (_normalize(alias) == normalized) return city;
      }
    }
    return _cities.first;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('\u200c', '')
        .replaceAll(' ', '');
  }

  static DateTime? _timeForSolarZenith({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double zenithDegrees,
    required bool isMorning,
    required double offset,
  }) {
    final dayOfYear = _dayOfYear(date);
    final decl = _solarDeclination(dayOfYear);
    final eqTime = _equationOfTime(dayOfYear);

    final latRad = _degToRad(latitude);
    final zenithRad = _degToRad(zenithDegrees);

    final cosHourAngle = (math.cos(zenithRad) -
            (math.sin(latRad) * math.sin(decl))) /
        (math.cos(latRad) * math.cos(decl));

    if (cosHourAngle < -1 || cosHourAngle > 1) {
      return null;
    }

    final hourAngle = math.acos(cosHourAngle);
    final minutesFromNoon = _radToDeg(hourAngle) * 4.0;
    final solarNoonMinutes = 720 - (4 * longitude) - eqTime + (offset * 60);
    final eventMinutes = isMorning
        ? solarNoonMinutes - minutesFromNoon
        : solarNoonMinutes + minutesFromNoon;

    return _minutesToDateTime(date, eventMinutes);
  }

  static DateTime _solarNoon({
    required DateTime date,
    required double longitude,
    required double offset,
  }) {
    final dayOfYear = _dayOfYear(date);
    final eqTime = _equationOfTime(dayOfYear);
    final solarNoonMinutes = 720 - (4 * longitude) - eqTime + (offset * 60);
    return _minutesToDateTime(date, solarNoonMinutes);
  }

  static int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  static double _equationOfTime(int dayOfYear) {
    final gamma = 2.0 * math.pi / 365.0 * (dayOfYear - 1);
    return 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));
  }

  static double _solarDeclination(int dayOfYear) {
    final gamma = 2.0 * math.pi / 365.0 * (dayOfYear - 1);
    return 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
  }

  static DateTime _minutesToDateTime(DateTime date, double totalMinutes) {
    var normalizedMinutes = totalMinutes.round();
    while (normalizedMinutes < 0) {
      normalizedMinutes += 24 * 60;
    }
    while (normalizedMinutes >= 24 * 60) {
      normalizedMinutes -= 24 * 60;
    }
    final hour = normalizedMinutes ~/ 60;
    final minute = normalizedMinutes % 60;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static double _degToRad(double degree) => degree * (math.pi / 180.0);
  static double _radToDeg(double radian) => radian * (180.0 / math.pi);
}
