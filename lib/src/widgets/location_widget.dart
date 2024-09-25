import 'package:flutter/material.dart';

class FixedLocationWidget extends StatelessWidget {
  final String? location;
  final VoidCallback onTap;

  const FixedLocationWidget({
    Key? key,
    required this.location,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Subtle white background
        borderRadius: BorderRadius.circular(25), // Rounded corners
        border: Border.all(
            color: Colors.lightBlueAccent,
            width: 1.5), // Border with light blue accent
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Soft shadow
            blurRadius: 12,
            offset: const Offset(0, 5), // Shadow effect
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.lightBlueAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location ?? "Fetching location...",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87, // Dark text for readability
                fontWeight: FontWeight
                    .w500, // Medium font weight for a professional look
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent
                    .withOpacity(0.15), // Light blue background for button
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_location_alt, // A modern location edit icon
                color: Colors.lightBlueAccent,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
