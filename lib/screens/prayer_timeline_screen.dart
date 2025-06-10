// lib/screens/prayer_timeline_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:masjid_locator/services/location_service.dart';
import 'package:masjid_locator/services/prayer_service.dart';

// ignore: library_private_types_in_public_api
class PrayerTimelineScreen extends StatefulWidget {
  const PrayerTimelineScreen({super.key});

  @override
  State<PrayerTimelineScreen> createState() => _PrayerTimelineScreenState();
}

class _PrayerTimelineScreenState extends State<PrayerTimelineScreen>
    with SingleTickerProviderStateMixin {
  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();
  PrayerTimes? _prayerTimes;
  String? _currentPrayer;
  String? _nextPrayer;
  DateTime? _nextPrayerTime;
  DateTime _currentTime = DateTime.now();
  int _remainingHours = 0;
  int _remainingMinutes = 0;
  Timer? _countdownTimer;
  Timer? _timeTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _startCurrentTime();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final prayerTimes = _prayerService.getPrayerTimes(position);
        final currentPrayer = _prayerService.getCurrentPrayer(prayerTimes);
        final nextPrayerInfo = _prayerService.getNextPrayer(prayerTimes);

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
        final nextPrayerInfo = _prayerService.getNextPrayer(_prayerTimes!);
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
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timeTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur and dark overlay
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/hi.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  color: Colors.black.withOpacity(0.55),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: _prayerTimes == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4A017)),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildGlassHeaderCard(),
                        const SizedBox(height: 18),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 32),
                            itemCount: 5,
                            itemBuilder: (context, index) =>
                                _buildPrayerCard(index),
                          ),
                        ),
                        _buildQuote(),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A017).withOpacity(0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFD4A017),
          child: const Icon(Icons.refresh, color: Color(0xFF1B5E20)),
          onPressed: _fetchPrayerTimes,
        ),
      ),
    );
  }

  Widget _buildGlassHeaderCard() {
    final urduPrayers = {
      'Fajr': 'فجر',
      'Zuhr': 'ظہر',
      'Asr': 'عصر',
      'Maghrib': 'مغرب',
      'Isha': 'عشاء',
    };
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 370,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time,
                        color: Color(0xFFD4A017), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('h:mm a').format(_currentTime),
                      style: GoogleFonts.almarai(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('EEEE, d MMMM y').format(_currentTime),
                  style: GoogleFonts.almarai(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                _currentPrayer != null
                    ? ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFFD4A017),
                              Color(0xFFFFC107),
                              Color(0xFFD4A017)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Current: $_currentPrayer (${urduPrayers[_currentPrayer] ?? ""})',
                          style: GoogleFonts.almarai(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                if (_nextPrayerTime != null)
                  Text(
                    'Next: $_nextPrayer (${urduPrayers[_nextPrayer]}) at ${DateFormat.jm().format(_nextPrayerTime!)}',
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFD4A017), width: 1.2),
                  ),
                  child: Text(
                    'Time until next prayer: $_remainingHours hrs $_remainingMinutes mins',
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      color: const Color(0xFFD4A017),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(int index) {
    final prayers = [
      {
        'name': 'Fajr',
        'urdu': 'فجر',
        'time': _prayerTimes!.fajr,
        'icon': Icons.nights_stay
      },
      {
        'name': 'Zuhr',
        'urdu': 'ظہر',
        'time': _prayerTimes!.dhuhr,
        'icon': Icons.wb_sunny
      },
      {
        'name': 'Asr',
        'urdu': 'عصر',
        'time': _prayerTimes!.asr,
        'icon': Icons.wb_twilight
      },
      {
        'name': 'Maghrib',
        'urdu': 'مغرب',
        'time': _prayerTimes!.maghrib,
        'icon': Icons.sunny
      },
      {
        'name': 'Isha',
        'urdu': 'عشاء',
        'time': _prayerTimes!.isha,
        'icon': Icons.star
      },
    ];

    final prayer = prayers[index];
    final isCurrentPrayer = _currentPrayer == prayer['name'];

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: isCurrentPrayer
                  ? const Color(0xFFD4A017).withOpacity(0.18)
                  : Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrentPrayer
                    ? const Color(0xFFD4A017)
                    : Colors.white.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrentPrayer
                      ? const Color(0xFFD4A017).withOpacity(0.18)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return isCurrentPrayer
                        ? const LinearGradient(
                            colors: [Color(0xFFD4A017), Color(0xFFFFC107)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds)
                        : const LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                  },
                  child: Icon(
                    prayer['icon'] as IconData,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prayer['name'] as String,
                            style: GoogleFonts.almarai(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isCurrentPrayer
                                  ? const Color(0xFFD4A017)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${prayer['urdu']})',
                            style: GoogleFonts.almarai(
                              fontSize: 18,
                              color: isCurrentPrayer
                                  ? const Color(0xFFD4A017)
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.jm().format(prayer['time'] as DateTime),
                        style: GoogleFonts.almarai(
                          fontSize: 16,
                          color: isCurrentPrayer
                              ? const Color(0xFFD4A017)
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentPrayer)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFD4A017), Color(0xFFFFC107)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            '“The prayer is the key to Paradise.”',
            style: GoogleFonts.almarai(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/masjid.png',
                  width: 28, height: 28, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Masjid Locator',
                style: GoogleFonts.almarai(
                  fontSize: 14,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
