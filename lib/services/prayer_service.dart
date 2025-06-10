// lib/src/services/prayer_service.dart
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerService {
  PrayerTimes getPrayerTimes(Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi; // For Islamabad users
    return PrayerTimes.today(coordinates, params);
  }

  String getCurrentPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (now.isAfter(prayerTimes.fajr) && now.isBefore(prayerTimes.dhuhr)) {
      return 'Fajr';
    } else if (now.isAfter(prayerTimes.dhuhr) && now.isBefore(prayerTimes.asr)) {
      return 'Zuhr';
    } else if (now.isAfter(prayerTimes.asr) && now.isBefore(prayerTimes.maghrib)) {
      return 'Asr';
    } else if (now.isAfter(prayerTimes.maghrib) && now.isBefore(prayerTimes.isha)) {
      return 'Maghrib';
    } else {
      return 'Isha';
    }
  }

  Map<String, dynamic> getNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    DateTime nextPrayerTime;
    String nextPrayer;

    if (now.isBefore(prayerTimes.fajr)) {
      nextPrayer = 'Fajr';
      nextPrayerTime = prayerTimes.fajr;
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      nextPrayer = 'Zuhr';
      nextPrayerTime = prayerTimes.dhuhr;
    } else if (now.isBefore(prayerTimes.asr)) {
      nextPrayer = 'Asr';
      nextPrayerTime = prayerTimes.asr;
    } else if (now.isBefore(prayerTimes.maghrib)) {
      nextPrayer = 'Maghrib';
      nextPrayerTime = prayerTimes.maghrib;
    } else if (now.isBefore(prayerTimes.isha)) {
      nextPrayer = 'Isha';
      nextPrayerTime = prayerTimes.isha;
    } else {
      nextPrayer = 'Fajr';
      nextPrayerTime = prayerTimes.fajr.add(const Duration(days: 1));
    }

    final remainingTime = nextPrayerTime.difference(now);
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    return {
      'nextPrayer': nextPrayer,
      'time': nextPrayerTime,
      'remainingHours': hours,
      'remainingMinutes': minutes,
    };
  }
}