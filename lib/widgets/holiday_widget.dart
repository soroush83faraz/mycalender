import 'package:flutter/material.dart';
import '../models/holiday.dart';

class HolidayWidget extends StatelessWidget {
  final List<Holiday> holidays;

  const HolidayWidget({Key? key, required this.holidays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: _getHolidayColor(holidays.first.type),
                ),
                const SizedBox(width: 8),
                Text(
                  'مناسبتهای روز',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getHolidayColor(holidays.first.type),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...holidays.map((holiday) => _buildHolidayItem(context, holiday)),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayItem(BuildContext context, Holiday holiday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getHolidayColor(holiday.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getHolidayColor(holiday.type),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getHolidayColor(holiday.type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getHolidayTypeLabel(holiday.type),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (holiday.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    holiday.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHolidayColor(String type) {
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

  String _getHolidayTypeLabel(String type) {
    switch (type) {
      case 'official':
        return 'رسمی';
      case 'religious':
        return 'مذهبی';
      case 'ancient':
        return 'باستانی';
      case 'international':
        return 'جهانی';
      default:
        return 'سایر';
    }
  }
}