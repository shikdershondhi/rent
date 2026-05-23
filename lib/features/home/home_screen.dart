import 'package:flutter/material.dart';
import 'widgets/bill_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const Text('Rent Calculator'),
          ],
        ),
      ),
      body: const BillForm(),
    );
  }
}
