import 'package:flutter/material.dart';

class MosqueDetailPage extends StatelessWidget {
  const MosqueDetailPage({super.key, required String mosqueName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Madni Majis', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image of the mosque
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/mosque.jpg', // Make sure the image is placed here
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mosque Address and Details
              _buildMosqueDetails(),

              const SizedBox(height: 20),

              // Prayer Times Table
              _buildPrayerTimesTable(),

              const SizedBox(height: 20),

              // Donation Button
            ],
          ),
        ),
      ),
    );
  }

  // Mosque Details Widget
  Widget _buildMosqueDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1.0 kms Away',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Madina Market, F-8/4',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            '+923462207429',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.phone, color: Colors.black54),
              Icon(Icons.map, color: Colors.black54),
              Icon(Icons.favorite_border, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }

  // Prayer Times Table Widget
  Widget _buildPrayerTimesTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildPrayerTimeRow('Fajr', '6:14 AM', '6:35 AM'),
          _buildPrayerTimeRow('Zuhr', '12:40 PM', '1:00 PM'),
          _buildPrayerTimeRow('Asr', '3:56 PM', '4:00 PM'),
          _buildPrayerTimeRow('Maghrib', '5:34 PM', '5:39 PM'),
          _buildPrayerTimeRow('Isha', '7:00 PM', '7:15 PM'),
        ],
      ),
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
}
