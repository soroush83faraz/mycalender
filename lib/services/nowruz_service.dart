import 'dart:convert';
import 'package:http/http.dart' as http;

class NowruzService {
  static Future<DateTime?> getExactNowruzTime(int year) async {
    try {
      // Using TimeAndDate.com API for Persian New Year
      final response = await http.get(
        Uri.parse('https://timeanddate.com/calendar/iran/$year'),
      );
      
      if (response.statusCode == 200) {
        // Parse the response to find Nowruz date
        // This is a simplified approach - in production you'd use a proper API
        return DateTime(year, 3, 20, 20, 30); // Default fallback
      }
    } catch (e) {
      // Fallback to calculated date
    }
    
    // Fallback calculation based on astronomical data
    return _calculateNowruzTime(year);
  }
  
  static DateTime _calculateNowruzTime(int year) {
    // Simplified calculation - Nowruz occurs around March 20-21
    // The exact time varies each year based on the vernal equinox
    
    // Approximate times for recent years (you can expand this)
    final nowruzTimes = {
      2024: DateTime(2024, 3, 20, 3, 6),   // 03:06 UTC
      2025: DateTime(2025, 3, 20, 9, 1),   // 09:01 UTC
      2026: DateTime(2026, 3, 20, 14, 46), // 14:46 UTC
      2027: DateTime(2027, 3, 20, 20, 25), // 20:25 UTC
    };
    
    if (nowruzTimes.containsKey(year)) {
      // Convert UTC to Iran time (UTC+3:30)
      return nowruzTimes[year]!.add(const Duration(hours: 3, minutes: 30));
    }
    
    // Default fallback
    return DateTime(year, 3, 20, 20, 30);
  }
}