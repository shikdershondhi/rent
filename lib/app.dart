import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/home/home_controller.dart';
import 'features/coaching/coaching_controller.dart';
import 'features/dashboard/main_dashboard.dart';

class RentApp extends StatefulWidget {
  const RentApp({super.key});

  @override
  State<RentApp> createState() => _RentAppState();
}

class _RentAppState extends State<RentApp> {
  @override
  void initState() {
    super.initState();
    ThemePersistence.loadThemeMode();
    SettingsPersistence.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeController>(
          create: (_) => HomeController()..loadHistory(),
        ),
        ChangeNotifierProvider<CoachingController>(
          create: (_) => CoachingController()..loadHistory(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Rent and Bill Calculator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const MainDashboard(),
          );
        },
      ),
    );
  }
}
