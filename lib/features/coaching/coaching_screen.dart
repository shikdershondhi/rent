import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coaching_controller.dart';
import 'widgets/coaching_form.dart';
import 'widgets/coaching_history_dialog.dart';

class CoachingScreen extends StatefulWidget {
  const CoachingScreen({super.key});

  @override
  State<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends State<CoachingScreen> {
  late final CoachingController controller;

  @override
  void initState() {
    super.initState();
    controller = CoachingController();
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
        title: const Text('Coaching Fee Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear saved history',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear saved history?'),
                  content: const Text(
                      'This will delete all saved coaching history.'),
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
      body: ChangeNotifierProvider<CoachingController>(
        create: (_) => controller,
        child: const CoachingForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCoachingHistoryDialog(context, controller),
        child: const Icon(Icons.history),
        tooltip: 'History',
      ),
    );
  }
}
