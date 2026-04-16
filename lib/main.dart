import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/utils/pp_bluetooth_kit_logger.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'profile_manager.dart';
import 'app_state.dart';

// Глобальный notifier для темы
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PPBluetoothKitLogger.addListener(callBack: (log) {
    print('SDK-Log:$log');
  });

  final configPath = 'config/lefu.config';
  String content = await rootBundle.loadString(configPath);
  PPBluetoothKitManager.initSDK(
    'lefu0eb0a285268f22c7',
    'oA0pdd57IJxmFqgvh1iQt4XyDxyQy8XDkTRTbsYFo0I=',
    content,
  );

  final deviceSettingPath = 'config/Device.json';
  try {
    String jsonStr = await rootBundle.loadString(deviceSettingPath);
    PPBluetoothKitManager.setDeviceSetting(jsonStr);
    print("Device settings loaded successfully");
  } catch (e) {
    print("Error loading device settings: $e");
  }

  await ProfileManager.instance.load();
  await AppState.instance.load();

  final hasProfiles = ProfileManager.instance.hasProfiles;

  runApp(MyApp(onboardingDone: hasProfiles));
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'BLE Scale App',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C6EF5),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0D1B3E),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C6EF5),
              brightness: Brightness.dark,
            ),
          ),
          home: onboardingDone ? const MainScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}