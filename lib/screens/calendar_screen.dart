import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_service.dart';
import '../services/google_auth_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final GoogleAuthService _authService;
  late final CalendarService _calendarService;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _events = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = GoogleAuthService();
    _calendarService = CalendarService(authService: _authService);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final events = await _calendarService.fetchEvents();
      if (mounted) {
        setState(() => _events = events);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () async {
              await _authService.signIn();
              await _loadEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              setState(() => _events = []);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) => _events.where((event) {
                    final start = event.start?.date ?? event.start?.dateTime;
                    return start != null && isSameDay(start, day);
                  }).toList(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return ListTile(
                        title: Text(event.summary ?? 'No title'),
                        subtitle: Text(
                          event.start?.date?.toString() ?? 
                          event.start?.dateTime?.toString() ?? 
                          'No date specified',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}