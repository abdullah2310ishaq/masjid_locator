import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  final String? location;
  final String defaultMessage;
  final VoidCallback onTap;
  final Color color; // Customizable color for the widget

  const LocationWidget({
    Key? key,
    required this.location,
    this.defaultMessage = "Fetching location...",
    required this.onTap,
    this.color = const Color(0xFF80DEEA), // Default teal color if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9), // White or custom background
          border: Border.all(color: Colors.black, width: 1), // Black border
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 32,
                color: Colors.lightBlueAccent, // Light blue icon
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location ?? defaultMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // Black text
                  ),
                ),
              ),
              const Icon(
                Icons.edit_location,
                size: 26,
                color: Colors.black45, // Softer black for the edit icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
