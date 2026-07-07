import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../models/event.dart';
import '../models/jalali_date.dart';
import '../utils/calendar_utils.dart';
import '../utils/responsive_helper.dart';
import '../l10n/app_localizations.dart';
import 'add_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context);
        final filteredEvents = _getFilteredEvents(provider.events);
        final canEdit = provider.activeMembershipRole != 'viewer';

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.navEvents),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(),
                ],
              ),
            ),
          ),
          body: AdaptiveContent(
            child: filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(context, filteredEvents[index]);
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: canEdit
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEventScreen(),
                      ),
                    );
                  }
                : null,
            tooltip: canEdit ? null : l10n.viewerCannotAdd,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchEvents,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final l10n = AppLocalizations.of(context);
    final categories = {
      'all': l10n.categoryAll,
      'personal': l10n.categoryPersonal,
      'work': l10n.categoryWork,
      'family': l10n.categoryFamily,
      'health': l10n.categoryHealth,
      'education': l10n.categoryEducation,
      'other': l10n.categoryOther,
    };

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: _selectedCategory == entry.key,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = entry.key;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noEventsFound,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).addEventHint,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final l10n = AppLocalizations.of(context);
    final jalaliDate = JalaliDate.fromGregorian(event.date);
    final isUpcoming = event.date.isAfter(DateTime.now());
    final daysDifference = event.date.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      Color(int.parse(event.color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (event.hasReminder)
                          Icon(
                            Icons.notifications,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CalendarUtils.toPersianNumber(jalaliDate.day)} ${jalaliDate.getMonthName()} ${CalendarUtils.toPersianNumber(jalaliDate.year)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isUpcoming && daysDifference >= 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysDifference == 0
                              ? Colors.red.withOpacity(0.1)
                              : daysDifference <= 7
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          daysDifference == 0
                              ? l10n.today
                              : daysDifference == 1
                                  ? l10n.tomorrow
                                  : l10n.daysLeft(CalendarUtils
                                      .toPersianNumber(daysDifference)),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: daysDifference == 0
                                ? Colors.red
                                : daysDifference <= 7
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    CalendarUtils.toPersianNumber(event.date.hour),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CalendarUtils.toPersianNumber(
                        event.date.minute.toString().padLeft(2, '0')),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    var filtered = events.where((event) {
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'all' || event.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by date
    filtered.sort((a, b) => a.date.compareTo(b.date));

    return filtered;
  }
}
