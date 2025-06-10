import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';

class PrayerTimelineScreen extends StatefulWidget {
  const PrayerTimelineScreen({super.key});

  @override
  _PrayerTimelineScreenState createState() => _PrayerTimelineScreenState();
}

class _PrayerTimelineScreenState extends State<PrayerTimelineScreen> {
  final PrayerService _prayerTimeService = PrayerService();
  final LocationService _locationService = LocationService();
  PrayerTimes? _prayerTimes;
  String? _currentPrayer;
  String? _nextPrayer;
  DateTime? _nextPrayerTime;
  DateTime _currentTime = DateTime.now();
  int _remainingHours = 0;
  int _remainingMinutes = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _startCurrentTime();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final coordinates = Coordinates(position.latitude, position.longitude);
        final prayerTimes =
            _prayerTimeService.getPrayerTimes(coordinates as Position);
        final currentPrayer = _prayerTimeService.getCurrentPrayer(prayerTimes);
        final nextPrayerInfo = _prayerTimeService.getNextPrayer(prayerTimes);

        setState(() {
          _prayerTimes = prayerTimes;
          _currentPrayer = currentPrayer;
          _nextPrayer = nextPrayerInfo['nextPrayer'] as String?;
          _nextPrayerTime = nextPrayerInfo['time'] as DateTime?;
          _remainingHours = nextPrayerInfo['remainingHours'] as int;
          _remainingMinutes = nextPrayerInfo['remainingMinutes'] as int;
        });

        _startCountdownTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching prayer times: $e')),
        );
      }
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_prayerTimes != null && _nextPrayerTime != null) {
        final nextPrayerInfo = _prayerTimeService.getNextPrayer(_prayerTimes!);
        setState(() {
          _remainingHours = nextPrayerInfo['remainingHours'] as int;
          _remainingMinutes = nextPrayerInfo['remainingMinutes'] as int;
          if (_remainingHours == 0 && _remainingMinutes == 0) {
            _fetchPrayerTimes();
          }
        });
      }
    });
  }

  void _startCurrentTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prayer Times - Islamabad',
          style: GoogleFonts.almarai(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: _prayerTimes == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrayerTimeCard(),
                  const SizedBox(height: 16),
                  _buildPrayerTimeline(),
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerTimeCard() {
    return GestureDetector(
      onTap: _fetchPrayerTimes,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Current Time: ${DateFormat.jm().format(_currentTime)}',
                  style: GoogleFonts.almarai(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Current Prayer: $_currentPrayer',
              style: GoogleFonts.almarai(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_nextPrayerTime != null)
              Text(
                'Next: $_nextPrayer at ${DateFormat.jm().format(_nextPrayerTime!)}',
                style: GoogleFonts.almarai(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Time until next prayer: $_remainingHours hrs $_remainingMinutes mins',
              style: GoogleFonts.almarai(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeline() {
    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr, 'icon': Icons.nights_stay},
      {'name': 'Zuhr', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': _prayerTimes!.asr, 'icon': Icons.wb_twilight},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.sunny},
      {'name': 'Isha', 'time': _prayerTimes!.isha, 'icon': Icons.star},
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: prayers.length,
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          final isCurrentPrayer = _currentPrayer == prayer['name'];
          return _buildPrayerItem(
            prayer['name'] as String,
            prayer['time'] as DateTime,
            prayer['icon'] as IconData,
            isCurrentPrayer,
          );
        },
      ),
    );
  }

  Widget _buildPrayerItem(
      String prayerName, DateTime prayerTime, IconData icon, bool isCurrentPrayer) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$prayerName tapped')),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentPrayer ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPrayer ? Colors.white : const Color(0xFF4CAF50),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isCurrentPrayer ? Colors.white : const Color(0xFF1B5E20),
            ),
            const SizedBox(height: 4),
            Text(
              prayerName,
              style: GoogleFonts.almarai(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCurrentPrayer ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.jm().format(prayerTime),
              style: GoogleFonts.almarai(
                fontSize: 12,
                color: isCurrentPrayer ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}