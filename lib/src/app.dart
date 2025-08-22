import 'package:flutter/material.dart';
import 'config/remote_config_service.dart';
import 'screens/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RemoteConfigService? _remoteConfigService;
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _initRemoteConfig();
  }

  Future<void> _initRemoteConfig() async {
    final service = await RemoteConfigService.init();
    _applyTheme(service.theme);

    setState(() => _remoteConfigService = service);

    // 👀 Listen for live updates from Firebase Remote Config
    service.instance.onConfigUpdated.listen((event) async {
      debugPrint("🔥 Remote Config updated from Firebase!");
      await service.instance.activate(); // Apply new config immediately
      final newTheme = service.theme;
      _applyTheme(newTheme); // Update ValueNotifier (UI rebuilds instantly)
    });
  }

  void _applyTheme(String theme) {
    final mode = theme.trim().toLowerCase() == "dark"
        ? ThemeMode.dark
        : ThemeMode.light;

    if (_themeMode.value != mode) {
      debugPrint("🎨 Switching Theme -> $mode");
      _themeMode.value = mode; // 🔔 triggers rebuild instantly
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_remoteConfigService == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode, // Auto switches instantly
          home: HomeScreen(remoteConfigService: _remoteConfigService!),
        );
      },
    );
  }
}
