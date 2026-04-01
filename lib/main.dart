import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/utils/pp_bluetooth_kit_logger.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'profile_manager.dart';
import 'app_state.dart';

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

  // Загружаем профили
  await ProfileManager.instance.load();

  // Загружаем историю измерений
  await AppState.instance.load();

  final hasProfiles = ProfileManager.instance.hasProfiles;

  runApp(MyApp(onboardingDone: hasProfiles));
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scale App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: onboardingDone ? const MainScreen() : const OnboardingScreen(),
    );
  }
}
