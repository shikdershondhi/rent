import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final rentController = TextEditingController(text: '0');
  final advanceRentController = TextEditingController(text: '0');
  final dueRentController = TextEditingController(text: '0');
  final gasController = TextEditingController(text: '0');
  final electricityController = TextEditingController(text: '0');
  final serviceChargeController = TextEditingController(text: '0');
  final utilityBillController = TextEditingController(text: '0');
  final noticeController = TextEditingController();

  String selectedMonth = months[DateTime.now().month - 1];
  String selectedYear = DateTime.now().year.toString();
  double totalBill = 0.0;
  final List<TextEditingController> additionalControllers = [];
  final List<TextEditingController> additionalLabelControllers = [];
  final List<String> history = [];

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static final List<String> years = List.generate(
      10, (index) => (DateTime.now().year - 5 + index).toString());

  void calculateTotalBill() {
    if (formKey.currentState?.validate() ?? false) {
      double total = double.parse(rentController.text) +
          double.parse(dueRentController.text) +
          double.parse(gasController.text) +
          double.parse(electricityController.text) +
          double.parse(serviceChargeController.text) +
          double.parse(utilityBillController.text);
      total -= double.parse(advanceRentController.text);
      for (var controller in additionalControllers) {
        if (controller.text.isNotEmpty) {
          total += double.parse(controller.text);
        }
      }
      totalBill = total;
      _addToHistory();
      notifyListeners();
    }
  }

  void _addToHistory() {
    final additional = additionalControllers
        .asMap()
        .entries
        .map((entry) => additionalLabelControllers[entry.key].text.isNotEmpty
            ? '${additionalLabelControllers[entry.key].text}: ${entry.value.text}'
            : '')
        .where((e) => e.isNotEmpty)
        .join('\n');
    final summary = 'Name: ${nameController.text}\n'
        'Address: ${addressController.text}\n'
        'Phone: ${phoneController.text}\n'
        'Year: $selectedYear\n'
        'Month: $selectedMonth\n'
        'Rent: ${rentController.text}\n'
        'Advance Rent: ${advanceRentController.text}\n'
        'Due Rent: ${dueRentController.text}\n'
        'GAS: ${gasController.text}\n'
        'Electricity Bill: ${electricityController.text}\n'
        'Service Charge: ${serviceChargeController.text}\n'
        'Utility Bill: ${utilityBillController.text}\n'
        '${additional.isNotEmpty ? '$additional\n' : ''}'
        'Notice: ${noticeController.text}\n'
        'Total Bill: $totalBill';
    history.insert(0, summary);
    if (history.length > 20) history.removeLast();
  }

  void clearData() {
    nameController.clear();
    addressController.clear();
    phoneController.clear();
    rentController.text = '0';
    advanceRentController.text = '0';
    dueRentController.text = '0';
    gasController.text = '0';
    electricityController.text = '0';
    serviceChargeController.text = '0';
    utilityBillController.text = '0';
    noticeController.clear();
    for (var c in additionalControllers) {
      c.clear();
    }
    for (var c in additionalLabelControllers) {
      c.clear();
    }
    totalBill = 0.0;
    selectedMonth = months[DateTime.now().month - 1];
    selectedYear = DateTime.now().year.toString();
    notifyListeners();
  }

  void addAdditionalField() {
    additionalControllers.add(TextEditingController());
    additionalLabelControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeAdditionalField(int index) {
    additionalControllers.removeAt(index);
    additionalLabelControllers.removeAt(index);
    notifyListeners();
  }
}
