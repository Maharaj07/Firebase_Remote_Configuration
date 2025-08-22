import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final String appIcon; // "default" | "diwali" | "pongal" | "christmas"
  const AppLogo({super.key, required this.appIcon});

  @override
  Widget build(BuildContext context) {
    String iconPath;
    switch (appIcon) {
      case "diwali":
        iconPath = "assets/images/diwali.jpg";
        break;
      case "pongal":
        iconPath = "assets/images/pongal.jpg";
        break;
      case "christmas":
        iconPath = "assets/images/christmas.jpg";
        break;
      default:
        iconPath = "assets/images/pongal.jpg";
    }

    return Image.asset(iconPath, height: 40, width: 40);
  }
}
