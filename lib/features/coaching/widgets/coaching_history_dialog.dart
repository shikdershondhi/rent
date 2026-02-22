import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void showCoachingHistoryDialog(BuildContext context, List<String> history) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Coaching Calculation History'),
        content: SizedBox(
          width: 400,
          child: history.isEmpty
              ? const Text('No history yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final parts = history[i].split('\n');
                    String invoice = '';
                    String summary = history[i];
                    if (parts.isNotEmpty &&
                        parts.first.startsWith('Invoice ID:')) {
                      invoice =
                          parts.first.replaceFirst('Invoice ID:', '').trim();
                      summary = parts.skip(1).join('\n');
                    }
                    return ListTile(
                      title: Text(
                          invoice.isNotEmpty ? invoice : 'Entry ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text(summary, style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          try {
                            await Share.share(
                              history[i],
                              subject: 'Coaching Calculation History',
                            );
                          } catch (e) {
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
