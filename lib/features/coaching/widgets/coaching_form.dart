import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../coaching_controller.dart';
import '../../../../core/theme.dart';

class CoachingForm extends StatefulWidget {
  const CoachingForm({super.key});

  @override
  State<CoachingForm> createState() => _CoachingFormState();
}

class _CoachingFormState extends State<CoachingForm> {
  final GlobalKey repaintKey = GlobalKey();
  late CoachingController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = Provider.of<CoachingController>(context);
    _setupListeners(_controller);
  }

  void _setupListeners(CoachingController controller) {
    final list = [
      controller.nameController,
      controller.classController,
      controller.batchController,
      controller.sessionController,
      controller.amountController,
      controller.dueController,
      controller.advanceController,
      controller.noticeController,
    ];
    for (var c in list) {
      c.removeListener(_onTextChanged);
      c.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
      _controller.saveDraft();
    }
  }

  double _calculateRunningTotal(CoachingController controller) {
    double total = (double.tryParse(controller.amountController.text) ?? 0) +
        (double.tryParse(controller.dueController.text) ?? 0);
    total -= (double.tryParse(controller.advanceController.text) ?? 0);
    for (var c in controller.additionalControllers) {
      if (c.text.isNotEmpty) {
        total += (double.tryParse(c.text) ?? 0);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final theme = Theme.of(context);
    final runningTotal = _calculateRunningTotal(controller);

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  // CARD 1: Student Details
                  _buildSectionCard(
                    theme: theme,
                    title: 'Student Details',
                    icon: Icons.school_rounded,
                    accentColor: AppTheme.primaryIndigo,
                    children: [
                      TextFormField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter student name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.classController,
                              decoration: const InputDecoration(
                                labelText: 'Class / Grade',
                                prefixIcon: Icon(Icons.class_outlined),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter class'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.batchController,
                              decoration: const InputDecoration(
                                labelText: 'Batch Name',
                                prefixIcon: Icon(Icons.group_outlined),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter batch'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.sessionController,
                        decoration: const InputDecoration(
                          labelText: 'Academic Session',
                          prefixIcon: Icon(Icons.history_edu_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter session'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedYear,
                              decoration: const InputDecoration(
                                labelText: 'Year',
                              ),
                              items: CoachingController.years
                                  .map((year) =>
                                      DropdownMenuItem(value: year, child: Text(year)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    controller.selectedYear = val;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedMonth,
                              decoration: const InputDecoration(
                                labelText: 'Month',
                              ),
                              items: CoachingController.months
                                  .map((month) => DropdownMenuItem(
                                      value: month, child: Text(month)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    controller.selectedMonth = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: Fee details
                  _buildSectionCard(
                    theme: theme,
                    title: 'Coaching Fees',
                    icon: Icons.payments_rounded,
                    accentColor: AppTheme.secondaryEmerald,
                    children: [
                      TextFormField(
                        controller: controller.amountController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Tuition Fee',
                          prefixIcon: Icon(Icons.currency_exchange_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter fee amount'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.advanceController,
                        decoration: const InputDecoration(
                          labelText: 'Advance Fee Paid',
                          prefixIcon: Icon(Icons.savings_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter advance amount'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.dueController,
                        decoration: const InputDecoration(
                          labelText: 'Arrears / Due Fee',
                          prefixIcon: Icon(Icons.assignment_late_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter due amount'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              controller.pickDate(picked);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: controller.dateController,
                            decoration: const InputDecoration(
                              labelText: 'Payment Date',
                              prefixIcon: Icon(Icons.date_range_outlined),
                            ),
                            validator: (value) => controller.selectedDate == null
                                ? 'Please select a date'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 3: Custom fields
                  _buildSectionCard(
                    theme: theme,
                    title: 'Additional Items',
                    icon: Icons.playlist_add_rounded,
                    accentColor: AppTheme.accentAmber,
                    children: [
                      if (controller.additionalControllers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No additional charges added.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      for (int i = 0; i < controller.additionalControllers.length; i++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.additionalLabelControllers[i],
                                decoration: const InputDecoration(
                                  labelText: 'Charge Label',
                                  hintText: 'e.g., Exam Fee',
                                ),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Enter a label'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: controller.additionalControllers[i],
                                decoration: const InputDecoration(
                                  labelText: 'Amount (৳)',
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Enter amount'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  controller.removeAdditionalField(i);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Item Field'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            controller.addAdditionalField();
                            final newIndex = controller.additionalControllers.length - 1;
                            controller.additionalControllers[newIndex].addListener(_onTextChanged);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 4: Notice Note
                  _buildSectionCard(
                    theme: theme,
                    title: 'Extra Notice / Note',
                    icon: Icons.note_alt_outlined,
                    accentColor: Colors.blueGrey,
                    children: [
                      TextFormField(
                        controller: controller.noticeController,
                        decoration: const InputDecoration(
                          labelText: 'Notice Note',
                          hintText: 'Add an extra note (visible on invoice)...',
                          alignLabelWithHint: true,
                        ),
                        maxLength: 256,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // STICKY BOTTOM PANEL
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF0F172A).withOpacity(0.9)
                  : Colors.white.withOpacity(0.92),
              border: Border(
                top: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RUNNING TOTAL',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${runningTotal.toStringAsFixed(0)} ৳',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () async {
                      if (controller.formKey.currentState?.validate() ?? false) {
                        await controller.calculateTotalBill();
                        if (mounted) {
                          _previewData(context, controller);
                        }
                      }
                    },
                    child: const Text('Preview'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent),
                    tooltip: 'Clear fields',
                    onPressed: () {
                      controller.clearData();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  void _previewData(BuildContext context, CoachingController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(20.0),
          title: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/app_logo.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Coaching Receipt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: 320.0,
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: repaintKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt Header
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/app_logo.png',
                                width: 44,
                                height: 44,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'TUITION RECEIPT',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            if (controller.lastInvoiceId != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${controller.lastInvoiceId}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDashedLine(isDark),
                      const SizedBox(height: 12),

                      // Customer Details Section
                      const Text(
                        'STUDENT DETAILS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text('Name: ${controller.nameController.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (controller.classController.text.isNotEmpty)
                        Text('Class: ${controller.classController.text}'),
                      if (controller.batchController.text.isNotEmpty)
                        Text('Batch: ${controller.batchController.text}'),
                      if (controller.sessionController.text.isNotEmpty)
                        Text('Session: ${controller.sessionController.text}'),
                      if (controller.dateController.text.isNotEmpty)
                        Text('Date: ${controller.dateController.text}'),

                      const SizedBox(height: 12),
                      _buildDashedLine(isDark),
                      const SizedBox(height: 12),

                      // Invoice breakdown details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Billing Period:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${controller.selectedMonth} ${controller.selectedYear}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDashedLine(isDark),
                      const SizedBox(height: 12),

                      // Billing lines
                      _buildReceiptRow('Tuition Base Fee', controller.amountController.text),
                      if ((double.tryParse(controller.dueController.text) ?? 0) > 0)
                        _buildReceiptRow('Arrears / Due Fee', '+ ${controller.dueController.text}'),

                      for (int i = 0; i < controller.additionalControllers.length; i++)
                        if (controller.additionalControllers[i].text.isNotEmpty)
                          _buildReceiptRow(
                            controller.additionalLabelControllers[i].text,
                            '+ ${controller.additionalControllers[i].text}',
                          ),

                      if ((double.tryParse(controller.advanceController.text) ?? 0) > 0)
                        _buildReceiptRow(
                          'Advance Fee Paid',
                          '- ${controller.advanceController.text}',
                          valueColor: Colors.redAccent,
                        ),

                      const SizedBox(height: 12),
                      _buildDashedLine(isDark),
                      const SizedBox(height: 16),

                      // Totals Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL AMOUNT DUE',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${controller.totalBill.toStringAsFixed(0)} ৳',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),

                      if (controller.noticeController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDashedLine(isDark),
                        const SizedBox(height: 12),
                        const Text(
                          'NOTICE / NOTE:',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.noticeController.text,
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                  onPressed: () {
                    if (controller.history.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: controller.history.first));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Details copied to clipboard!')),
                      );
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Share'),
                  onPressed: () async {
                    if (controller.history.isNotEmpty) {
                      try {
                        await Share.share(controller.history.first, subject: 'Coaching Invoice');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to share: $e')),
                        );
                      }
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Save Image'),
                  onPressed: () async {
                    try {
                      final granted = await _requestSavePermission();
                      if (!granted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Storage/Photos permission denied')),
                        );
                        return;
                      }
                      final boundary = repaintKey.currentContext
                          ?.findRenderObject() as RenderRepaintBoundary?;
                      if (boundary == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to capture image')),
                        );
                        return;
                      }
                      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                      final bytes = byteData!.buffer.asUint8List();
                      final name = 'coaching_invoice_${controller.lastInvoiceId ?? DateTime.now().millisecondsSinceEpoch}';
                      final result = await ImageGallerySaverPlus.saveImage(bytes, name: name);
                      var success = false;
                      if (result is Map && result['isSuccess'] == true) {
                        success = true;
                      } else if (result == true) {
                        success = true;
                      } else if (result != null) {
                        success = true;
                      }
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved successfully to gallery!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save image')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save image: $e')),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine(bool isDark) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double boxWidth = constraints.constrainWidth();
        if (boxWidth.isInfinite || boxWidth <= 0 || boxWidth > 10000) {
          boxWidth = 280.0; // Sensible default width for a standard dialog receipt
        }
        const dashWidth = 5.0;
        final dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12),
              ),
            );
          }),
        );
      },
    );
  }

  Future<bool> _requestSavePermission() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted) return true;

      final statuses = await [Permission.storage, Permission.photos].request();
      final s = statuses[Permission.storage];
      final p = statuses[Permission.photos];
      if (s?.isGranted == true || p?.isGranted == true) return true;
      return false;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      return false;
    }
    return true;
  }
}
