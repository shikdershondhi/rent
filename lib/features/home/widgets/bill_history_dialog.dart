import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../home_controller.dart';

void showBillHistoryDialog(BuildContext context, HomeController controller) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Calculation History'),
        content: SizedBox(
          width: 400,
          child: controller.history.isEmpty
              ? const Text('No history yet.')
              : StatefulBuilder(builder: (context, setState) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.history.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final parts = controller.history[i].split('\n');
                      String invoice = '';
                      String summary = controller.history[i];
                      if (parts.isNotEmpty &&
                          parts.first.startsWith('Invoice ID:')) {
                        invoice =
                            parts.first.replaceFirst('Invoice ID:', '').trim();
                        summary = parts.skip(1).join('\n');
                      }
                      return ListTile(
                        title: Text(
                          invoice.isNotEmpty ? invoice : 'Entry ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text(summary, style: const TextStyle(fontSize: 13)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () async {
                                try {
                                  await Share.share(
                                    controller.history[i],
                                    subject: 'Invoice',
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Failed to share: $e')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete entry?'),
                                    content: const Text(
                                        'This will remove the selected history entry.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await controller.removeHistoryAt(i);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Entry deleted')));
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
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
