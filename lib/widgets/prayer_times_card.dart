import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../services/prayer_times_service.dart';
import '../utils/calendar_utils.dart';

/// Prayer times for the provider's selected (or current) date, using device
/// coordinates when available and the configured city otherwise.
class PrayerTimesCard extends StatelessWidget {
  const PrayerTimesCard({Key? key, this.margin}) : super(key: key);

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final scheme = Theme.of(context).colorScheme;
    final targetDate =
        (provider.selectedDate ?? provider.currentDate).toGregorian();
    final s = provider.settings;
    final useCoords =
        s.useDeviceLocation && s.latitude != null && s.longitude != null;
    final prayerTimes = useCoords
        ? PrayerTimesService.calculate(
            date: targetDate,
            latitude: s.latitude,
            longitude: s.longitude,
            utcOffsetHours: DateTime.now().timeZoneOffset.inMinutes / 60.0,
          )
        : PrayerTimesService.calculate(
            date: targetDate,
            cityName: s.location,
          );

    return Card(
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_twilight, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)
                        .prayerTimesFor(prayerTimes.cityName),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final entry in prayerTimes.times.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      CalendarUtils.formatNumber(
                        entry.value == null
                            ? '--:--'
                            : '${entry.value!.hour.toString().padLeft(2, '0')}:${entry.value!.minute.toString().padLeft(2, '0')}',
                        usePersian: s.showPersianNumbers,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
