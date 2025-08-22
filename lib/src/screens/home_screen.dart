import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config_poc/src/config/remote_config_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/special_alert_banner.dart';

class HomeScreen extends StatefulWidget {
  final RemoteConfigService remoteConfigService;

  const HomeScreen({super.key, required this.remoteConfigService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadConfig();

    // ✅ auto refresh every 30s
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadConfig();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    await widget.remoteConfigService.refresh();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final message = widget.remoteConfigService.welcomeMessage;
    final appIcon = widget.remoteConfigService.appIcon;
    final specialAlert = widget.remoteConfigService.specialAlert;
    final festivalAlert = widget.remoteConfigService.festivalAlert;
    final homeLayout = widget.remoteConfigService.homeLayout;
    final features = widget.remoteConfigService.getFeatures();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Remote Config POC"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(

            child: AppLogo(appIcon: appIcon),
            radius: 12.0,
          ),
        ), // Dynamic App Icon
      ),
      body: ListView(
        children: [
          // 🔔 Special Alert (general banner)
          if (specialAlert.isNotEmpty)
            SpecialAlertBanner(alertType: specialAlert),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // 🎉 Festival banner
          if (festivalAlert.toLowerCase() == "diwali")
            _buildFestivalBanner("🎆 Happy Diwali! 🎆", Colors.orange),
          if (festivalAlert.toLowerCase() == "pongal")
            _buildFestivalBanner("🌾 Happy Pongal! 🌾", Colors.green),
          if (festivalAlert.toLowerCase() == "christmas")
            _buildFestivalBanner("🎄 Merry Christmas! 🎄", Colors.red),

          // 🔹 Dynamic layout: Grid or List
          if (homeLayout == "grid")
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: features.isNotEmpty
                  ? features
                        .map(
                          (f) => _buildFeatureTile(
                            _mapIcon(f["icon"]),
                            f["title"],
                          ),
                        )
                        .toList()
                  : _defaultFeatures(),
            )
          else
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: features.isNotEmpty
                  ? features
                        .map(
                          (f) => ListTile(
                            leading: Icon(_mapIcon(f["icon"])),
                            title: Text(f["title"]),
                          ),
                        )
                        .toList()
                  : _defaultFeatures()
                        .map(
                          (w) => ListTile(
                            leading: const Icon(Icons.apps),
                            title: const Text("Default"),
                          ),
                        )
                        .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalBanner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _mapIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case "shop":
        return Icons.shopping_cart;
      case "event":
        return Icons.event;
      case "profile":
        return Icons.account_circle;
      case "settings":
        return Icons.settings;
      default:
        return Icons.help_outline;
    }
  }

  /// Default features fallback
  List<Widget> _defaultFeatures() {
    return [
      _buildFeatureTile(Icons.shopping_cart, "Shop"),
      _buildFeatureTile(Icons.event, "Events"),
      _buildFeatureTile(Icons.account_circle, "Profile"),
      _buildFeatureTile(Icons.settings, "Settings"),
    ];
  }
}
