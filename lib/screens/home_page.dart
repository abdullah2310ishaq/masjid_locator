// lib/screens/home_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masjid_locator/screens/mosques_near_me.dart';
import 'package:masjid_locator/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'prayer_timeline_screen.dart';

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
      final locationService = LocationService();
      _currentPosition = await locationService.getCurrentPosition();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timeTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimeUpdate();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startTimeUpdate() {
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            // Background image with blur and dark overlay
            Positioned.fill(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/masjid.png',
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
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // Greeting and shimmer
                        _buildShimmerGreeting(),
                        const SizedBox(height: 12),
                        // Center glassmorphic card
                        Expanded(
                          child: Center(
                            child: _buildGlassCard(context, locationProvider),
                          ),
                        ),
                        // Motivational quote
                        _buildQuote(),
                        const SizedBox(height: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGreeting() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFD4A017), Color(0xFFFFC107), Color(0xFFD4A017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        'Masjid Locator',
        style: GoogleFonts.almarai(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGlassCard(
      BuildContext context, LocationProvider locationProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 370,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time and date
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time,
                      color: Color(0xFFD4A017), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('h:mm a').format(_currentTime),
                    style: GoogleFonts.almarai(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM y').format(_currentTime),
                style: GoogleFonts.almarai(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 18),
              // Location or button
              if (locationProvider.isLoading)
                const CircularProgressIndicator(color: Color(0xFFD4A017))
              else if (locationProvider.errorMessage != null)
                _buildErrorWidget(context, locationProvider.errorMessage!)
              else if (locationProvider.currentPosition != null)
                _buildLocationSuccess(context)
              else
                _buildLocationButton(context),
              const SizedBox(height: 24),
              // Action buttons
              _buildActionButtons(context, locationProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<LocationProvider>(context, listen: false).getUserLocation();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A017), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, color: Color(0xFF1B5E20)),
            const SizedBox(width: 8),
            Text(
              'Grant Location Access',
              style: GoogleFonts.almarai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSuccess(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFFD4A017), size: 22),
        const SizedBox(width: 8),
        Text(
          'Location accessed!',
          style: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Column(
      children: [
        Text(
          errorMessage,
          style: GoogleFonts.almarai(
            fontSize: 14,
            color: Colors.red[200],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Geolocator.openAppSettings(),
          child: Text(
            'Open Settings',
            style: GoogleFonts.almarai(
              fontSize: 14,
              color: const Color(0xFFD4A017),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, LocationProvider locationProvider) {
    final bool enabled = locationProvider.currentPosition != null;
    return Column(
      children: [
        GestureDetector(
          onTap: enabled
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MosquesNearMePage()),
                  );
                }
              : null,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFFD4A017)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Find Mosques Near Me',
                    style: GoogleFonts.almarai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: enabled
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrayerTimelineScreen()),
                  );
                }
              : null,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_alarm, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'View Prayer Times',
                    style: GoogleFonts.almarai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            '“The best among you are those who have the best manners and character.”',
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
