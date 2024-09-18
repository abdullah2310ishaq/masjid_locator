import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';

class PrayerProvider with ChangeNotifier {
  Coordinates? _coordinates;
  PrayerTimes? _prayerTimes;
  DateTime? _hijriDate;
  String? _nextPrayer;
  
  PrayerTimes? get prayerTimes => _prayerTimes;
  DateTime? get hijriDate => _hijriDate;
  String? get nextPrayer => _nextPrayer;

  // Method to fetch and update prayer times and Hijri date
  void updatePrayerTimes(Coordinates coordinates, Madhab madhab) {
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = madhab;
    _prayerTimes = PrayerTimes.today(coordinates, params);

    _hijriDate = _calculateHijriDate();

    _nextPrayer = _getNextPrayer();

    notifyListeners();
  }

  // Hijri Date Calculation
  DateTime _calculateHijriDate() {
    // Placeholder calculation logic for Hijri date
    return DateTime.now();  // You can add Hijri date library for accurate calculations
  }

  // Determine next prayer
  String _getNextPrayer() {
    final now = DateTime.now();
    if (now.isBefore(_prayerTimes!.fajr)) {
      return "Fajr";
    } else if (now.isBefore(_prayerTimes!.dhuhr)) {
      return "Dhuhr";
    } else if (now.isBefore(_prayerTimes!.asr)) {
      return "Asr";
    } else if (now.isBefore(_prayerTimes!.maghrib)) {
      return "Maghrib";
    } else if (now.isBefore(_prayerTimes!.isha)) {
      return "Isha";
    } else {
      return "Fajr";
    }
  }
}
