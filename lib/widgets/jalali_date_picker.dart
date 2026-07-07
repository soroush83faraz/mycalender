import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/jalali_date.dart';
import '../utils/calendar_utils.dart';

/// Shows a Jalali (Persian) date picker dialog and returns the picked date,
/// or null if dismissed. Replaces Flutter's Gregorian [showDatePicker] for
/// every user-facing date entry so dates are picked the way they are shown.
Future<JalaliDate?> showJalaliDatePicker(
  BuildContext context, {
  required JalaliDate initialDate,
  int? firstYear,
  int? lastYear,
}) {
  return showDialog<JalaliDate>(
    context: context,
    builder: (context) => _JalaliDatePickerDialog(
      initialDate: initialDate,
      firstYear: firstYear ?? initialDate.year - 100,
      lastYear: lastYear ?? initialDate.year + 50,
    ),
  );
}

class _JalaliDatePickerDialog extends StatefulWidget {
  const _JalaliDatePickerDialog({
    required this.initialDate,
    required this.firstYear,
    required this.lastYear,
  });

  final JalaliDate initialDate;
  final int firstYear;
  final int lastYear;

  @override
  State<_JalaliDatePickerDialog> createState() =>
      _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<_JalaliDatePickerDialog> {
  late int _year;
  late int _month;
  late int _day;

  static const List<String> _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year.clamp(widget.firstYear, widget.lastYear);
    _month = widget.initialDate.month.clamp(1, 12);
    _day = widget.initialDate.day;
    _clampDay();
  }

  void _clampDay() {
    final max = CalendarUtils.getDaysInMonth(_year, _month);
    if (_day > max) _day = max;
    if (_day < 1) _day = 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final daysInMonth = CalendarUtils.getDaysInMonth(_year, _month);
    final selected = JalaliDate(year: _year, month: _month, day: _day);
    final gregorian = selected.toGregorian();
    final weekdayName = JalaliDate.getWeekdayName(
      CalendarUtils.gregorianWeekdayToPersianIndex(gregorian.weekday),
    );

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectDate, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            '$weekdayName ${CalendarUtils.toPersianNumber(_day)} ${_monthNames[_month - 1]} ${CalendarUtils.toPersianNumber(_year)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          Text(
            '${gregorian.year}/${gregorian.month.toString().padLeft(2, '0')}/${gregorian.day.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 330,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── year stepper ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _year > widget.firstYear
                        ? () => setState(() {
                              _year--;
                              _clampDay();
                            })
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      CalendarUtils.toPersianNumber(_year),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _year < widget.lastYear
                        ? () => setState(() {
                              _year++;
                              _clampDay();
                            })
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ── month grid ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 2.1,
                children: [
                  for (var m = 1; m <= 12; m++)
                    _pickCell(
                      label: _monthNames[m - 1],
                      selected: m == _month,
                      onTap: () => setState(() {
                        _month = m;
                        _clampDay();
                      }),
                      fontSize: 11.5,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                  height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 10),
              // ── day grid ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (var d = 1; d <= daysInMonth; d++)
                    _pickCell(
                      label: CalendarUtils.toPersianNumber(d),
                      selected: d == _day,
                      onTap: () => setState(() => _day = d),
                      fontSize: 12.5,
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            JalaliDate(year: _year, month: _month, day: _day),
          ),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }

  Widget _pickCell({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? null
              : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
