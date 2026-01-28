import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/calendar_provider.dart';
import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('تنظیمات'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeSection(context, provider),
              const SizedBox(height: 16),
              _buildDisplaySection(context, provider),
              const SizedBox(height: 16),
              _buildNotificationSection(context, provider),
              const SizedBox(height: 16),
              _buildCalendarSection(context, provider),
              const SizedBox(height: 16),
              _buildAboutSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ظاهر و تم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تم خودکار'),
              subtitle: const Text('تغییر خودکار بر اساس تنظیمات سیستم'),
              value: provider.settings.autoTheme,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(autoTheme: value),
                );
              },
            ),
            if (!provider.settings.autoTheme)
              SwitchListTile(
                title: const Text('حالت تاریک'),
                subtitle: const Text('استفاده از تم تاریک'),
                value: provider.settings.isDarkMode,
                onChanged: (value) {
                  provider.updateSettings(
                    provider.settings.copyWith(isDarkMode: value),
                  );
                },
              ),
            ListTile(
              title: const Text('رنگ اصلی'),
              subtitle: const Text('انتخاب رنگ اصلی اپلیکیشن'),
              leading: CircleAvatar(
                backgroundColor: Color(
                  int.parse(provider.settings.primaryColor.replaceFirst('#', '0xFF')),
                ),
                radius: 12,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showColorPicker(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نمایش',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('اعداد فارسی'),
              subtitle: const Text('نمایش اعداد به صورت فارسی'),
              value: provider.settings.showPersianNumbers,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPersianNumbers: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش تقویم میلادی'),
              subtitle: const Text('نمایش همزمان تاریخ میلادی'),
              value: provider.settings.showGregorianCalendar,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showGregorianCalendar: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش تقویم قمری'),
              subtitle: const Text('نمایش همزمان تاریخ قمری'),
              value: provider.settings.showLunarCalendar,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showLunarCalendar: value),
                );
              },
            ),
            ListTile(
              title: const Text('نمای پیشفرض'),
              subtitle: Text(_getViewName(provider.settings.defaultView)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showViewSelector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اعلانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('فعالسازی اعلانات'),
              subtitle: const Text('دریافت اعلان برای رویدادها و یادآورها'),
              value: provider.settings.enableNotifications,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(enableNotifications: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context, CalendarProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تقویم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('نمایش مناسبتها'),
              subtitle: const Text('نمایش تعطیلات و مناسبتهای رسمی'),
              value: provider.settings.showHolidays,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showHolidays: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('نمایش رویدادها'),
              subtitle: const Text('نمایش رویدادهای شخصی در تقویم'),
              value: provider.settings.showEvents,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showEvents: value),
                );
              },
            ),
            SwitchListTile(
              title: const Text('اوقات شرعی'),
              subtitle: const Text('نمایش اوقات شرعی'),
              value: provider.settings.showPrayerTimes,
              onChanged: (value) {
                provider.updateSettings(
                  provider.settings.copyWith(showPrayerTimes: value),
                );
              },
            ),
            ListTile(
              title: const Text('موقعیت جغرافیایی'),
              subtitle: Text(provider.settings.location),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLocationSelector(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'درباره برنامه',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('نسخه'),
              subtitle: const Text('۱.۰.۰'),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('توسعهدهنده'),
              subtitle: const Text('تیم توسعه تقویم فارسی'),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text('ارتباط با ما'),
              subtitle: const Text('ارسال بازخورد و پیشنهادات'),
              leading: const Icon(Icons.email),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showContactDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, CalendarProvider provider) {
    Color currentColor = Color(
      int.parse(provider.settings.primaryColor.replaceFirst('#', '0xFF')),
    );
    
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('انتخاب رنگ'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                provider.updateSettings(
                  provider.settings.copyWith(
                    primaryColor: '#${tempColor.value.toRadixString(16).substring(2)}',
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('تایید'),
            ),
          ],
        );
      },
    );
  }

  void _showViewSelector(BuildContext context, CalendarProvider provider) {
    const views = {
      'month': 'ماهانه',
      'week': 'هفتگی',
      'year': 'سالانه',
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب نمای پیشفرض'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: views.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: provider.settings.defaultView,
                onChanged: (value) {
                  if (value != null) {
                    provider.updateSettings(
                      provider.settings.copyWith(defaultView: value),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLocationSelector(BuildContext context, CalendarProvider provider) {
    const locations = [
      'تهران', 'مشهد', 'اصفهان', 'شیراز', 'تبریز', 'کرج', 'قم', 'اهواز',
      'کرمانشاه', 'ارومیه', 'رشت', 'زاهدان', 'همدان', 'کرمان', 'یزد', 'اردبیل'
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب شهر'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(locations[index]),
                  onTap: () {
                    provider.updateSettings(
                      provider.settings.copyWith(location: locations[index]),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ارتباط با ما'),
          content: const Text(
            'برای ارسال بازخورد، گزارش باگ یا پیشنهادات خود میتوانید با ما در ارتباط باشید.\n\nایمیل: support@persiancalendar.com\nتلگرام: @PersianCalendarSupport',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }

  String _getViewName(String view) {
    switch (view) {
      case 'month':
        return 'ماهانه';
      case 'week':
        return 'هفتگی';
      case 'year':
        return 'سالانه';
      default:
        return 'ماهانه';
    }
  }
}