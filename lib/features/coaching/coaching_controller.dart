import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CoachingController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final classController = TextEditingController();
  final batchController = TextEditingController();
  final sessionController = TextEditingController();
  final amountController = TextEditingController(text: '0');
  final dueController = TextEditingController(text: '0');
  final advanceController = TextEditingController(text: '0');
  final noticeController = TextEditingController();
  final dateController = TextEditingController();

  String selectedMonth = months[DateTime.now().month - 1];
  String selectedYear = DateTime.now().year.toString();
  DateTime? selectedDate;
  double totalBill = 0.0;
  final List<TextEditingController> additionalControllers = [];
  final List<TextEditingController> additionalLabelControllers = [];
  final List<String> history = [];
  static const String _historyKey = 'coaching_history_v1';
  static const String _counterKey = 'coaching_invoice_counter_v1';
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

  void pickDate(DateTime date) {
    selectedDate = date;
    dateController.text =
        selectedDate!.toLocal().toIso8601String().split('T').first;
    notifyListeners();
  }

  Future<void> calculateTotalBill() async {
    if (formKey.currentState?.validate() ?? false) {
      double total = double.parse(amountController.text) +
          double.parse(dueController.text);
      // subtract advance fee if provided
      total -= double.parse(advanceController.text);
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
    final dateText = selectedDate != null
        ? selectedDate!.toLocal().toIso8601String().split('T').first
        : '';
    final summaryBase = 'Name: ${nameController.text}\n'
        'Class: ${classController.text}\n'
        'Batch: ${batchController.text}\n'
        'Session: ${sessionController.text}\n'
        'Year: $selectedYear\n'
        'Month: $selectedMonth\n'
        'Date: $dateText\n'
        'Amount: ${amountController.text}\n'
        'Advance Fee: ${advanceController.text}\n'
        'Due: ${dueController.text}\n'
        '${additional.isNotEmpty ? '$additional\n' : ''}'
        'Notice: ${noticeController.text}\n'
        'Total Fee: $totalBill';

    // Avoid adding duplicate entries: check if identical summaryBase exists
    final existingIndex = history.indexWhere((h) => h.contains(summaryBase));
    if (existingIndex != -1) {
      // reuse existing invoice id and move entry to top
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
      final invoiceId = 'CF-${counter.toString().padLeft(5, '0')}';
      lastInvoiceId = invoiceId;
      final full = 'Invoice ID: $invoiceId\n' + summaryBase;
      history.insert(0, full);
      if (history.length > 50) history.removeLast();
      await saveHistory();
    } catch (_) {
      // fallback to timestamp id if prefs fail
      final invoiceId =
          'CF-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
      lastInvoiceId = invoiceId;
      final full = 'Invoice ID: $invoiceId\n' + summaryBase;
      history.insert(0, full);
      if (history.length > 50) history.removeLast();
      await saveHistory();
    }
  }

  void clearData() {
    nameController.clear();
    classController.clear();
    batchController.clear();
    sessionController.clear();
    amountController.text = '0';
    advanceController.text = '0';
    dueController.text = '0';
    noticeController.clear();
    for (var c in additionalControllers) c.clear();
    for (var c in additionalLabelControllers) c.clear();
    totalBill = 0.0;
    selectedMonth = months[DateTime.now().month - 1];
    selectedYear = DateTime.now().year.toString();
    selectedDate = null;
    dateController.text = '';
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
        // set lastInvoiceId from first entry if present
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
}
