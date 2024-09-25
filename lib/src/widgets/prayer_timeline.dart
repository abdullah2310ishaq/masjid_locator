import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:masjid_locator/src/services/location_service.dart';
import 'package:masjid_locator/src/services/prayer_services.dart';

class PrayerTimelineWidget extends StatefulWidget {
  @override
  _PrayerTimelineWidgetState createState() => _PrayerTimelineWidgetState();
}

class _PrayerTimelineWidgetState extends State<PrayerTimelineWidget> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final LocationService _locationService = LocationService();

  PrayerTimes? _prayerTimes;
  String? _currentPrayer;

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
        final prayerTimes =
            _prayerTimeService.getPrayerTimes(coordinates, Madhab.hanafi);
        final currentPrayer = _prayerTimeService.getCurrentPrayer(prayerTimes);

        setState(() {
          _prayerTimes = prayerTimes;
          _currentPrayer = currentPrayer;
        });
      }
    } catch (e) {
      print("Error fetching prayer times: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get prayer times
    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr},
      {'name': 'Zuhr', 'time': _prayerTimes!.dhuhr},
      {'name': 'Asr', 'time': _prayerTimes!.asr},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib},
      {'name': 'Isha', 'time': _prayerTimes!.isha},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      height: 70, // Adjusted height for the horizontal row
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: prayers.map((prayer) {
          final isCurrentPrayer = _currentPrayer == prayer['name'];
          return _buildPrayerItem(prayer['name'] as String, isCurrentPrayer);
        }).toList(),
      ),
    );
  }

  // Helper function to build each prayer item in the row
  Widget _buildPrayerItem(String prayerName, bool isCurrentPrayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrentPrayer ? FontWeight.bold : FontWeight.normal,
              color: isCurrentPrayer ? Colors.black : Colors.grey,
            ),
          ),
          if (isCurrentPrayer) ...[
            const SizedBox(height: 5),
            const CircleAvatar(
              radius: 3,
              backgroundColor: Colors.blue, // Dot color for current prayer
            ),
          ],
        ],
      ),
    );
  }
}
