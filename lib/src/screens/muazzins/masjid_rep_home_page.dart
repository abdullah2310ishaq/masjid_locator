import 'package:flutter/material.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/services/mosques_service.dart'; // For fetching and updating mosque details

class MuadhinHomePage extends StatefulWidget {
  const MuadhinHomePage({super.key});

  @override
  _MuadhinHomePageState createState() => _MuadhinHomePageState();
}

class _MuadhinHomePageState extends State<MuadhinHomePage> {
  final AuthService _authService = AuthService();
  final MosqueService _mosqueService = MosqueService(); // For handling mosque-related data
  String? mosqueName;
  String? currentPrayer;
  String? nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _fetchMosqueDetails(); // Fetch mosque details on page load
  }

  // Fetch mosque details
  Future<void> _fetchMosqueDetails() async {
    try {
      var mosqueDetails = await _mosqueService.getMosqueDetails();
      setState(() {
        mosqueName = mosqueDetails['mosqueName'];
        currentPrayer = mosqueDetails['currentPrayer'];
        nextPrayerTime = mosqueDetails['nextPrayerTime'];
      });
    } catch (e) {
      print("Error fetching mosque details: $e");
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to save updated mosque details and prayer times
  Future<void> _updateMosqueDetails() async {
    try {
      await _mosqueService.updateMosqueDetails({
        'mosqueName': mosqueName,
        'currentPrayer': currentPrayer,
        'nextPrayerTime': nextPrayerTime,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mosque details updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update mosque details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muadhin Home'),
        backgroundColor: const Color(0xFF2E2E2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Display welcome message
            const Text(
              'Welcome, Muadhin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Edit Mosque Details Section
            _buildMosqueDetailsForm(),

            const SizedBox(height: 20),

            // Save button
            ElevatedButton(
              onPressed: _updateMosqueDetails,
              child: const Text('Save Mosque Details'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build mosque details form
  Widget _buildMosqueDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mosque Name
        TextField(
          decoration: const InputDecoration(
            labelText: 'Mosque Name',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: mosqueName),
          onChanged: (value) {
            setState(() {
              mosqueName = value;
            });
          },
        ),
        const SizedBox(height: 20),

        // Current Prayer
        TextField(
          decoration: const InputDecoration(
            labelText: 'Current Prayer',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: currentPrayer),
          onChanged: (value) {
            setState(() {
              currentPrayer = value;
            });
          },
        ),
        const SizedBox(height: 20),

        // Next Prayer Time
        TextField(
          decoration: const InputDecoration(
            labelText: 'Next Prayer Time',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: nextPrayerTime),
          onChanged: (value) {
            setState(() {
              nextPrayerTime = value;
            });
          },
        ),
      ],
    );
  }
}
