import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';
import '../home_controller.dart';

class BillForm extends StatelessWidget {
  const BillForm({super.key});

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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
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
                      value: controller.selectedYear,
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
                      value: controller.selectedMonth,
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
                    onPressed: controller.calculateTotalBill,
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
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          style: const TextStyle(fontStyle: FontStyle.italic)),
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
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: controller.history.first));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Data copied to clipboard!')));
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FlutterShare.share(
                        title: 'Invoice', text: controller.history.first);
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to share: $e')));
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
