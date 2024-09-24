import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/services/prayer_services.dart';

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({Key? key, required Null Function() onTap})
      : super(key: key);

  @override
  State<PrayerTimeWidget> createState() => _PrayerTimeWidgetState();
}

class _PrayerTimeWidgetState extends State<PrayerTimeWidget> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final LocationService _locationService = LocationService();

  PrayerTimes? _prayerTimes;
  String? _currentPrayer;
  String? _nextPrayer;
  DateTime? _nextPrayerTime;
  int _remainingHours = 0;
  int _remainingMinutes = 0;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        final coordinates = LatLng(position.latitude, position.longitude);

        // Fetch prayer times
        final prayerTimes =
            _prayerTimeService.getPrayerTimes(coordinates, Madhab.hanafi);

        // Fetch current and next prayer info
        final currentPrayer = _prayerTimeService.getCurrentPrayer(prayerTimes);
        final nextPrayerInfo = _prayerTimeService.getNextPrayer(prayerTimes);

        setState(() {
          _prayerTimes = prayerTimes;
          _currentPrayer = currentPrayer;
          _nextPrayer = nextPrayerInfo['nextPrayer'];
          _nextPrayerTime = nextPrayerInfo['time'];
          _remainingHours = nextPrayerInfo['remainingHours'];
          _remainingMinutes = nextPrayerInfo['remainingMinutes'];
        });

        // Start countdown for next prayer
        _startCountdownTimer();
      }
    } catch (e) {
      print("Error fetching prayer times: $e");
    }
  }

  void _startCountdownTimer() {
    const oneMinute = Duration(minutes: 1);
    Timer.periodic(oneMinute, (Timer timer) {
      if (_nextPrayerTime != null) {
        setState(() {
          final nextPrayerInfo =
              _prayerTimeService.getNextPrayer(_prayerTimes!);
          _remainingHours = nextPrayerInfo['remainingHours'];
          _remainingMinutes = nextPrayerInfo['remainingMinutes'];

          if (_remainingHours == 0 && _remainingMinutes == 0) {
            _fetchPrayerTimes();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/good.png'), // Background illustration
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topRight,
              colors: [
                Colors.black.withOpacity(0.5), // Darker at the bottom
                Colors.white60, // Transparent at the top
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current prayer
              Text(
                '$_currentPrayer',
                style: const TextStyle(
                  fontSize: 22, // Slightly smaller font for current prayer
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White color for contrast
                ),
              ),
              const SizedBox(height: 10), // Adjusted space

              // Next prayer with time
              if (_nextPrayerTime != null)
                Text(
                  'Next: $_nextPrayer at ${DateFormat.jm().format(_nextPrayerTime!)}',
                  style: const TextStyle(
                    fontSize: 16, // Slightly smaller font for time
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10), // Adjusted space

              // Time until next prayer
              Text(
                'Time until next prayer: $_remainingHours hrs $_remainingMinutes mins',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
