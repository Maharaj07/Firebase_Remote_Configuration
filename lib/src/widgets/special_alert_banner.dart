import 'package:flutter/material.dart';

class SpecialAlertBanner extends StatelessWidget {
  final String alertType; // "none" | "diwali" | "pongal" | "christmas"
  const SpecialAlertBanner({super.key, required this.alertType});

  @override
  Widget build(BuildContext context) {
    if (alertType == "none") return const SizedBox.shrink();

    String message;
    switch (alertType) {
      case "diwali":
        message = "✨ Happy Diwali! Enjoy the festival of lights!";
        break;
      case "pongal":
        message = "🌾 Happy Pongal! Celebrate the harvest season!";
        break;
      case "christmas":
        message = "🎄 Merry Christmas! Spread joy and cheer!";
        break;
      default:
        message = "";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
