import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/holiday.dart';
import '../models/jalali_date.dart';
import '../providers/calendar_provider.dart';
import '../utils/calendar_utils.dart';

/// Browse and search all calendar occasions (official, religious, ancient,
/// international) for the current Persian year, sorted by date with a live
/// countdown to each one.
class OccasionsScreen extends StatefulWidget {
  const OccasionsScreen({Key? key}) : super(key: key);

  @override
  State<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends State<OccasionsScreen> {
  String _query = '';
  String _category = 'all';

  Map<String, String> _categoryLabels(AppLocalizations l10n) => {
        'all': l10n.categoryAll,
        'official': l10n.catOfficial,
        'religious': l10n.catReligious,
        'ancient': l10n.catAncient,
        'international': l10n.catInternational,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CalendarProvider>();
    final usePersian = provider.settings.showPersianNumbers;
    final year = provider.currentDate.year;
    final today = JalaliDate.fromGregorian(DateTime.now());

    // Resolve every occasion for the displayed year, sorted by date.
    final all = Holiday.occurrencesForJalaliYear(year)
      ..sort((a, b) =>
          a.month != b.month ? a.month - b.month : a.day - b.day);

    final normalizedQuery = _query.trim();
    final items = all.where((h) {
      final matchesCat = _category == 'all' || h.type == _category;
      final matchesQuery =
          normalizedQuery.isEmpty || h.name.contains(normalizedQuery);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.occasions)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchOccasion,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categoryLabels(l10n).entries.map((e) {
                final selected = _category == e.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(l10n.noResults))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        _buildTile(context, items[i], year, today, usePersian),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, Holiday h, int year,
      JalaliDate today, bool usePersian) {
    final l10n = AppLocalizations.of(context);
    final date = JalaliDate(year: year, month: h.month, day: h.day);
    final gregorian = date.toGregorian();
    final todayGregorian = today.toGregorian();
    final daysLeft = DateTime(gregorian.year, gregorian.month, gregorian.day)
        .difference(DateTime(
            todayGregorian.year, todayGregorian.month, todayGregorian.day))
        .inDays;
    final color = _categoryColor(h.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(h.type), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          h.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (h.isDayOff)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.dayOff,
                            style: TextStyle(
                                fontSize: 11, color: Colors.red.shade400),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CalendarUtils.formatNumber(date.day, usePersian: usePersian)} ${date.getMonthName()}'
                    '  •  ${_categoryLabels(l10n)[h.type] ?? ''}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (h.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      h.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _countdownLabel(context, daysLeft, usePersian),
          ],
        ),
      ),
    );
  }

  Widget _countdownLabel(BuildContext context, int daysLeft, bool usePersian) {
    final l10n = AppLocalizations.of(context);
    final String text;
    final Color color;
    if (daysLeft == 0) {
      text = l10n.today;
      color = Theme.of(context).colorScheme.primary;
    } else if (daysLeft > 0) {
      text = '${CalendarUtils.formatNumber(daysLeft, usePersian: usePersian)}\n${l10n.daysRemainingLabel}';
      color = Colors.green.shade400;
    } else {
      text = l10n.past;
      color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    }
    return SizedBox(
      width: 58,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Color _categoryColor(String type) {
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

  IconData _categoryIcon(String type) {
    switch (type) {
      case 'official':
        return Icons.flag;
      case 'religious':
        return Icons.mosque;
      case 'ancient':
        return Icons.local_fire_department;
      case 'international':
        return Icons.public;
      default:
        return Icons.event;
    }
  }
}
