import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_controller.dart';
import 'widgets/bill_form.dart';
import 'widgets/bill_history_dialog.dart';
import '../coaching/coaching_screen.dart';
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
    controller.loadHistory();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent and Bill Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear saved history',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear saved history?'),
                  content:
                      const Text('This will delete all saved bill history.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear')),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.clearSavedHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved history cleared')));
              }
            },
          ),
        ],
      ),
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
              leading: const Icon(Icons.school),
              title: const Text('Coaching Fee'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachingScreen()),
                );
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              children: [
                ListTile(
                  leading: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, _) => Icon(
                      mode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
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
          ],
        ),
      ),
      body: ChangeNotifierProvider<HomeController>(
        create: (_) => controller,
        child: const BillForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBillHistoryDialog(context, controller),
        child: const Icon(Icons.history),
        tooltip: 'History',
      ),
    );
  }
}
