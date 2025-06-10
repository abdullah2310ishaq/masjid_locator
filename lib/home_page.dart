import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masjid_locator/time_line.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
 // To be created

// State management for location
class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } else {
        _errorMessage = 'Location permission denied. Please enable it in settings.';
      }
    } catch (e) {
      _errorMessage = 'Failed to get location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  if (locationProvider.isLoading) {
                    return const SpinKitCircle(color: Colors.white, size: 50.0);
                  }
                  if (locationProvider.errorMessage != null) {
                    return _buildErrorWidget(context, locationProvider.errorMessage!);
                  }
                  if (locationProvider.currentPosition != null) {
                    return _buildLocationSuccessWidget(context);
                  }
                  return _buildWelcomeWidget(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Masjid Locator - Islamabad',
            style: GoogleFonts.almarai(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Find mosques and prayer times near you',
            style: GoogleFonts.almarai(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Provider.of<LocationProvider>(context, listen: false).getUserLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Grant Location Access',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Implement manual location selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual location selection coming soon!')),
              );
            },
            child: Text(
              'Select Location Manually',
              style: GoogleFonts.almarai(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: GoogleFonts.almarai(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: openAppSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Open Settings',
              style: GoogleFonts.almarai(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSuccessWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Location accessed successfully!',
            style: GoogleFonts.almarai(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to Prayer Timelines
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimelineScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View Prayer Times',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to Mosques Near Me screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mosques Near Me coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Find Mosques Near Me',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}