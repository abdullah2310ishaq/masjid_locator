// import 'package:flutter/material.dart';

// class LocationWidget extends StatefulWidget {
//   final String? location;
//   final String defaultMessage;
//   final VoidCallback onTap;
//   final Color color;

//   const LocationWidget({
//     Key? key,
//     required this.location,
//     this.defaultMessage = "Fetching location...",
//     required this.onTap,
//     this.color = const Color(0xFF80DEEA),
//   }) : super(key: key);

//   @override
//   State<LocationWidget> createState() => _LocationWidgetState();
// }

// class _LocationWidgetState extends State<LocationWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: widget.color.withOpacity(0.9),
//           border: Border.all(color: Colors.white, width: 1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.location_on,
//                 size: 40,
//                 color: Colors.black,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.location ?? widget.defaultMessage,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const Icon(
//                 Icons.edit_location,
//                 size: 40,
//                 color: Colors.black,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
