import 'package:flutter/material.dart';
import 'package:masjid_locator/src/providers/hijri_provider.dart';
import 'package:masjid_locator/src/services/auth_service.dart';
import 'package:masjid_locator/src/widgets/hijri_date.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final AuthService _authService = AuthService(); // Auth service for logout

  @override
  void initState() {
    super.initState();
    // Fetch location and update Hijri date on load
    Provider.of<HijriDateProvider>(context, listen: false)
        .updateHijriDateWithLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C), // Dark background color
      appBar: AppBar(
        title: const Text(
          'Masjid Locator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E2E2E), // Soft dark AppBar
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            const Text(
              'Welcome to Masjid Locator!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Light text on dark background
              ),
            ),
            const SizedBox(height: 20),

            // Hijri Date Widget
            // HijriDateWidget(),

            const SizedBox(height: 30), // Add more space before cards

            // Center the cards
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card 1: Prayer Times
                _buildFeatureCard(
                  icon: Icons.access_time,
                  title: 'Prayer Times',
                  description: 'Check the current prayer times',
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/prayer'); // Navigate to prayer times
                  },
                ),
                const SizedBox(height: 20),

                // Card 2: Find Nearby Mosques
                _buildFeatureCard(
                  icon: Icons.location_on,
                  title: 'Nearby Mosques',
                  description: 'Locate mosques around your area',
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/map'); // Navigate to nearby mosques
                  },
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Custom feature card widget with a modern, dark design
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E2E2E),
              Color(0xFF383838)
            ], // Soft gradient for cards
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.5), // Deeper shadow for modern effect
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(25), // Increased padding for better spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at the top center with a glowing effect
              Icon(icon, size: 50, color: const Color(0xFF4CAF50)),
              const SizedBox(height: 15),

              // Title text
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Description text
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE0E0E0), // Lighter grey for description
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logout method
  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
  }
}
