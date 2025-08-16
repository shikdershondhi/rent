import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

void showBillHistoryDialog(BuildContext context, List<String> history) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Calculation History'),
        content: SizedBox(
          width: 400,
          child: history.isEmpty
              ? const Text('No history yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(history[i],
                          style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          try {
                            await FlutterShare.share(
                              title: 'Calculation History',
                              text: history[i],
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to share: $e')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
