import 'package:flutter/material.dart';

class MosqueDetailPage extends StatelessWidget {
  final String mosqueName;

  const MosqueDetailPage({super.key, required this.mosqueName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Light blue background
      body: Column(
        children: [
          // Mosque Image Section (placed above the card)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/hello.jpg'), // Mosque image asset
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Mosque Details and Prayer Times Section in a card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosqueName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMosqueDetails(),
                      const SizedBox(height: 20),
                      _buildPrayerTimesTable(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDirectionButton(),
    );
  }

  // Mosque Details Widget
  Widget _buildMosqueDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '1.0 Kms Away',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 8),
        Text(
          'Madine Market, F-8/4 - Islamabad',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          '+92-3462207429',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  // Prayer Times Table Widget
  Widget _buildPrayerTimesTable() {
    return Column(
      children: [
        _buildPrayerTimeRow('Fajr', '6:14 AM', '6:35 AM'),
        _buildPrayerTimeRow('Dhuhr', '12:40 PM', '1:00 PM'),
        _buildPrayerTimeRow('Asr', '3:56 PM', '4:00 PM'),
        _buildPrayerTimeRow('Maghrib', '5:34 PM', '5:39 PM'),
        _buildPrayerTimeRow('Isha', '7:00 PM', '7:15 PM'),
      ],
    );
  }

  // Helper function to build each row in the prayer time table
  Widget _buildPrayerTimeRow(String prayer, String adhan, String iqama) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prayer,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(adhan,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(iqama,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  // Donation Button Widget
  Widget _buildDirectionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          backgroundColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Get Directions',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
