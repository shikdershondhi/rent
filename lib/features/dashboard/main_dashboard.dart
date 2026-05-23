import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';
import '../coaching/coaching_screen.dart';
import 'history_tab.dart';
import 'settings_tab.dart';

final ValueNotifier<int> dashboardTabNotifier = ValueNotifier<int>(0);

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<int>(
      valueListenable: dashboardTabNotifier,
      builder: (context, currentIndex, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: rentEnabledNotifier,
          builder: (context, rentEnabled, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: coachingEnabledNotifier,
              builder: (context, coachingEnabled, _) {
                final List<Widget> visibleTabs = [];
                final List<NavigationDestination> visibleDestinations = [];

                if (rentEnabled) {
                  visibleTabs.add(const HomeScreen());
                  visibleDestinations.add(
                    NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        color: currentIndex == visibleTabs.length - 1
                            ? theme.colorScheme.primary
                            : const Color(0xFF64748B),
                      ),
                      selectedIcon: Icon(
                        Icons.home_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Rent',
                    ),
                  );
                }

                if (coachingEnabled) {
                  visibleTabs.add(const CoachingScreen());
                  visibleDestinations.add(
                    NavigationDestination(
                      icon: Icon(
                        Icons.school_outlined,
                        color: currentIndex == visibleTabs.length - 1
                            ? theme.colorScheme.primary
                            : const Color(0xFF64748B),
                      ),
                      selectedIcon: Icon(
                        Icons.school_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Coaching',
                    ),
                  );
                }

                // History tab
                visibleTabs.add(const HistoryTab());
                visibleDestinations.add(
                  NavigationDestination(
                    icon: Icon(
                      Icons.history_outlined,
                      color: currentIndex == visibleTabs.length - 1
                          ? theme.colorScheme.primary
                          : const Color(0xFF64748B),
                    ),
                    selectedIcon: Icon(
                      Icons.history_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    label: 'History',
                  ),
                );

                // Settings tab
                visibleTabs.add(const SettingsTab());
                visibleDestinations.add(
                  NavigationDestination(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: currentIndex == visibleTabs.length - 1
                          ? theme.colorScheme.primary
                          : const Color(0xFF64748B),
                    ),
                    selectedIcon: Icon(
                      Icons.settings_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    label: 'Settings',
                  ),
                );

                // Cap the index if out of bounds (e.g. when a feature is disabled)
                int safeIndex = currentIndex;
                if (safeIndex >= visibleTabs.length) {
                  safeIndex = visibleTabs.length - 1;
                  // Update the notifier asynchronously to avoid building issues
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    dashboardTabNotifier.value = safeIndex;
                  });
                }

                return Scaffold(
                  body: IndexedStack(
                    index: safeIndex,
                    children: visibleTabs,
                  ),
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black38 : const Color(0x0A000000),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: NavigationBar(
                      selectedIndex: safeIndex,
                      onDestinationSelected: (index) {
                        dashboardTabNotifier.value = index;
                      },
                      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      height: 74,
                      destinations: visibleDestinations,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
