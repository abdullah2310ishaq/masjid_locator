import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:adhan/adhan.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Location location = Location();
  LocationData? _currentPosition;
  double? latitude, longitude;

  // Dropdown selection for madhab (Hanafi or Shafi)
  String _selectedMadhab = 'Hanafi'; // Default to Hanafi
  Madhab _madhab = Madhab.hanafi;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Times'),
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: FutureBuilder(
          future: getLoc(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final myCoordinates =
                Coordinates(33.7699333, 72.8248431); // Placeholder coordinates
            final params = CalculationMethod.karachi.getParameters()
              ..madhab = _madhab; // Set based on selected madhab
            final prayerTimes = PrayerTimes.today(myCoordinates, params);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMadhabDropdown(), // Madhab selection dropdown
                  const SizedBox(height: 20),

                  // Prayer Time Cards
                  _buildPrayerCard(
                      'Fajr', Icons.wb_twighlight, prayerTimes.fajr),
                  _buildPrayerCard('Zuhr', Icons.wb_sunny, prayerTimes.dhuhr),
                  _buildPrayerCard('Asr', Icons.wb_cloudy, prayerTimes.asr),
                  _buildPrayerCard(
                      'Maghrib', Icons.nights_stay, prayerTimes.maghrib),
                  _buildPrayerCard(
                      'Isha', Icons.brightness_2, prayerTimes.isha),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Dropdown for selecting madhab (Hanafi or Shafi)
  Widget _buildMadhabDropdown() {
    return Row(
      children: [
        const Text('Select Madhab:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: _selectedMadhab,
          items: const [
            DropdownMenuItem(
              value: 'Hanafi',
              child: Text('Hanafi'),
            ),
            DropdownMenuItem(
              value: 'Shafi',
              child: Text('Shafi'),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedMadhab = newValue!;
              _madhab = newValue == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;
            });
          },
        ),
      ],
    );
  }

  // Custom prayer time card widget
  Widget _buildPrayerCard(
      String prayerName, IconData icon, DateTime prayerTime) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat.jm().format(prayerTime),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Location fetcher
  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();

    latitude = _currentPosition?.latitude;
    longitude = _currentPosition?.longitude;
  }
}