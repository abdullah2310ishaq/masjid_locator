import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:location/location.dart';

class HijriDateProvider with ChangeNotifier {
  HijriCalendar _hijriDate = HijriCalendar.now();
  LocationData? _currentPosition;

  HijriCalendar get hijriDate => _hijriDate;

  // Fetch Hijri Date based on location
  Future<void> updateHijriDateWithLocation() async {
    Location location = Location();
    _currentPosition = await location.getLocation();

    if (_currentPosition != null) {
      // Use current location to fetch date
      // For now, we just fetch the current Hijri date
      _hijriDate = HijriCalendar.now();
      notifyListeners();
    }
  }

  String getFormattedHijriDate() {
    return _hijriDate.toFormat("MMMM dd, yyyy");
  }
}
