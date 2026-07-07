import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../models/jalali_date.dart';
import '../providers/calendar_provider.dart';
import '../screens/add_event_screen.dart';
import '../utils/calendar_utils.dart';
import 'prayer_times_card.dart';

/// Fixed side panel on expanded (desktop) layouts showing everything about
/// the selected day: date header, occasions, events and prayer times.
class DayDetailsPanel extends StatelessWidget {
  const DayDetailsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CalendarProvider>();
    final scheme = Theme.of(context).colorScheme;
    final usePersian = provider.settings.showPersianNumbers;

    final date = provider.selectedDate ??
        JalaliDate.fromGregorian(DateTime.now());
    final gregorian = date.toGregorian();
    final weekdayName = JalaliDate.getWeekdayName(
      CalendarUtils.gregorianWeekdayToPersianIndex(gregorian.weekday),
    );
    final events = provider.settings.showEvents
        ? provider.getEventsForDate(date)
        : const <Event>[];
    final dayHolidays = provider.settings.showHolidays
        ? provider.getHolidaysForDate(date)
        : const <Holiday>[];
    final isDayOff = dayHolidays.any((h) => h.isDayOff);
    final canEdit = provider.activeMembershipRole != 'viewer';

    return Container(
      color: scheme.surfaceContainerLowest,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // ── date header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDayOff
                      ? Colors.red.withValues(alpha: 0.12)
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  CalendarUtils.formatNumber(date.day, usePersian: usePersian),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDayOff
                        ? Colors.red.shade400
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$weekdayName ${CalendarUtils.formatNumber(date.day, usePersian: usePersian)} ${date.getMonthName()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      CalendarUtils.formatNumber(date.year,
                          usePersian: usePersian),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${gregorian.year}/${gregorian.month.toString().padLeft(2, '0')}/${gregorian.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── occasions ──
          if (dayHolidays.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel(context, l10n.occasions),
            const SizedBox(height: 8),
            for (final h in dayHolidays)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _holidayColor(h.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: BorderDirectional(
                    start: BorderSide(color: _holidayColor(h.type), width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            h.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (h.isDayOff)
                          Text(
                            l10n.dayOff,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade400,
                            ),
                          ),
                      ],
                    ),
                    if (h.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        h.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],

          // ── events ──
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _sectionLabel(context, l10n.navEvents)),
              if (canEdit)
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEventScreen(selectedDate: date),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addEvent),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 30, color: scheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 6),
                  Text(
                    l10n.noEventsForDay,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final e in events)
              _EventTile(event: e, canEdit: canEdit),

          // ── prayer times ──
          if (provider.settings.showPrayerTimes) ...[
            const SizedBox(height: 20),
            const PrayerTimesCard(),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Color _holidayColor(String type) {
    switch (type) {
      case 'official':
        return Colors.red;
      case 'religious':
        return Colors.green;
      case 'ancient':
        return Colors.orange;
      case 'international':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.canEdit});

  final Event event;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color color;
    try {
      color = Color(int.parse(event.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = scheme.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canEdit
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEventScreen(event: event),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!event.allDay)
                  Text(
                    '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
