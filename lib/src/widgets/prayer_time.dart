import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  LatLng? _coordinates;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      // Fetching user's current location
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _coordinates = LatLng(position.latitude, position.longitude);
        });

        // Fetching prayer times based on location
        final prayerTimes = _prayerTimeService.getPrayerTimes(
          _coordinates!,
          Madhab.hanafi, // Using Hanafi calculation method
        );

        // Fetching current and next prayer information
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

        // Start countdown for the next prayer
        _startCountdownTimer();
      }
    } catch (e) {
      print("Error fetching prayer times: $e");
    }
  }

  void _startCountdownTimer() {
    const oneMinute = Duration(minutes: 1);
    Timer.periodic(oneMinute, (Timer timer) {
      setState(() {
        if (_nextPrayerTime != null) {
          // Recalculate the remaining time for the next prayer
          final nextPrayerInfo =
              _prayerTimeService.getNextPrayer(_prayerTimes!);
          _remainingHours = nextPrayerInfo['remainingHours'];
          _remainingMinutes = nextPrayerInfo['remainingMinutes'];

          // If time reaches zero, fetch new prayer times
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background
          border: Border.all(color: Colors.black, width: 1), // Black border
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current prayer information
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.black, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current Prayer: $_currentPrayer',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Next prayer information
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orangeAccent, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: _nextPrayerTime != null
                      ? Text(
                          'Next Prayer: $_nextPrayer at ${DateFormat.jm().format(_nextPrayerTime!)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        )
                      : const Text("Calculating next prayer..."),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Countdown to next prayer
            _buildCountdownRow(),
          ],
        ),
      ),
    );
  }

  // Widget to display the countdown timer until the next prayer
  Widget _buildCountdownRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time until next prayer:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '$_remainingHours hrs $_remainingMinutes mins',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.watch_later_outlined, color: Colors.black54),
      ],
    );
  }
}
