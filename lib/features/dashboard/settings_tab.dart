import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../home/home_controller.dart';
import '../coaching/coaching_controller.dart';
import 'main_dashboard.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rentController = Provider.of<HomeController>(context);
    final coachingController = Provider.of<CoachingController>(context);

    final totalRentInvoices = rentController.history.length;
    final totalCoachingInvoices = coachingController.history.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/app_logo.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Configurations'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Section: General Stats
          _buildSectionHeader('Archive Status'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Rent Bills',
                  totalRentInvoices.toString(),
                  Icons.receipt_long_rounded,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Coaching Fees',
                  totalCoachingInvoices.toString(),
                  Icons.school_rounded,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section: Preferences
          _buildSectionHeader('Preferences & Feature Flags'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                // Toggle Dark Mode
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, mode, _) {
                    final darkActive = mode == ThemeMode.dark;
                    return ListTile(
                      leading: Icon(
                        darkActive ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: darkActive ? theme.colorScheme.primary : Colors.amber,
                      ),
                      title: const Text('Dark Mode Preference', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        darkActive ? 'Slate dark theme enabled' : 'Cool light theme enabled',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: Switch(
                        value: darkActive,
                        onChanged: (val) {
                          final newMode = val ? ThemeMode.dark : ThemeMode.light;
                          themeNotifier.value = newMode;
                          ThemePersistence.saveThemeMode(newMode);
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Toggle Rent Calculator
                ValueListenableBuilder<bool>(
                  valueListenable: rentEnabledNotifier,
                  builder: (context, rentEnabled, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: coachingEnabledNotifier,
                      builder: (context, coachingEnabled, _) {
                        return ListTile(
                          leading: Icon(
                            Icons.home_rounded,
                            color: rentEnabled ? theme.colorScheme.primary : Colors.grey,
                          ),
                          title: const Text('Enable Rent Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Show/hide the Rent Calculator on the dashboard.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Switch(
                            value: rentEnabled,
                            onChanged: (val) {
                              if (!val && !coachingEnabled) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('At least one calculator must remain active!'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              rentEnabledNotifier.value = val;
                              SettingsPersistence.saveRentEnabled(val);
                              if (val) {
                                // Redirect to Rent tab (index 0)
                                dashboardTabNotifier.value = 0;
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Toggle Coaching Calculator
                ValueListenableBuilder<bool>(
                  valueListenable: coachingEnabledNotifier,
                  builder: (context, coachingEnabled, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: rentEnabledNotifier,
                      builder: (context, rentEnabled, _) {
                        return ListTile(
                          leading: Icon(
                            Icons.school_rounded,
                            color: coachingEnabled ? theme.colorScheme.secondary : Colors.grey,
                          ),
                          title: const Text('Enable Coaching Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Show/hide the Coaching Fee Calculator on the dashboard.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Switch(
                            value: coachingEnabled,
                            onChanged: (val) {
                              if (!val && !rentEnabled) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('At least one calculator must remain active!'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              coachingEnabledNotifier.value = val;
                              SettingsPersistence.saveCoachingEnabled(val);
                              if (val) {
                                // Redirect to Coaching tab
                                final isRentEnabled = rentEnabledNotifier.value;
                                dashboardTabNotifier.value = isRentEnabled ? 1 : 0;
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section: Danger Zone
          _buildSectionHeader('System Actions'),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3), width: 1.2),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                  title: const Text(
                    'Clear Saved History',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  subtitle: const Text(
                    'Permanently delete all saved invoices & reset counters.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear All Archives?'),
                        content: const Text(
                          'This will wipe all historical rent and coaching records permanently. This action cannot be reversed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await rentController.clearSavedHistory();
                      await coachingController.clearSavedHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All historical databases cleared successfully.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Footer info
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/app_logo.png',
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rent & Bill Calculator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 3.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Build by Shikder Shondhi',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String count, IconData icon, Color accentColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
