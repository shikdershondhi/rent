import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent and Bill Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _advanceRentController = TextEditingController();
  final TextEditingController _dueRentController = TextEditingController();
  final TextEditingController _gasController = TextEditingController();
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _serviceChargeController = TextEditingController();
  final TextEditingController _utilityBillController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();

  String _selectedMonth = 'January';
  double _totalBill = 0.0;
  List<TextEditingController> _additionalControllers = [];
  List<String> _additionalLabels = [];

  final List<String> _months = [
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

  void _calculateTotalBill() {
    if (_formKey.currentState!.validate()) {
      double total = double.parse(_rentController.text) +
          double.parse(_advanceRentController.text) +
          double.parse(_dueRentController.text) +
          double.parse(_gasController.text) +
          double.parse(_electricityController.text) +
          double.parse(_serviceChargeController.text) +
          double.parse(_utilityBillController.text);

      for (var controller in _additionalControllers) {
        if (controller.text.isNotEmpty) {
          total += double.parse(controller.text);
        }
      }

      setState(() {
        _totalBill = total;
      });
    }
  }

  void _previewData() {
    if (_formKey.currentState!.validate()) {
      _calculateTotalBill();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Preview Data'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_nameController.text}'),
                  Text('Address: ${_addressController.text}'),
                  Text('Phone: ${_phoneController.text}'),
                  Text('Month: $_selectedMonth'),
                  Text('Rent: ${_rentController.text}'),
                  Text('Advance Rent: ${_advanceRentController.text}'),
                  Text('Due Rent: ${_dueRentController.text}'),
                  Text('GAS: ${_gasController.text}'),
                  Text('Electricity Bill: ${_electricityController.text}'),
                  Text('Service Charge: ${_serviceChargeController.text}'),
                  Text('Utility Bill: ${_utilityBillController.text}'),
                  for (int i = 0; i < _additionalControllers.length; i++)
                    Text('${_additionalLabels[i]}: ${_additionalControllers[i].text}'),
                  Text('Notice: ${_noticeController.text}'),
                  SizedBox(height: 16),
                  Text(
                    'Total Bill: $_totalBill',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  void _downloadPdf() async {
    if (_formKey.currentState!.validate()) {
      _calculateTotalBill();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('House Rent Info', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Name: ${_nameController.text}'),
                pw.Text('Address: ${_addressController.text}'),
                pw.Text('Phone: ${_phoneController.text}'),
                pw.Text('Month: $_selectedMonth'),
                pw.Text('Rent: ${_rentController.text}'),
                pw.Text('Advance Rent: ${_advanceRentController.text}'),
                pw.Text('Due Rent: ${_dueRentController.text}'),
                pw.Text('GAS: ${_gasController.text}'),
                pw.Text('Electricity Bill: ${_electricityController.text}'),
                pw.Text('Service Charge: ${_serviceChargeController.text}'),
                pw.Text('Utility Bill: ${_utilityBillController.text}'),
                for (int i = 0; i < _additionalControllers.length; i++)
                  pw.Text('${_additionalLabels[i]}: ${_additionalControllers[i].text}'),
                pw.Text('Notice: ${_noticeController.text}'),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Total Bill: $_totalBill',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/rent/house_rent_info.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
      OpenFile.open(file.path);
    }
  }

  void _clearData() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _rentController.clear();
    _advanceRentController.clear();
    _dueRentController.clear();
    _gasController.clear();
    _electricityController.clear();
    _serviceChargeController.clear();
    _utilityBillController.clear();
    _noticeController.clear();
    for (var controller in _additionalControllers) {
      controller.clear();
    }
    setState(() {
      _totalBill = 0.0;
      _selectedMonth = 'January';
    });
  }

  void _addAdditionalField() {
    setState(() {
      _additionalControllers.add(TextEditingController());
      _additionalLabels.add('Additional Field ${_additionalControllers.length}');
    });
  }

  void _removeAdditionalField(int index) {
    setState(() {
      _additionalControllers.removeAt(index);
      _additionalLabels.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent and Bill Calculator'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Only alphabets are allowed';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: _months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMonth = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _rentController,
                        decoration: InputDecoration(
                          labelText: 'Rent of Month',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the rent';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _advanceRentController,
                  decoration: InputDecoration(
                    labelText: 'Advance Rent of Month',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the advance rent';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dueRentController,
                  decoration: InputDecoration(
                    labelText: 'Due Rent of Month',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the due rent';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _gasController,
                  decoration: InputDecoration(
                    labelText: 'GAS',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the GAS bill';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _electricityController,
                  decoration: InputDecoration(
                    labelText: 'Electricity Bill',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the electricity bill';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _serviceChargeController,
                  decoration: InputDecoration(
                    labelText: 'Service Charge',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the service charge';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _utilityBillController,
                  decoration: InputDecoration(
                    labelText: 'Utility Bill',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the utility bill';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                for (int i = 0; i < _additionalControllers.length; i++)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _additionalControllers[i],
                              decoration: InputDecoration(
                                labelText: _additionalLabels[i],
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeAdditionalField(i),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _addAdditionalField,
                  child: Text('Add Additional Field'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _noticeController,
                  decoration: InputDecoration(
                    labelText: 'Notice',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 256,
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.length > 256) {
                      return 'Notice cannot exceed 256 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'Total Bill: $_totalBill',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _calculateTotalBill,
                      child: Text('Calculate Bill'),
                    ),
                    // ElevatedButton(
                    //   onPressed: _printData,
                    //   child: Text('Print'),
                    // ),
                    ElevatedButton(
                      onPressed: _previewData,
                      child: Text('Preview'),
                    ),
                    ElevatedButton(
                      onPressed: _downloadPdf,
                      child: Text('Download PDF'),
                    ),
                    ElevatedButton(
                      onPressed: _clearData,
                      child: Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}