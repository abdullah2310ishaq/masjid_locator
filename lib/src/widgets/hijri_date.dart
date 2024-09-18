import 'package:flutter/material.dart';
import 'package:masjid_locator/src/providers/hijri_provider.dart';
import 'package:provider/provider.dart';

class HijriDateWidget extends StatefulWidget {
  @override
  State<HijriDateWidget> createState() => _HijriDateWidgetState();
}

class _HijriDateWidgetState extends State<HijriDateWidget> {
  @override
  Widget build(BuildContext context) {
    final hijriDateProvider = Provider.of<HijriDateProvider>(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.green),
            const SizedBox(width: 10),
            Text(
              hijriDateProvider.getFormattedHijriDate(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
