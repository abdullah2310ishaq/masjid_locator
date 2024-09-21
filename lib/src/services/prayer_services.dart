import 'package:adhan/adhan.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PrayerTimeService {
  // Method to get prayer times for the current day based on coordinates and madhab
  PrayerTimes getPrayerTimes(LatLng coordinates, Madhab madhab) {
    final params = CalculationMethod.karachi.getParameters(); // You can adjust this
    params.madhab = madhab;

    // Calculate prayer times for today based on the coordinates
    final prayerTimes = PrayerTimes.today(
      Coordinates(coordinates.latitude, coordinates.longitude),
      params,
    );

    return prayerTimes;
  }

  // Method to get the current prayer
  String getCurrentPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (now.isBefore(prayerTimes.fajr)) {
      return "Fajr";
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      return "Dhuhr";
    } else if (now.isBefore(prayerTimes.asr)) {
      return "Asr";
    } else if (now.isBefore(prayerTimes.maghrib)) {
      return "Maghrib";
    } else if (now.isBefore(prayerTimes.isha)) {
      return "Isha";
    } else {
      return "Fajr"; // If it's after Isha, Fajr is next
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
      nextPrayer = "Fajr";
      nextPrayerTime = prayerTimes.fajr;
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
