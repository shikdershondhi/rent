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

class BillForm extends StatefulWidget {
  const BillForm({super.key});

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final GlobalKey repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                    labelText: 'Address', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
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
                      initialValue: controller.selectedYear,
                      decoration: const InputDecoration(
                          labelText: 'Year', border: OutlineInputBorder()),
                      items: HomeController.years
                          .map((year) =>
                              DropdownMenuItem(value: year, child: Text(year)))
                          .toList(),
                      onChanged: (val) => controller.selectedYear = val!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.selectedMonth,
                      decoration: const InputDecoration(
                          labelText: 'Month', border: OutlineInputBorder()),
                      items: HomeController.months
                          .map((month) => DropdownMenuItem(
                              value: month, child: Text(month)))
                          .toList(),
                      onChanged: (val) => controller.selectedMonth = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.rentController,
                decoration: const InputDecoration(
                    labelText: 'Rent of Month', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rent';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.advanceRentController,
                decoration: const InputDecoration(
                    labelText: 'Advance Rent of Month',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the advance rent';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.dueRentController,
                decoration: const InputDecoration(
                    labelText: 'Due Rent of Month',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the due rent';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.gasController,
                decoration: const InputDecoration(
                    labelText: 'GAS', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the GAS bill';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.electricityController,
                decoration: const InputDecoration(
                    labelText: 'Electricity Bill',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the electricity bill';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.serviceChargeController,
                decoration: const InputDecoration(
                    labelText: 'Service Charge', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service charge';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.utilityBillController,
                decoration: const InputDecoration(
                    labelText: 'Utility Bill', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the utility bill';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < controller.additionalControllers.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.additionalLabelControllers[i],
                        decoration: const InputDecoration(
                            labelText: 'Field Label',
                            border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a label'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.additionalControllers[i],
                        decoration: const InputDecoration(
                            labelText: 'Value', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Only whole numbers are allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.removeAdditionalField(i),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: controller.addAdditionalField,
                child: const Text('Add Additional Field'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.noticeController,
                decoration: const InputDecoration(
                    labelText: 'Notice', border: OutlineInputBorder()),
                maxLength: 256,
                maxLines: 3,
                validator: (value) => value != null && value.length > 256
                    ? 'Notice cannot exceed 256 characters'
                    : null,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text('Total Bill: ${controller.totalBill}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async =>
                        await controller.calculateTotalBill(),
                    child: const Text('Calculate Bill'),
                  ),
                  ElevatedButton(
                    onPressed: () => _previewData(context, controller),
                    child: const Text('Preview'),
                  ),
                  ElevatedButton(
                    onPressed: controller.clearData,
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewData(BuildContext context, HomeController controller) {
    if (controller.formKey.currentState?.validate() ?? false) {
      controller.calculateTotalBill();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invoice',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            content: SingleChildScrollView(
              child: RepaintBoundary(
                key: repaintKey,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.lastInvoiceId != null)
                          Text('Invoice ID: ${controller.lastInvoiceId}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Customer Details',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 8),
                        Text('Name: ${controller.nameController.text}'),
                        Text('Address: ${controller.addressController.text}'),
                        Text('Phone: ${controller.phoneController.text}'),
                        const SizedBox(height: 16),
                        const Text('Invoice Details',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 8),
                        Text('Year: ${controller.selectedYear}'),
                        Text('Month: ${controller.selectedMonth}'),
                        Text('Rent: ${controller.rentController.text}'),
                        Text(
                            'Advance Rent: ${controller.advanceRentController.text}'),
                        Text('Due Rent: ${controller.dueRentController.text}'),
                        Text('GAS: ${controller.gasController.text}'),
                        Text(
                            'Electricity Bill: ${controller.electricityController.text}'),
                        Text(
                            'Service Charge: ${controller.serviceChargeController.text}'),
                        Text(
                            'Utility Bill: ${controller.utilityBillController.text}'),
                        for (int i = 0;
                            i < controller.additionalControllers.length;
                            i++)
                          Text(
                              '${controller.additionalLabelControllers[i].text}: ${controller.additionalControllers[i].text}'),
                        const SizedBox(height: 16),
                        Text('Notice: ${controller.noticeController.text}',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Total Bill: ${controller.totalBill}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (controller.history.isNotEmpty) {
                          Clipboard.setData(
                              ClipboardData(text: controller.history.first));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Data copied to clipboard!')));
                        }
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (controller.history.isNotEmpty) {
                          try {
                            await Share.share(controller.history.first,
                                subject: 'Invoice');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to share: $e')));
                          }
                        }
                      },
                      child: const Text('Share'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final granted = await _requestSavePermission();
                          if (!granted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Permission denied')));
                            return;
                          }
                          final boundary = repaintKey.currentContext
                              ?.findRenderObject() as RenderRepaintBoundary?;
                          if (boundary == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to capture image')));
                            return;
                          }
                          final ui.Image image =
                              await boundary.toImage(pixelRatio: 3.0);
                          final byteData = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          final bytes = byteData!.buffer.asUint8List();
                          final name =
                              'invoice_${controller.lastInvoiceId ?? DateTime.now().millisecondsSinceEpoch}';
                          final result = await ImageGallerySaverPlus.saveImage(
                              bytes,
                              name: name);
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
                                const SnackBar(
                                    content: Text('Saved to gallery')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to save image')));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to save image: $e')));
                        }
                      },
                      child: const Text('Download'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }
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

      if (s?.isPermanentlyDenied == true || p?.isPermanentlyDenied == true) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission required'),
            content: const Text(
                'Please enable storage/photos permission in app settings to save images.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Open Settings')),
            ],
          ),
        );
        if (open == true) {
          await openAppSettings();
        }
      }
      return false;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission required'),
            content: const Text(
                'Please enable photos permission in app settings to save images.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Open Settings')),
            ],
          ),
        );
        if (open == true) await openAppSettings();
      }
      return false;
    }
    return false;
  }
}
