import 'package:flutter/material.dart';
import '/auth/login_page.dart';
import '/auth/auth_utils.dart';
import 'room.dart';
import 'teachers.dart';
import 'subjects.dart';
import 'classes.dart';
import 'sessions.dart';
import 'students.dart';
import 'timetable.dart';
import '/auth/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/main': (context) => const HomePage(),
      },
      home: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

// HomePage with Titles and Navigation Buttons
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await clearToken(); // Clear the token
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Class Management'),
            _buildButton(context, 'Classes', const ClassesPage()),
            _buildButton(context, 'Rooms', const RoomsPage()),
            const Divider(height: 40, thickness: 2),
            const SectionTitle(title: 'Teacher Management'),
            _buildButton(context, 'Teachers', const TeachersPage()),
            const Divider(height: 40, thickness: 2),
            const SectionTitle(title: 'Student Management'),
            _buildButton(context, 'Students', const StudentsPage()),
            const Divider(height: 40, thickness: 2),
            const SectionTitle(title: 'Course Management'),
            _buildButton(context, 'Subjects', const SubjectsPage()),
            _buildButton(context, 'Sessions', const SessionsPage()),
            const Divider(height: 40, thickness: 2),
            const SectionTitle(title: 'Timetable Management'),
            _buildButton(context, 'Timetable', const TimetablePage()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, Widget targetPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Section title widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}
