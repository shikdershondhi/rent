import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../coaching_controller.dart';

class CoachingForm extends StatelessWidget {
  const CoachingForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CoachingController>(context);
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
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.classController,
                decoration: const InputDecoration(
                    labelText: 'Class', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a class'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.batchController,
                decoration: const InputDecoration(
                    labelText: 'Batch', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a batch'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.sessionController,
                decoration: const InputDecoration(
                    labelText: 'Session', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a session'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.selectedYear,
                      decoration: const InputDecoration(
                          labelText: 'Year', border: OutlineInputBorder()),
                      items: CoachingController.years
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
                      items: CoachingController.months
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
                controller: controller.amountController,
                decoration: const InputDecoration(
                    labelText: 'Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.advanceController,
                decoration: const InputDecoration(
                    labelText: 'Advance Fee', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the advance amount';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.dueController,
                decoration: const InputDecoration(
                    labelText: 'Due', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the due amount';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Only whole numbers are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (picked != null) controller.pickDate(picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: controller.dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => controller.selectedDate == null
                        ? 'Please select a date'
                        : null,
                  ),
                ),
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
                child: const Text('Add Custom Field'),
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
              Text('Total Fee: ${controller.totalBill}',
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
                    onPressed: controller.calculateTotalBill,
                    child: const Text('Calculate Fee'),
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

  void _previewData(BuildContext context, CoachingController controller) {
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
                      const Text('Student Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      const SizedBox(height: 8),
                      Text('Name: ${controller.nameController.text}'),
                      Text('Class: ${controller.classController.text}'),
                      Text('Batch: ${controller.batchController.text}'),
                      Text('Session: ${controller.sessionController.text}'),
                      const SizedBox(height: 16),
                      const Text('Invoice Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      const SizedBox(height: 8),
                      Text('Year: ${controller.selectedYear}'),
                      Text('Month: ${controller.selectedMonth}'),
                      Text('Amount: ${controller.amountController.text}'),
                      Text('Advance Fee: ${controller.advanceController.text}'),
                      Text('Due: ${controller.dueController.text}'),
                      for (int i = 0;
                          i < controller.additionalControllers.length;
                          i++)
                        Text(
                            '${controller.additionalLabelControllers[i].text}: ${controller.additionalControllers[i].text}'),
                      const SizedBox(height: 16),
                      Text('Notice: ${controller.noticeController.text}',
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Total Fee: ${controller.totalBill}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (controller.history.isNotEmpty) {
                    Clipboard.setData(
                        ClipboardData(text: controller.history.first));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}
