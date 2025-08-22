import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._internal(this._remoteConfig);

  // Expose instance
  FirebaseRemoteConfig get instance => _remoteConfig;

  /// Initialize Remote Config
  static Future<RemoteConfigService> init() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // ✅ Default values (must cover all keys you use)
    await remoteConfig.setDefaults({
      "app_theme": "light",
      "welcome_message": "Hello 👋",
      "home_layout": "list",
      "features": '[{"title":"Default","icon":"home"}]',
      "show_promo": false,
      "promo_text": "No offers right now.",
      "app_icon": "default", // values: "default", "diwali", "pongal", "christmas"
      "special_alert": "",
      "festival_alert": "", // <-- added missing default
    });

    // ✅ Config settings
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 5), // keep small for dev
      minimumFetchInterval: const Duration(seconds: 5),
    ));

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print("⚠️ Remote Config fetch failed: $e");
    }

    return RemoteConfigService._internal(remoteConfig);
  }

  /// Refresh manually
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print("⚠️ Refresh failed: $e");
    }
  }

  // Getters
  String get theme => _remoteConfig.getString('app_theme').trim().toLowerCase();
  String get welcomeMessage => _remoteConfig.getString('welcome_message');
  String get homeLayout => _remoteConfig.getString('home_layout');
  bool get showPromo => _remoteConfig.getBool('show_promo');
  String get promoText => _remoteConfig.getString('promo_text');

  String get appIcon =>
      _remoteConfig.getString("app_icon").trim().toLowerCase();

  String get specialAlert => _remoteConfig.getString("special_alert").trim();
  String get festivalAlert => _remoteConfig.getString("festival_alert").trim();

  List<Map<String, dynamic>> getFeatures() {
    final jsonString = _remoteConfig.getString('features');
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print("⚠️ Failed to decode features: $e");
      return [];
    }
  }
}
