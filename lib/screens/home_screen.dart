import 'package:flutter/material.dart';
import '../models/jalali_date.dart';
import '../utils/calendar_utils.dart';
import '../widgets/calendar_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late JalaliDate _currentDate;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentDate = JalaliDate.fromGregorian(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم فارسی'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month and Year header
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                    Column(
                      children: [
                        Text(
                          _currentDate.getMonthName(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CalendarUtils.toPersianNumber(_currentDate.year),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Calendar grid
              CalendarGrid(
                year: _currentDate.year,
                month: _currentDate.month,
                selectedDay: _selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    _selectedDay = day;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Selected day info
              if (_selectedDay != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تاریخ انتخاب شده:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${CalendarUtils.toPersianNumber(_selectedDay!)} ${_currentDate.getMonthName()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${JalaliDate.getWeekdayName(
                              _getGregorianDate(_selectedDay!).weekday - 1,
                            )})',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentDate = JalaliDate.fromGregorian(DateTime.now());
            _selectedDay = null;
          });
        },
        child: const Icon(Icons.today),
      ),
    );
  }

  void _nextMonth() {
    setState(() {
      if (_currentDate.month == 12) {
        _currentDate = JalaliDate(
          year: _currentDate.year + 1,
          month: 1,
          day: 1,
        );
      } else {
        _currentDate = JalaliDate(
          year: _currentDate.year,
          month: _currentDate.month + 1,
          day: 1,
        );
      }
      _selectedDay = null;
    });
  }

  void _previousMonth() {
    setState(() {
      if (_currentDate.month == 1) {
        _currentDate = JalaliDate(
          year: _currentDate.year - 1,
          month: 12,
          day: 1,
        );
      } else {
        _currentDate = JalaliDate(
          year: _currentDate.year,
          month: _currentDate.month - 1,
          day: 1,
        );
      }
      _selectedDay = null;
    });
  }

  DateTime _getGregorianDate(int day) {
    final jalaliDate = JalaliDate(
      year: _currentDate.year,
      month: _currentDate.month,
      day: day,
    );
    return CalendarUtils.toGregorian(jalaliDate);
  }
}
