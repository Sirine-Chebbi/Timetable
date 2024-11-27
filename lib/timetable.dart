import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final String apiUrl = 'http://localhost:3000/sessions';
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          sessions = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch sessions. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching sessions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> addSession(Map<String, dynamic> newSession) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newSession),
      );

      if (response.statusCode == 201) {
        // Add the new session to the list locally
        setState(() {
          sessions.add(newSession);
        });
        showError('Session added successfully');
      } else {
        showError('Failed to add session');
      }
    } catch (e) {
      showError('Error adding session: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.teal,
                          width: 1.5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(100),
                          1: FixedColumnWidth(100),
                          2: FixedColumnWidth(100),
                          3: FixedColumnWidth(100),
                          4: FixedColumnWidth(100),
                          5: FixedColumnWidth(100),
                          6: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                            ),
                            children: [
                              const TableCell(child: Center(child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                              for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                TableCell(child: Center(child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                            ],
                          ),
                          for (String time in _timeSlots())
                            TableRow(
                              decoration: BoxDecoration(
                                color: _timeSlots().indexOf(time) % 2 == 0 ? Colors.teal.shade50 : Colors.white,
                              ),
                              children: [
                                TableCell(child: Center(child: Text(time, style: const TextStyle(fontSize: 14)))),
                                for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                  TableCell(child: _getSessionForDayAndTime(day, time)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<String> _timeSlots() {
    return [
      '08:00 - 09:00',
      '09:00 - 10:00',
      '10:00 - 11:00',
      '11:00 - 12:00',
      '12:00 - 13:00',
      '13:00 - 14:00',
      '14:00 - 15:00',
    ];
  }

  Widget _getSessionForDayAndTime(String day, String time) {
    final session = sessions.firstWhere(
      (session) {
        final sessionDate = DateTime.parse(session['session_date']);
        final sessionDay = _getDayFromDate(sessionDate);
        final sessionTime = session['start_time'];

        return sessionDay == day && sessionTime == time.split(' - ')[0];
      },
      orElse: () => {},
    );

    if (session.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No session', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session['subject_id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Teacher: ${session['teacher_id']}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _getDayFromDate(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      default:
        return '';
    }
  }
}
