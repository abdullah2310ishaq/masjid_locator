import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masjid_locator/src/providers/prayer_provider.dart';
import 'package:provider/provider.dart';

class PrayerTimesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final prayerTimes = prayerProvider.prayerTimes;
    final nextPrayer = prayerProvider.nextPrayer;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Prayer Times',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPrayerTimeRow('Fajr', prayerTimes?.fajr, nextPrayer == 'Fajr'),
            _buildPrayerTimeRow('Dhuhr', prayerTimes?.dhuhr, nextPrayer == 'Dhuhr'),
            _buildPrayerTimeRow('Asr', prayerTimes?.asr, nextPrayer == 'Asr'),
            _buildPrayerTimeRow('Maghrib', prayerTimes?.maghrib, nextPrayer == 'Maghrib'),
            _buildPrayerTimeRow('Isha', prayerTimes?.isha, nextPrayer == 'Isha'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayerName, DateTime? prayerTime, bool isNext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            prayerTime != null ? DateFormat.jm().format(prayerTime) : 'Loading...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? Colors.green : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
