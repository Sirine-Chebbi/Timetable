import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final String apiUrl = 'http://localhost:3000/rooms';
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController floorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          rooms = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch rooms. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching rooms: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addOrUpdateRoom({Map<String, dynamic>? room}) async {
    final String roomName = roomNameController.text.trim();
    final String capacity = capacityController.text.trim();
    final String building = buildingController.text.trim();
    final String floor = floorController.text.trim();

    if (roomName.isEmpty || capacity.isEmpty || building.isEmpty || floor.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final roomData = {
        'room_name': roomName,
        'capacity': int.parse(capacity),
        'building': building,
        'floor': int.parse(floor),
      };

      final response = room == null
          ? await http.post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(roomData),
            )
          : await http.put(
              Uri.parse('$apiUrl/${room['id']}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(roomData),
            );

      if (response.statusCode == (room == null ? 201 : 200)) {
        fetchRooms();
        Navigator.pop(context);
        showSuccessToast('Room ${room == null ? 'added' : 'updated'} successfully.');
      } else {
        showError('Failed to ${room == null ? 'add' : 'update'} room.');
      }
    } catch (e) {
      showError('Error adding/updating room. Ensure all fields are valid.');
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchRooms();
        showSuccessToast('Room deleted successfully.');
      } else {
        showError('Failed to delete room.');
      }
    } catch (e) {
      showError('Error deleting room: $e');
    }
  }

  void showRoomDialog({Map<String, dynamic>? room}) {
    final isEditing = room != null;

    if (isEditing) {
      roomNameController.text = room?['room_name'] ?? '';
      capacityController.text = room?['capacity']?.toString() ?? '';
      buildingController.text = room?['building'] ?? '';
      floorController.text = room?['floor']?.toString() ?? '';
    } else {
      roomNameController.clear();
      capacityController.clear();
      buildingController.clear();
      floorController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Room' : 'Add Room'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField(
                  controller: roomNameController,
                  label: 'Room Name',
                  icon: Icons.meeting_room,
                ),
                buildTextField(
                  controller: capacityController,
                  label: 'Capacity',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                ),
                buildTextField(
                  controller: buildingController,
                  label: 'Building',
                  icon: Icons.business,
                ),
                buildTextField(
                  controller: floorController,
                  label: 'Floor',
                  icon: Icons.layers,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => addOrUpdateRoom(room: room),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success toast with customized style
  void showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms Management'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    'No rooms available. Add a new room!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Text(
                            room['room_name'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(room['room_name']),
                        subtitle: Text(
                          'Capacity: ${room['capacity']} | Building: ${room['building']} | Floor: ${room['floor']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.indigo),
                              onPressed: () => showRoomDialog(room: room),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteRoom(room['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showRoomDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
