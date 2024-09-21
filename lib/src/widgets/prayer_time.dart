import 'dart:async';

import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/services/prayer_services.dart';

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({Key? key}) : super(key: key);

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
  LatLng? _coordinates;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      // Get user location (coordinates)
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _coordinates = LatLng(position.latitude, position.longitude);
        });

        // Calculate prayer times
        final prayerTimes = _prayerTimeService.getPrayerTimes(
          _coordinates!,
          Madhab.hanafi, // Default Madhab
        );

        setState(() {
          _prayerTimes = prayerTimes;
          _currentPrayer = _prayerTimeService.getCurrentPrayer(prayerTimes);

          // Get next prayer and remaining time
          final nextPrayerInfo = _prayerTimeService.getNextPrayer(prayerTimes);
          _nextPrayer = nextPrayerInfo['nextPrayer'];
          _nextPrayerTime = nextPrayerInfo['time'];
          _remainingHours = nextPrayerInfo['remainingHours'];
          _remainingMinutes = nextPrayerInfo['remainingMinutes'];
        });

        // Start the countdown timer
        _startCountdownTimer();
      }
    } catch (e) {
      print("Error fetching prayer times: $e");
    }
  }

  void _startCountdownTimer() {
    // Update the countdown every minute
    const oneMinute = Duration(minutes: 1);
    Timer.periodic(oneMinute, (Timer timer) {
      setState(() {
        if (_nextPrayerTime != null) {
          final nextPrayerInfo =
              _prayerTimeService.getNextPrayer(_prayerTimes!);
          _remainingHours = nextPrayerInfo['remainingHours'];
          _remainingMinutes = nextPrayerInfo['remainingMinutes'];

          // If the countdown reaches zero, fetch new prayer times
          if (_remainingHours == 0 && _remainingMinutes == 0) {
            _fetchPrayerTimes();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Current Prayer
          _buildPrayerCard("Current Prayer: $_currentPrayer", Icons.access_time),
          const SizedBox(height: 20),

          // Display Next Prayer and Countdown
          _buildPrayerCard(
            "Next Prayer: $_nextPrayer",
            Icons.schedule,
            additionalInfo:
                "Time: ${DateFormat.jm().format(_nextPrayerTime!)} | Countdown: $_remainingHours hrs $_remainingMinutes mins",
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(String title, IconData icon,
      {String? additionalInfo}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (additionalInfo != null)
                    const SizedBox(height: 5),
                  if (additionalInfo != null)
                    Text(
                      additionalInfo,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
