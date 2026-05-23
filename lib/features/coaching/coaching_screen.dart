import 'package:flutter/material.dart';
import 'widgets/coaching_form.dart';

class CoachingScreen extends StatelessWidget {
  const CoachingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Text('Coaching Fee Calculator'),
          ],
        ),
      ),
      body: const CoachingForm(),
    );
  }
}
