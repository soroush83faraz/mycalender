import 'package:flutter/material.dart';
import '../services/date_conversion_service.dart';
import '../services/nowruz_service.dart';
import '../models/jalali_date.dart';
import '../utils/calendar_utils.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ابزارها'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolCard(
            context,
            'تبدیل تاریخ',
            'تبدیل بین تقویم شمسی، میلادی و قمری',
            Icons.swap_horiz,
            () => _showDateConverter(context),
          ),
          _buildToolCard(
            context,
            'محاسبه سن',
            'محاسبه سن بر اساس تاریخ تولد',
            Icons.cake,
            () => _showAgeCalculator(context),
          ),
          _buildToolCard(
            context,
            'اختلاف دو تاریخ',
            'محاسبه فاصله زمانی بین دو تاریخ',
            Icons.date_range,
            () => _showDateDifference(context),
          ),
          _buildToolCard(
            context,
            'روزشمار',
            'شمارش روزهای باقیمانده تا رویداد',
            Icons.timer,
            () => _showCountdown(context),
          ),
          _buildToolCard(
            context,
            'لحظه سال تحویل',
            'نمایش زمان دقیق سال تحویل',
            Icons.celebration,
            () => _showNewYearCountdown(context),
          ),
          _buildToolCard(
            context,
            'ساعت جهانی',
            'نمایش ساعت شهرهای مختلف جهان',
            Icons.public,
            () => _showWorldClock(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BidirectionalDateConverterWidget(),
    );
  }

  void _showAgeCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AgeCalculatorWidget(),
    );
  }

  void _showDateDifference(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const DateDifferenceWidget(),
    );
  }

  void _showCountdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CountdownWidget(),
    );
  }

  void _showNewYearCountdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NewYearCountdownWidget(),
    );
  }

  void _showWorldClock(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const WorldClockWidget(),
    );
  }
}

class DateConverterWidget extends StatefulWidget {
  const DateConverterWidget({Key? key}) : super(key: key);

  @override
  State<DateConverterWidget> createState() => _DateConverterWidgetState();
}

class _DateConverterWidgetState extends State<DateConverterWidget> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final jalali = JalaliDate.fromGregorian(selectedDate);
    final hijri = DateConversionService.gregorianToHijri(selectedDate);
    final hijriMonths = DateConversionService.getHijriMonthNames();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'تبدیل تاریخ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            },
            child: const Text('انتخاب تاریخ'),
          ),
          const SizedBox(height: 24),
          _buildDateCard(
            'شمسی (هجری شمسی)',
            '${CalendarUtils.toPersianNumber(jalali.day)} ${jalali.getMonthName()} ${CalendarUtils.toPersianNumber(jalali.year)}',
            Icons.wb_sunny,
            Colors.orange,
          ),
          _buildDateCard(
            'میلادی (گریگوری)',
            '${selectedDate.day} ${_getGregorianMonthName(selectedDate.month)} ${selectedDate.year}',
            Icons.calendar_today,
            Colors.blue,
          ),
          _buildDateCard(
            'قمری (هجری قمری)',
            '${CalendarUtils.toPersianNumber(hijri['day']!)} ${hijriMonths[hijri['month']! - 1]} ${CalendarUtils.toPersianNumber(hijri['year']!)}',
            Icons.nightlight_round,
            Colors.green,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, String date, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class BidirectionalDateConverterWidget extends StatefulWidget {
  const BidirectionalDateConverterWidget({Key? key}) : super(key: key);

  @override
  State<BidirectionalDateConverterWidget> createState() =>
      _BidirectionalDateConverterWidgetState();
}

class _BidirectionalDateConverterWidgetState
    extends State<BidirectionalDateConverterWidget> {
  DateTime selectedDate = DateTime.now();
  String sourceType = 'gregorian';
  late final TextEditingController _jalaliYearController;
  late final TextEditingController _jalaliMonthController;
  late final TextEditingController _jalaliDayController;
  String? _jalaliError;

  @override
  void initState() {
    super.initState();
    _jalaliYearController = TextEditingController();
    _jalaliMonthController = TextEditingController();
    _jalaliDayController = TextEditingController();
    _syncJalaliInputsFromSelectedDate();
  }

  @override
  void dispose() {
    _jalaliYearController.dispose();
    _jalaliMonthController.dispose();
    _jalaliDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jalali = JalaliDate.fromGregorian(selectedDate);
    final hijri = DateConversionService.gregorianToHijri(selectedDate);
    final hijriMonths = DateConversionService.getHijriMonthNames();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'تبدیل تاریخ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('مبدا میلادی'),
                  selected: sourceType == 'gregorian',
                  onSelected: (_) {
                    setState(() {
                      sourceType = 'gregorian';
                      _jalaliError = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('مبدا شمسی'),
                  selected: sourceType == 'jalali',
                  onSelected: (_) {
                    setState(() {
                      sourceType = 'jalali';
                      _jalaliError = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sourceType == 'gregorian')
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    _syncJalaliInputsFromSelectedDate();
                  });
                }
              },
              child: const Text('انتخاب تاریخ میلادی'),
            ),
          if (sourceType == 'jalali') ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _jalaliYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'سال'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _jalaliMonthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ماه'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _jalaliDayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'روز'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyJalaliInput,
                    child: const Text('تبدیل از شمسی'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime.now();
                        _jalaliError = null;
                        _syncJalaliInputsFromSelectedDate();
                      });
                    },
                    child: const Text('امروز'),
                  ),
                ),
              ],
            ),
            if (_jalaliError != null) ...[
              const SizedBox(height: 8),
              Text(
                _jalaliError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          _buildDateCard(
            'شمسی (هجری شمسی)',
            '${CalendarUtils.toPersianNumber(jalali.day)} ${jalali.getMonthName()} ${CalendarUtils.toPersianNumber(jalali.year)}',
            Icons.wb_sunny,
            Colors.orange,
          ),
          _buildDateCard(
            'میلادی (گریگوری)',
            '${selectedDate.day} ${_getGregorianMonthName(selectedDate.month)} ${selectedDate.year}',
            Icons.calendar_today,
            Colors.blue,
          ),
          _buildDateCard(
            'قمری (هجری قمری)',
            '${CalendarUtils.toPersianNumber(hijri['day']!)} ${hijriMonths[hijri['month']! - 1]} ${CalendarUtils.toPersianNumber(hijri['year']!)}',
            Icons.nightlight_round,
            Colors.green,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, String date, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _syncJalaliInputsFromSelectedDate() {
    final jalali = JalaliDate.fromGregorian(selectedDate);
    _jalaliYearController.text = jalali.year.toString();
    _jalaliMonthController.text = jalali.month.toString();
    _jalaliDayController.text = jalali.day.toString();
  }

  void _applyJalaliInput() {
    final year = int.tryParse(_normalizeDigits(_jalaliYearController.text));
    final month = int.tryParse(_normalizeDigits(_jalaliMonthController.text));
    final day = int.tryParse(_normalizeDigits(_jalaliDayController.text));

    if (year == null || month == null || day == null) {
      setState(() {
        _jalaliError = 'سال، ماه و روز را به صورت عددی وارد کنید.';
      });
      return;
    }

    if (month < 1 || month > 12) {
      setState(() {
        _jalaliError = 'ماه باید بین 1 تا 12 باشد.';
      });
      return;
    }

    final maxDay = CalendarUtils.getDaysInMonth(year, month);
    if (day < 1 || day > maxDay) {
      setState(() {
        _jalaliError = 'روز برای این ماه باید بین 1 تا $maxDay باشد.';
      });
      return;
    }

    setState(() {
      selectedDate = JalaliDate(year: year, month: month, day: day).toGregorian();
      _jalaliError = null;
    });
  }

  String _normalizeDigits(String input) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var output = input;
    for (var i = 0; i < 10; i++) {
      output = output.replaceAll(persianDigits[i], i.toString());
      output = output.replaceAll(arabicDigits[i], i.toString());
    }
    return output.trim();
  }
}

class AgeCalculatorWidget extends StatefulWidget {
  const AgeCalculatorWidget({Key? key}) : super(key: key);

  @override
  State<AgeCalculatorWidget> createState() => _AgeCalculatorWidgetState();
}

class _AgeCalculatorWidgetState extends State<AgeCalculatorWidget> {
  DateTime? birthDate;
  DateTime? secondBirthDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'محاسبه سن',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  birthDate = date;
                });
              }
            },
            child: Text(birthDate != null ? 'تاریخ تولد انتخاب شده' : 'انتخاب تاریخ تولد'),
          ),
          if (birthDate != null) ...[
            const SizedBox(height: 16),
            _buildAgeResult(birthDate!, 'سن شما'),
          ],
          if (birthDate != null && secondBirthDate != null) ...[
            const SizedBox(height: 16),
            _buildAgeDifference(birthDate!, secondBirthDate!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAgeResult(DateTime birthDate, String title) {
    final age = DateConversionService.calculateAge(birthDate, DateTime.now());
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${CalendarUtils.toPersianNumber(age['years']!)} سال، ${CalendarUtils.toPersianNumber(age['months']!)} ماه، ${CalendarUtils.toPersianNumber(age['days']!)} روز',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDifference(DateTime date1, DateTime date2) {
    final diff = DateConversionService.calculateAge(date1, date2);
    final isOlder = date1.isBefore(date2);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختلاف سن',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${isOlder ? 'نفر اول' : 'نفر دوم'} ${CalendarUtils.toPersianNumber(diff['years']!)} سال، ${CalendarUtils.toPersianNumber(diff['months']!)} ماه، ${CalendarUtils.toPersianNumber(diff['days']!)} روز ${isOlder ? 'بزرگتر' : 'کوچکتر'} است',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class DateDifferenceWidget extends StatefulWidget {
  const DateDifferenceWidget({Key? key}) : super(key: key);

  @override
  State<DateDifferenceWidget> createState() => _DateDifferenceWidgetState();
}

class _DateDifferenceWidgetState extends State<DateDifferenceWidget> {
  DateTime? firstDate;
  DateTime? secondDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'اختلاف دو تاریخ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        firstDate = date;
                      });
                    }
                  },
                  child: Text(firstDate != null ? 'تاریخ اول' : 'انتخاب تاریخ اول'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        secondDate = date;
                      });
                    }
                  },
                  child: Text(secondDate != null ? 'تاریخ دوم' : 'انتخاب تاریخ دوم'),
                ),
              ),
            ],
          ),
          if (firstDate != null && secondDate != null) ...[
            const SizedBox(height: 24),
            _buildDifferenceResult(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDifferenceResult() {
    final diff = DateConversionService.dateDifference(firstDate!, secondDate!);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نتیجه محاسبه',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'فاصله: ${CalendarUtils.toPersianNumber(diff['days']!)} روز',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'معادل: ${CalendarUtils.toPersianNumber(diff['years']!)} سال و ${CalendarUtils.toPersianNumber(diff['months']!)} ماه',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder widgets for other tools
class CountdownWidget extends StatefulWidget {
  const CountdownWidget({Key? key}) : super(key: key);

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  DateTime? targetDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'روزشمار',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  targetDate = date;
                });
              }
            },
            child: Text(targetDate != null ? 'تاریخ هدف انتخاب شده' : 'انتخاب تاریخ هدف'),
          ),
          if (targetDate != null) ...[
            const SizedBox(height: 24),
            _buildCountdownResult(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCountdownResult() {
    final difference = targetDate!.difference(DateTime.now()).inDays;
    final jalaliTarget = JalaliDate.fromGregorian(targetDate!);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'تاریخ هدف: ${CalendarUtils.toPersianNumber(jalaliTarget.day)} ${jalaliTarget.getMonthName()} ${CalendarUtils.toPersianNumber(jalaliTarget.year)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              difference > 0 
                  ? '${CalendarUtils.toPersianNumber(difference)} روز مانده'
                  : difference == 0
                      ? 'امروز!'
                      : '${CalendarUtils.toPersianNumber(difference.abs())} روز گذشته',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: difference > 0 ? Colors.green : difference == 0 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewYearCountdownWidget extends StatefulWidget {
  const NewYearCountdownWidget({Key? key}) : super(key: key);

  @override
  State<NewYearCountdownWidget> createState() => _NewYearCountdownWidgetState();
}

class _NewYearCountdownWidgetState extends State<NewYearCountdownWidget> {
  DateTime? exactNowruzTime;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExactNowruzTime();
  }

  Future<void> _loadExactNowruzTime() async {
    final now = DateTime.now();
    final currentJalali = JalaliDate.fromGregorian(now);
    
    // Determine which year's Nowruz to show
    final currentYear = now.year;
    final thisYearNowruz = await NowruzService.getExactNowruzTime(currentYear);
    
    if (thisYearNowruz != null && now.isBefore(thisYearNowruz)) {
      exactNowruzTime = thisYearNowruz;
    } else {
      exactNowruzTime = await NowruzService.getExactNowruzTime(currentYear + 1);
    }
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (exactNowruzTime == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text('خطا در بارگیری اطلاعات'),
      );
    }

    final now = DateTime.now();
    final nextJalaliYear = JalaliDate.fromGregorian(exactNowruzTime!).year;
    
    // Calculate exact time difference
    final difference = exactNowruzTime!.difference(now);
    final daysUntilNewYear = difference.inDays;
    final hoursLeft = difference.inHours % 24;
    final minutesLeft = difference.inMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نوروز ${CalendarUtils.toPersianNumber(nextJalaliYear)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (daysUntilNewYear > 0) ...[
                    Text(
                      '${CalendarUtils.toPersianNumber(daysUntilNewYear)} روز',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${CalendarUtils.toPersianNumber(hoursLeft)} ساعت و ${CalendarUtils.toPersianNumber(minutesLeft)} دقیقه',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ] else if (daysUntilNewYear == 0) ...[
                    const Text(
                      'امروز نوروز!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'لحظه دقیق: ${CalendarUtils.toPersianNumber(exactNowruzTime!.day)} مارس - ${CalendarUtils.toPersianNumber(exactNowruzTime!.hour)}:${CalendarUtils.toPersianNumber(exactNowruzTime!.minute.toString().padLeft(2, '0'))}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class WorldClockWidget extends StatelessWidget {
  const WorldClockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cities = {
      'تهران': 3.5,
      'لندن': 0,
      'پاریس': 1,
      'نیویورک': -5,
      'توکیو': 9,
      'سیدنی': 11,
      'دبی': 4,
      'استانبول': 3,
    };
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ساعت جهانی',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...cities.entries.map((entry) {
            final cityTime = DateTime.now().toUtc().add(Duration(hours: entry.value.toInt(), minutes: ((entry.value % 1) * 60).toInt()));
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${CalendarUtils.toPersianNumber(cityTime.hour)}:${CalendarUtils.toPersianNumber(cityTime.minute.toString().padLeft(2, '0'))}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
