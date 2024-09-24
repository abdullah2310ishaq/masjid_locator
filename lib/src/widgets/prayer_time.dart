import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/services/prayer_services.dart';

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({Key? key, required Null Function() onTap}) : super(key: key);

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
        final prayerTimes = _prayerTimeService.getPrayerTimes(coordinates, Madhab.hanafi);

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
          final nextPrayerInfo = _prayerTimeService.getNextPrayer(_prayerTimes!);
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current prayer
            Text(
              'Current Prayer: $_currentPrayer',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Next prayer with countdown
            if (_nextPrayerTime != null)
              Text(
                'Next: $_nextPrayer at ${DateFormat.jm().format(_nextPrayerTime!)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 10),

            // Time until next prayer
            Text(
              'Time until next prayer: $_remainingHours hrs $_remainingMinutes mins',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
