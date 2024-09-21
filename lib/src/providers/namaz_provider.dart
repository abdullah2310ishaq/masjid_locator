import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

class PrayerProvider with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  String? _nextPrayer;
  DateTime? _nextPrayerTime;
  
  PrayerTimes? get prayerTimes => _prayerTimes;
  String? get nextPrayer => _nextPrayer;
  DateTime? get nextPrayerTime => _nextPrayerTime;

  void updatePrayerTimes(Coordinates coordinates, Madhab madhab) {
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = madhab;

    _prayerTimes = PrayerTimes.today(coordinates, params);
    _nextPrayer = _calculateNextPrayer();
    _nextPrayerTime = _getNextPrayerTime();
    notifyListeners();
  }

  String _calculateNextPrayer() {
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

  DateTime _getNextPrayerTime() {
    final now = DateTime.now();
    if (now.isBefore(_prayerTimes!.fajr)) {
      return _prayerTimes!.fajr;
    } else if (now.isBefore(_prayerTimes!.dhuhr)) {
      return _prayerTimes!.dhuhr;
    } else if (now.isBefore(_prayerTimes!.asr)) {
      return _prayerTimes!.asr;
    } else if (now.isBefore(_prayerTimes!.maghrib)) {
      return _prayerTimes!.maghrib;
    } else if (now.isBefore(_prayerTimes!.isha)) {
      return _prayerTimes!.isha;
    } else {
      return _prayerTimes!.fajr;
    }
  }
}
