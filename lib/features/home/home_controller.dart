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
      double total = (double.tryParse(rentController.text) ?? 0) +
          (double.tryParse(dueRentController.text) ?? 0) +
          (double.tryParse(gasController.text) ?? 0) +
          (double.tryParse(electricityController.text) ?? 0) +
          (double.tryParse(serviceChargeController.text) ?? 0) +
          (double.tryParse(utilityBillController.text) ?? 0);
      total -= (double.tryParse(advanceRentController.text) ?? 0);
      for (var controller in additionalControllers) {
        if (controller.text.isNotEmpty) {
          total += (double.tryParse(controller.text) ?? 0);
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
      }
      await loadDraft();
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
    clearDraft();
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
  static const String _draftKey = 'rent_draft_v1';

  Future<void> saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_draftKey}_name', nameController.text);
      await prefs.setString('${_draftKey}_address', addressController.text);
      await prefs.setString('${_draftKey}_phone', phoneController.text);
      await prefs.setString('${_draftKey}_rent', rentController.text);
      await prefs.setString('${_draftKey}_advance', advanceRentController.text);
      await prefs.setString('${_draftKey}_due', dueRentController.text);
      await prefs.setString('${_draftKey}_gas', gasController.text);
      await prefs.setString('${_draftKey}_electricity', electricityController.text);
      await prefs.setString('${_draftKey}_serviceCharge', serviceChargeController.text);
      await prefs.setString('${_draftKey}_utility', utilityBillController.text);
      await prefs.setString('${_draftKey}_notice', noticeController.text);
      await prefs.setString('${_draftKey}_month', selectedMonth);
      await prefs.setString('${_draftKey}_year', selectedYear);

      // Save dynamic fields count and values
      await prefs.setInt('${_draftKey}_additional_count', additionalControllers.length);
      for (int i = 0; i < additionalControllers.length; i++) {
        await prefs.setString('${_draftKey}_additional_label_$i', additionalLabelControllers[i].text);
        await prefs.setString('${_draftKey}_additional_value_$i', additionalControllers[i].text);
      }
    } catch (_) {}
  }

  Future<void> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('${_draftKey}_name') || prefs.containsKey('${_draftKey}_rent')) {
        nameController.text = prefs.getString('${_draftKey}_name') ?? '';
        addressController.text = prefs.getString('${_draftKey}_address') ?? '';
        phoneController.text = prefs.getString('${_draftKey}_phone') ?? '';
        rentController.text = prefs.getString('${_draftKey}_rent') ?? '0';
        advanceRentController.text = prefs.getString('${_draftKey}_advance') ?? '0';
        dueRentController.text = prefs.getString('${_draftKey}_due') ?? '0';
        gasController.text = prefs.getString('${_draftKey}_gas') ?? '0';
        electricityController.text = prefs.getString('${_draftKey}_electricity') ?? '0';
        serviceChargeController.text = prefs.getString('${_draftKey}_serviceCharge') ?? '0';
        utilityBillController.text = prefs.getString('${_draftKey}_utility') ?? '0';
        noticeController.text = prefs.getString('${_draftKey}_notice') ?? '';
        selectedMonth = prefs.getString('${_draftKey}_month') ?? months[DateTime.now().month - 1];
        selectedYear = prefs.getString('${_draftKey}_year') ?? DateTime.now().year.toString();

        // Restore dynamic fields
        final count = prefs.getInt('${_draftKey}_additional_count') ?? 0;
        additionalControllers.clear();
        additionalLabelControllers.clear();
        for (int i = 0; i < count; i++) {
          final label = prefs.getString('${_draftKey}_additional_label_$i') ?? '';
          final value = prefs.getString('${_draftKey}_additional_value_$i') ?? '';
          additionalControllers.add(TextEditingController(text: value));
          additionalLabelControllers.add(TextEditingController(text: label));
        }

        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_draftKey}_name');
      await prefs.remove('${_draftKey}_address');
      await prefs.remove('${_draftKey}_phone');
      await prefs.remove('${_draftKey}_rent');
      await prefs.remove('${_draftKey}_advance');
      await prefs.remove('${_draftKey}_due');
      await prefs.remove('${_draftKey}_gas');
      await prefs.remove('${_draftKey}_electricity');
      await prefs.remove('${_draftKey}_serviceCharge');
      await prefs.remove('${_draftKey}_utility');
      await prefs.remove('${_draftKey}_notice');
      await prefs.remove('${_draftKey}_month');
      await prefs.remove('${_draftKey}_year');

      final count = prefs.getInt('${_draftKey}_additional_count') ?? 0;
      await prefs.remove('${_draftKey}_additional_count');
      for (int i = 0; i < count; i++) {
        await prefs.remove('${_draftKey}_additional_label_$i');
        await prefs.remove('${_draftKey}_additional_value_$i');
      }
    } catch (_) {}
  }
}
