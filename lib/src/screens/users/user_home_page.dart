import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/screens/users/map_screen.dart';
import 'package:masjid_locator/src/widgets/location_adjust.dart';
import 'package:masjid_locator/src/widgets/location_widget.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/services/location_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService =
      LocationService(); // Use the new LocationService

  Position? _currentPosition;
  String? _currentAddress;

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
        // Fetch address from coordinates
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Masjid Locator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.black,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Masjid Locator',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),

                // Location Widget
                LocationWidget(
                  location: _currentAddress,
                  onTap: _openLocationAdjustScreen,
                  color: Colors.white,
                ),

                const SizedBox(height: 30),

                // Nearby Mosques Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NearbyMosquesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text(
                      'Nearby Mosques',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 30),
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
