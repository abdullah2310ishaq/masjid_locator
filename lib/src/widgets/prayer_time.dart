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
  DateTime _currentTime = DateTime.now();
  int _remainingHours = 0;
  int _remainingMinutes = 0;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _startCurrentTime();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        final coordinates = LatLng(position.latitude, position.longitude);
        final prayerTimes =
            _prayerTimeService.getPrayerTimes(coordinates, Madhab.hanafi);
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

  void _startCurrentTime() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 220, // Increased height for horizontal design
        width: double.infinity, // Full width of the screen
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/abc.png'), // Background illustration
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.center,
              colors: [
                Colors.black.withOpacity(0.2), // Darker at the bottom
                Colors.white30, // Transparent at the top
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Time
              Text(
                'Current Time: ${DateFormat.jm().format(_currentTime)}',
                style: const TextStyle(
                  fontSize: 20, // Time display font
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12), // Adjusted space

              // Current prayer
              Text(
                '$_currentPrayer',
                style: const TextStyle(
                  fontSize: 24, // Bigger font for current prayer
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // White color for contrast
                ),
              ),
              const SizedBox(height: 12),

              // Next prayer with time
              if (_nextPrayerTime != null)
                Text(
                  'Next: $_nextPrayer at ${DateFormat.jm().format(_nextPrayerTime!)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 12),

              // Time until next prayer
              Text(
                'Time until next prayer: $_remainingHours hrs $_remainingMinutes mins',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
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
