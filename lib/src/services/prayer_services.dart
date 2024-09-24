import 'package:adhan/adhan.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PrayerTimeService {
  // Method to get prayer times for the current day based on coordinates and madhab
  PrayerTimes getPrayerTimes(LatLng coordinates, Madhab madhab) {
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = madhab;

    // Calculate prayer times for today based on the coordinates
    return PrayerTimes.today(
      Coordinates(coordinates.latitude, coordinates.longitude),
      params,
    );
  }

  // Method to get the current prayer
  String getCurrentPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    if (now.isAfter(prayerTimes.fajr) && now.isBefore(prayerTimes.dhuhr)) {
      return "Fajr";
    } else if (now.isAfter(prayerTimes.dhuhr) && now.isBefore(prayerTimes.asr)) {
      return "Dhuhr";
    } else if (now.isAfter(prayerTimes.asr) && now.isBefore(prayerTimes.maghrib)) {
      return "Asr";
    } else if (now.isAfter(prayerTimes.maghrib) && now.isBefore(prayerTimes.isha)) {
      return "Maghrib";
    } else if (now.isAfter(prayerTimes.isha) || now.isBefore(prayerTimes.fajr)) {
      return "Isha";
    } else {
      return "Fajr"; // If it's after Isha, Fajr is next (for next day)
    }
  }

  // Method to get the next prayer and the remaining time
  Map<String, dynamic> getNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    DateTime nextPrayerTime;
    String nextPrayer;

    if (now.isBefore(prayerTimes.fajr)) {
      nextPrayer = "Fajr";
      nextPrayerTime = prayerTimes.fajr;
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      nextPrayer = "Dhuhr";
      nextPrayerTime = prayerTimes.dhuhr;
    } else if (now.isBefore(prayerTimes.asr)) {
      nextPrayer = "Asr";
      nextPrayerTime = prayerTimes.asr;
    } else if (now.isBefore(prayerTimes.maghrib)) {
      nextPrayer = "Maghrib";
      nextPrayerTime = prayerTimes.maghrib;
    } else if (now.isBefore(prayerTimes.isha)) {
      nextPrayer = "Isha";
      nextPrayerTime = prayerTimes.isha;
    } else {
      // Handle next day's Fajr
      nextPrayer = "Fajr";
      nextPrayerTime = prayerTimes.fajr.add(const Duration(days: 1));
    }

    // Calculate the remaining time in hours and minutes
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
