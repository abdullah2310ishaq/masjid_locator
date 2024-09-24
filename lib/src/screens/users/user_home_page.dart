import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/screens/users/map_screen.dart';
import 'package:masjid_locator/src/widgets/location_adjust.dart';
import 'package:masjid_locator/src/widgets/location_widget.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/widgets/prayer_time.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationWidget(),
            const SizedBox(height: 30),
            PrayerTimeWidget(
              onTap: () {},
            ),
            const SizedBox(height: 40),
            _buildNearbyMosquesHeader(),
            const SizedBox(height: 10),
            _buildMosqueCard('Madni Masjid', 'Madina Market', () {
              _openDirections();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationWidget() {
    return LocationWidget(
      location: _currentAddress,
      onTap: _openLocationAdjustScreen,
      color: Colors.white,
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

  Widget _buildMosqueCard(
      String mosqueName, String mosqueAddress, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.lightBlue.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosqueName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mosqueAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Directions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDirections() {
  
    print('Opening directions...');
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
