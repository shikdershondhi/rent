import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _historyKey = 'rent_history_v1';
  static const String _counterKey = 'rent_invoice_counter_v1';
  String? lastInvoiceId;

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

  Future<void> calculateTotalBill() async {
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
      await _addToHistory();
      notifyListeners();
    }
  }

  Future<void> _addToHistory() async {
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
    // avoid duplicates: if same summary exists, move it to top
    final existingIndex = history.indexWhere((h) => h.contains(summary));
    if (existingIndex != -1) {
      final existing = history.removeAt(existingIndex);
      history.insert(0, existing);
      if (existing.startsWith('Invoice ID:')) {
        lastInvoiceId =
            existing.split('\n').first.replaceFirst('Invoice ID:', '').trim();
      }
      await saveHistory();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      int counter = prefs.getInt(_counterKey) ?? 0;
      counter++;
      await prefs.setInt(_counterKey, counter);
      final invoiceId = 'RN-${counter.toString().padLeft(5, '0')}';
      lastInvoiceId = invoiceId;
      final full = 'Invoice ID: $invoiceId\n' + summary;
      history.insert(0, full);
      if (history.length > 50) history.removeLast();
      await saveHistory();
    } catch (_) {
      final invoiceId =
          'RN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
      lastInvoiceId = invoiceId;
      final full = 'Invoice ID: $invoiceId\n' + summary;
      history.insert(0, full);
      if (history.length > 50) history.removeLast();
      await saveHistory();
    }
  }

  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);
    } catch (_) {}
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_historyKey);
      if (list != null) {
        history.clear();
        history.addAll(list);
        if (history.isNotEmpty && history.first.startsWith('Invoice ID:')) {
          lastInvoiceId = history.first
              .split('\n')
              .first
              .replaceFirst('Invoice ID:', '')
              .trim();
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> clearSavedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      await prefs.setInt(_counterKey, 0);
    } catch (_) {}
    history.clear();
    lastInvoiceId = null;
    notifyListeners();
  }

  Future<void> removeHistoryAt(int index) async {
    if (index < 0 || index >= history.length) return;
    history.removeAt(index);
    await saveHistory();
    if (history.isNotEmpty && history.first.startsWith('Invoice ID:')) {
      lastInvoiceId = history.first
          .split('\n')
          .first
          .replaceFirst('Invoice ID:', '')
          .trim();
    } else {
      lastInvoiceId = null;
    }
    notifyListeners();
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
