import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_controller.dart';
import 'widgets/bill_form.dart';
import 'widgets/bill_history_dialog.dart';
import '../../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent and Bill Calculator')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                showBillHistoryDialog(context, controller.history);
              },
            ),
            ListTile(
              leading: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) => Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              title: const Text('Dark Mode'),
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) => Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (val) {
                    final newMode = val ? ThemeMode.dark : ThemeMode.light;
                    themeNotifier.value = newMode;
                    ThemePersistence.saveThemeMode(newMode);
                  },
                ),
              ),
              onTap: () {
                final newMode = themeNotifier.value == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                themeNotifier.value = newMode;
                ThemePersistence.saveThemeMode(newMode);
              },
            ),
          ],
        ),
      ),
      body: ChangeNotifierProvider<HomeController>(
        create: (_) => controller,
        child: const BillForm(),
      ),
    );
  }
}
