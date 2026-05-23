import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../home_controller.dart';
import '../../../../core/theme.dart';

class BillForm extends StatefulWidget {
  const BillForm({super.key});

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final GlobalKey repaintKey = GlobalKey();
  late HomeController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = Provider.of<HomeController>(context);
    _setupListeners(_controller);
  }

  void _setupListeners(HomeController controller) {
    final list = [
      controller.nameController,
      controller.addressController,
      controller.phoneController,
      controller.rentController,
      controller.advanceRentController,
      controller.dueRentController,
      controller.gasController,
      controller.electricityController,
      controller.serviceChargeController,
      controller.utilityBillController,
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

  double _calculateRunningTotal(HomeController controller) {
    double total = (double.tryParse(controller.rentController.text) ?? 0) +
        (double.tryParse(controller.dueRentController.text) ?? 0) +
        (double.tryParse(controller.gasController.text) ?? 0) +
        (double.tryParse(controller.electricityController.text) ?? 0) +
        (double.tryParse(controller.serviceChargeController.text) ?? 0) +
        (double.tryParse(controller.utilityBillController.text) ?? 0);
    total -= (double.tryParse(controller.advanceRentController.text) ?? 0);
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
                  // CARD 1: Customer Details
                  _buildSectionCard(
                    theme: theme,
                    title: 'Customer Details',
                    icon: Icons.person_rounded,
                    accentColor: AppTheme.primaryIndigo,
                    children: [
                      TextFormField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter customer name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Only numbers are allowed';
                          }
                          return null;
                        },
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
                              items: HomeController.years
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
                              items: HomeController.months
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

                  // CARD 2: Rent details
                  _buildSectionCard(
                    theme: theme,
                    title: 'Rent Breakdowns',
                    icon: Icons.payments_rounded,
                    accentColor: AppTheme.accentAmber,
                    children: [
                      TextFormField(
                        controller: controller.rentController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Base Rent',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter monthly rent'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.advanceRentController,
                        decoration: const InputDecoration(
                          labelText: 'Advance Paid',
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
                        controller: controller.dueRentController,
                        decoration: const InputDecoration(
                          labelText: 'Arrears / Due Rent',
                          prefixIcon: Icon(Icons.assignment_late_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter due amount'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 3: Utilities
                  _buildSectionCard(
                    theme: theme,
                    title: 'Utility Charges',
                    icon: Icons.electrical_services_rounded,
                    accentColor: AppTheme.secondaryEmerald,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.electricityController,
                              decoration: const InputDecoration(
                                labelText: 'Electricity',
                                prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter electricity bill'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.gasController,
                              decoration: const InputDecoration(
                                labelText: 'Gas / Fuel',
                                prefixIcon: Icon(Icons.local_fire_department_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter gas bill'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.serviceChargeController,
                              decoration: const InputDecoration(
                                labelText: 'Service Charge',
                                prefixIcon: Icon(Icons.room_service_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter service charge'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.utilityBillController,
                              decoration: const InputDecoration(
                                labelText: 'Water / Utility',
                                prefixIcon: Icon(Icons.water_drop_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter utility bill'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 4: Custom Additions
                  _buildSectionCard(
                    theme: theme,
                    title: 'Additional Charges',
                    icon: Icons.playlist_add_rounded,
                    accentColor: theme.colorScheme.primary,
                    children: [
                      if (controller.additionalControllers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No custom charges added yet.',
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
                                  hintText: 'e.g., Internet',
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
                        label: const Text('Add Custom Field'),
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

                  // CARD 5: Notes/Notice
                  _buildSectionCard(
                    theme: theme,
                    title: 'Special Notice / Instructions',
                    icon: Icons.note_alt_outlined,
                    accentColor: Colors.blueGrey,
                    children: [
                      TextFormField(
                        controller: controller.noticeController,
                        decoration: const InputDecoration(
                          labelText: 'Notice Note',
                          hintText: 'Add an extra note (visible on the invoice)...',
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
          // Header of the card
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

  void _previewData(BuildContext context, HomeController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: dialogBgColor,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          title: null, // Unified single-card design (header built in content)
          content: SizedBox(
            width: 320.0,
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: repaintKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Premium Gradient Receipt Header
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(26),
                            topRight: Radius.circular(26),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  'assets/app_logo.png',
                                  width: 44,
                                  height: 44,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'RENT RECEIPT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            if (controller.lastInvoiceId != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30, width: 0.8),
                                ),
                                child: Text(
                                  'ID: ${controller.lastInvoiceId}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 2. Receipt Body
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section: Tenant Details Box
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TENANT DETAILS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDetailRow(Icons.person_rounded, 'Name', controller.nameController.text, isDark),
                                  _buildDetailRow(Icons.phone_rounded, 'Phone', controller.phoneController.text, isDark),
                                  _buildDetailRow(Icons.location_on_rounded, 'Address', controller.addressController.text, isDark),
                                  _buildDetailRow(
                                    Icons.calendar_month_rounded,
                                    'Period',
                                    '${controller.selectedMonth} ${controller.selectedYear}',
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Ticket Notch Separator 1
                            _buildTicketNotchDivider(isDark, dialogBgColor),
                            const SizedBox(height: 20),

                            // Section: Billing Items Table
                            const Text(
                              'BILL BREAKDOWN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildReceiptRow('Monthly Base Rent', '${controller.rentController.text} ৳', icon: Icons.home_work_rounded),
                            if ((double.tryParse(controller.dueRentController.text) ?? 0) > 0)
                              _buildReceiptRow(
                                'Arrears / Due Rent',
                                '+ ${controller.dueRentController.text} ৳',
                                valueColor: Colors.orangeAccent,
                                icon: Icons.assignment_late_outlined,
                              ),
                            _buildReceiptRow('Electricity Bill', '+ ${controller.electricityController.text} ৳', icon: Icons.bolt_rounded),
                            _buildReceiptRow('Gas / Fuel', '+ ${controller.gasController.text} ৳', icon: Icons.local_fire_department_rounded),
                            _buildReceiptRow('Service Charge', '+ ${controller.serviceChargeController.text} ৳', icon: Icons.handyman_rounded),
                            _buildReceiptRow('Water / Utility', '+ ${controller.utilityBillController.text} ৳', icon: Icons.water_drop_rounded),

                            for (int i = 0; i < controller.additionalControllers.length; i++)
                              if (controller.additionalControllers[i].text.isNotEmpty)
                                _buildReceiptRow(
                                  controller.additionalLabelControllers[i].text,
                                  '+ ${controller.additionalControllers[i].text} ৳',
                                  icon: Icons.add_circle_outline_rounded,
                                ),

                            if ((double.tryParse(controller.advanceRentController.text) ?? 0) > 0)
                              _buildReceiptRow(
                                'Advance Paid',
                                '- ${controller.advanceRentController.text} ৳',
                                valueColor: Colors.redAccent,
                                icon: Icons.check_circle_outline_rounded,
                              ),

                            const SizedBox(height: 20),

                            // Ticket Notch Separator 2
                            _buildTicketNotchDivider(isDark, dialogBgColor),
                            const SizedBox(height: 20),

                            // Section: Grand Total High-contrast Box
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF064E3B).withOpacity(0.2)
                                    : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF047857).withOpacity(0.4)
                                      : const Color(0xFFA7F3D0),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TOTAL DUE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                          color: isDark ? Colors.white70 : const Color(0xFF065F46),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Net Payable',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${controller.totalBill.toStringAsFixed(0)} ৳',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (controller.noticeController.text.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'NOTICE / REMARKS:',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.noticeController.text,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),
                            // Authentic Receipt Barcode
                            _buildBarcode(),
                            const SizedBox(height: 12),

                            // Physical Torn Ticket Bottom Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.content_cut_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '-------------------------------------------',
                                    style: TextStyle(color: Colors.grey.withOpacity(0.3), fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                    onPressed: () async {
                      if (controller.history.isNotEmpty) {
                        try {
                          await Share.share(controller.history.first, subject: 'Rent Invoice');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to share: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Save'),
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
                        final name = 'invoice_${controller.lastInvoiceId ?? DateTime.now().millisecondsSinceEpoch}';
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
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Receipt'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketNotchDivider(bool isDark, Color dialogBgColor) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _buildDashedLine(isDark),
        Positioned(
          left: -28, // Pull slightly outside dialog padding area
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: dialogBgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -28, // Pull slightly outside dialog padding area
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: dialogBgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 2, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 2),
        Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 1),
        Container(width: 4, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 2),
        Container(width: 2, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 3),
        Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 1),
        Container(width: 3, height: 24, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(width: 2),
        Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_outline_rounded,
            size: 16,
            color: valueColor ?? const Color(0xFF6366F1).withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
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
