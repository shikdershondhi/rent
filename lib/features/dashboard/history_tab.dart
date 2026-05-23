import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../home/home_controller.dart';
import '../coaching/coaching_controller.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  Map<String, String> _parseInvoice(String rawText) {
    final Map<String, String> data = {};
    final lines = rawText.split('\n');
    for (var line in lines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex != -1) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        data[key] = value;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: rentEnabledNotifier,
      builder: (context, rentEnabled, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: coachingEnabledNotifier,
          builder: (context, coachingEnabled, _) {
            if (rentEnabled && coachingEnabled) {
              return DefaultTabController(
                key: const ValueKey('both_enabled'),
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/app_logo.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Invoice Archive'),
                      ],
                    ),
                    bottom: TabBar(
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Rent Bills'),
                        Tab(text: 'Coaching Fees'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      _buildRentHistoryList(context, theme, isDark),
                      _buildCoachingHistoryList(context, theme, isDark),
                    ],
                  ),
                ),
              );
            } else if (rentEnabled) {
              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/app_logo.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Rent Invoice Archive'),
                    ],
                  ),
                ),
                body: _buildRentHistoryList(context, theme, isDark),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/app_logo.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Coaching Invoice Archive'),
                    ],
                  ),
                ),
                body: _buildCoachingHistoryList(context, theme, isDark),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildRentHistoryList(BuildContext context, ThemeData theme, bool isDark) {
    final controller = Provider.of<HomeController>(context);
    final history = controller.history;

    if (history.isEmpty) {
      return _buildEmptyState(theme, Icons.receipt_long_rounded, 'No saved rent invoices');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final rawText = history[index];
        final data = _parseInvoice(rawText);

        final invoiceId = data['Invoice ID'] ?? 'RN-N/A';
        final name = data['Name'] ?? 'Unknown';
        final address = data['Address'] ?? '';
        final month = data['Month'] ?? '';
        final year = data['Year'] ?? '';
        final total = data['Total Bill'] ?? '0';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        invoiceId,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (month.isNotEmpty || year.isNotEmpty)
                      Text(
                        '$month $year',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total ৳',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          tooltip: 'Copy details',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Details copied to clipboard!')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          tooltip: 'Share invoice',
                          onPressed: () async {
                            try {
                              await Share.share(rawText, subject: 'Rent Invoice $invoiceId');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to share: $e')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                          tooltip: 'Delete invoice',
                          onPressed: () async {
                            final confirm = await _showDeleteConfirmDialog(context, theme, invoiceId);
                            if (confirm == true) {
                              await controller.removeHistoryAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invoice deleted')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoachingHistoryList(BuildContext context, ThemeData theme, bool isDark) {
    final controller = Provider.of<CoachingController>(context);
    final history = controller.history;

    if (history.isEmpty) {
      return _buildEmptyState(theme, Icons.school_rounded, 'No saved coaching invoices');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final rawText = history[index];
        final data = _parseInvoice(rawText);

        final invoiceId = data['Invoice ID'] ?? 'CF-N/A';
        final name = data['Name'] ?? 'Unknown';
        final className = data['Class'] ?? '';
        final month = data['Month'] ?? '';
        final year = data['Year'] ?? '';
        final total = data['Total Fee'] ?? '0';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        invoiceId,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (month.isNotEmpty || year.isNotEmpty)
                      Text(
                        '$month $year',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (className.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Class: $className',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL FEE',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total ৳',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          tooltip: 'Copy details',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Details copied to clipboard!')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          tooltip: 'Share invoice',
                          onPressed: () async {
                            try {
                              await Share.share(rawText, subject: 'Coaching Fee Invoice $invoiceId');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to share: $e')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                          tooltip: 'Delete invoice',
                          onPressed: () async {
                            final confirm = await _showDeleteConfirmDialog(context, theme, invoiceId);
                            if (confirm == true) {
                              await controller.removeHistoryAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invoice deleted')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Once you calculate and save a bill, it will appear here in this archive.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, ThemeData theme, String invoiceId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text('Are you sure you want to delete invoice $invoiceId? This action cannot be undone.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
