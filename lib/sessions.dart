import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final String apiUrl = 'http://localhost:3000/sessions';
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  // Méthode pour gérer le token de succès
  void handleSuccessToken(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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

  Future<void> addSession() async {
    final String subject = subjectController.text.trim();
    final String teacher = teacherController.text.trim();
    final String room = roomController.text.trim();
    final String classId = classController.text.trim();
    final String date = dateController.text.trim();
    final String startTime = startTimeController.text.trim();
    final String endTime = endTimeController.text.trim();

    if (subject.isEmpty || teacher.isEmpty || room.isEmpty || classId.isEmpty || date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newSession = {
        'subject_id': subject,
        'teacher_id': teacher,
        'room_id': room,
        'class_id': classId,
        'session_date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newSession),
      );

      if (response.statusCode == 201) {
        fetchSessions();
        Navigator.pop(context);
        handleSuccessToken('Session added successfully!');  // Appeler la méthode de succès ici
      } else {
        showError('Failed to add session.');
      }
    } catch (e) {
      showError('Error adding session. Please try again.');
    }
  }

  Future<void> updateSession(String id) async {
    final String subject = subjectController.text.trim();
    final String teacher = teacherController.text.trim();
    final String room = roomController.text.trim();
    final String classId = classController.text.trim();
    final String date = dateController.text.trim();
    final String startTime = startTimeController.text.trim();
    final String endTime = endTimeController.text.trim();

    if (subject.isEmpty || teacher.isEmpty || room.isEmpty || classId.isEmpty || date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedSession = {
        'subject_id': subject,
        'teacher_id': teacher,
        'room_id': room,
        'class_id': classId,
        'session_date': date,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedSession),
      );

      if (response.statusCode == 200) {
        fetchSessions();
        Navigator.pop(context);
        handleSuccessToken('Session updated successfully!');  // Appeler la méthode de succès ici
      } else {
        showError('Failed to update session.');
      }
    } catch (e) {
      showError('Error updating session. Please try again.');
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchSessions();
        handleSuccessToken('Session deleted successfully!');  // Appeler la méthode de succès ici
      } else {
        showError('Failed to delete session.');
      }
    } catch (e) {
      showError('Error deleting session: $e');
    }
  }

  void showSessionDialog({Map<String, dynamic>? sessionData}) {
    final isEditing = sessionData != null;

    if (isEditing) {
      subjectController.text = sessionData!['subject_id'];
      teacherController.text = sessionData['teacher_id'];
      roomController.text = sessionData['room_id'];
      classController.text = sessionData['class_id'];
      dateController.text = sessionData['session_date'];
      startTimeController.text = sessionData['start_time'];
      endTimeController.text = sessionData['end_time'];
    } else {
      subjectController.clear();
      teacherController.clear();
      roomController.clear();
      classController.clear();
      dateController.clear();
      startTimeController.clear();
      endTimeController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: Text(isEditing ? 'Edit Session' : 'Add Session', style: TextStyle(color: Colors.blueAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(subjectController, 'Subject ID'),
              _buildTextField(teacherController, 'Teacher ID'),
              _buildTextField(roomController, 'Room ID'),
              _buildTextField(classController, 'Class ID'),
              _buildTextField(dateController, 'Session Date (YYYY-MM-DD)'),
              _buildTextField(startTimeController, 'Start Time'),
              _buildTextField(endTimeController, 'End Time'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateSession(sessionData!['id'])
                  : addSession(),
              child: Text(isEditing ? 'Update' : 'Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const Center(
                  child: Text(
                    'No sessions available. Add a new session!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final sessionData = sessions[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text('Session: ${sessionData['class_id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Subject: ${sessionData['subject_id']}, Teacher: ${sessionData['teacher_id']}, Room: ${sessionData['room_id']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showSessionDialog(sessionData: sessionData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteSession(sessionData['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSessionDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
