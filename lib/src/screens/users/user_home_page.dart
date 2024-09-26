import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/screens/users/mosque_detail.dart';
import 'package:masjid_locator/src/screens/users/nearby.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/widgets/location_adjust.dart';
import 'package:masjid_locator/src/widgets/location_widget.dart';
import 'package:masjid_locator/src/widgets/mosque_nearme.dart';
import 'package:masjid_locator/src/widgets/prayer_time.dart';
import 'package:masjid_locator/src/widgets/prayer_timeline.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;

  List<Map<String, String>> mosques = [
    {
      "mosqueName": "Masjid Ibrahim",
      "currentPrayer": "Dhuhr",
      "nextPrayerTime": "Asr: 3:56 PM"
    },
    {
      "mosqueName": "Madni Masjid",
      "currentPrayer": "Fajr",
      "nextPrayerTime": "Dhuhr: 12:45 PM"
    },
    {
      "mosqueName": "Makki Masjid",
      "currentPrayer": "Isha",
      "nextPrayerTime": "Fajr: 6:00 AM"
    },
    {
      "mosqueName": "University Masjid",
      "currentPrayer": "Maghrib",
      "nextPrayerTime": "Isha: 7:00 PM"
    }
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        String? address = await _locationService.getAddressFromLatLng(
          LatLng(position.latitude, position.longitude),
        );
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _openLocationAdjustScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationAdjustWidget(),
      ),
    );

    if (result != null && result is LatLng) {
      String? newAddress = await _locationService.getAddressFromLatLng(result);
      setState(() {
        _currentAddress = newAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing user details via AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final String userName = authProvider.userModel?.name ?? 'User'; // Default to 'User' if name is null

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Masjid Locator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome message with the user's name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FixedLocationWidget(
              location: _currentAddress,
              onTap: _openLocationAdjustScreen,
            ),
          ),
          const SizedBox(height: 20),

          // Two buttons to navigate to pages
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearbyMosquesMap()), // Navigate to Nearby Mosques Screen
              );
            },
            child: const Text('Find Nearby Mosques'),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrayerTimelineWidget(),
                  const SizedBox(height: 10),
                  PrayerTimeWidget(onTap: () {}),
                  const SizedBox(height: 30),
                  _buildNearbyMosquesHeader(),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mosques.length,
                    itemBuilder: (context, index) {
                      final mosque = mosques[index];
                      return MosqueCard(
                        mosqueName: mosque["mosqueName"]!,
                        currentPrayer: mosque["currentPrayer"]!,
                        nextPrayerTime: mosque["nextPrayerTime"]!,
                        onTap: () =>
                            _openMosqueDetails(context, mosque["mosqueName"]!),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyMosquesHeader() {
    return Text(
      'Mosques Near Me',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.9),
      ),
    );
  }

  void _openMosqueDetails(BuildContext context, String mosqueName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MosqueDetailPage(mosqueName: mosqueName),
      ),
    );
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
