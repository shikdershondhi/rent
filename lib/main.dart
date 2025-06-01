import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const HomeScreen({super.key});

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

  // Initialize with the current month and year
  String _selectedMonth = DateTime.now().month.toString(); // Default value
  String _selectedYear = DateTime.now().year.toString(); // Default value
  double _totalBill = 0.0;
  final List<TextEditingController> _additionalControllers = [];
  final List<TextEditingController> _additionalLabelControllers = [];

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

  final List<String> _years = List.generate(10, (index) => (DateTime.now().year - 5 + index).toString());

  @override
  void initState() {
    super.initState();
    // Set the current month and year
    final DateTime now = DateTime.now();
    _selectedMonth = _months[now.month - 1]; // Months are 1-indexed in DateTime
    _selectedYear = now.year.toString();
  }

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
          // Function to format the preview data as a string
          String formatPreviewData() {
            return '''
Name: ${_nameController.text}
Address: ${_addressController.text}
Phone: ${_phoneController.text}
Year: $_selectedYear
Month: $_selectedMonth
Rent: ${_rentController.text}
Advance Rent: ${_advanceRentController.text}
Due Rent: ${_dueRentController.text}
GAS: ${_gasController.text}
Electricity Bill: ${_electricityController.text}
Service Charge: ${_serviceChargeController.text}
Utility Bill: ${_utilityBillController.text}
${_additionalControllers.asMap().entries.map((entry) => '${_additionalLabelControllers[entry.key].text}: ${entry.value.text}').join('\n')}
Notice: ${_noticeController.text}
Total Bill: $_totalBill
''';
          }

          return AlertDialog(
            title: const Text(
              'Invoice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            content: SingleChildScrollView(
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${_nameController.text}'),
                      Text('Address: ${_addressController.text}'),
                      Text('Phone: ${_phoneController.text}'),
                      const SizedBox(height: 16),
                      const Text(
                        'Invoice Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Year: $_selectedYear'),
                      Text('Month: $_selectedMonth'),
                      Text('Rent: ${_rentController.text}'),
                      Text('Advance Rent: ${_advanceRentController.text}'),
                      Text('Due Rent: ${_dueRentController.text}'),
                      Text('GAS: ${_gasController.text}'),
                      Text('Electricity Bill: ${_electricityController.text}'),
                      Text('Service Charge: ${_serviceChargeController.text}'),
                      Text('Utility Bill: ${_utilityBillController.text}'),
                      for (int i = 0; i < _additionalControllers.length; i++)
                        Text('${_additionalLabelControllers[i].text}: ${_additionalControllers[i].text}'),
                      const SizedBox(height: 16),
                      Text(
                        'Notice: ${_noticeController.text}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Total Bill: $_totalBill',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Copy button
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: formatPreviewData())); // Copy data to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data copied to clipboard!')),
                  );
                },
                child: const Text('Copy'),
              ),
              // Share button
              TextButton(
                onPressed: () async {
                  try {
                    await FlutterShare.share(
                      title: 'Invoice', // Title of the shared content
                      text: formatPreviewData(), // Text to share
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to share: $e')),
                    );
                  }
                },
                child: const Text('Share'),
              ),
              // Close button
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
    for (var controller in _additionalLabelControllers) {
      controller.clear();
    }
    setState(() {
      _totalBill = 0.0;
      _selectedMonth = 'January';
      _selectedYear = DateTime.now().year.toString();
    });
  }

  void _addAdditionalField() {
    setState(() {
      _additionalControllers.add(TextEditingController());
      _additionalLabelControllers.add(TextEditingController());
    });
  }

  void _removeAdditionalField(int index) {
    setState(() {
      _additionalControllers.removeAt(index);
      _additionalLabelControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent and Bill Calculator'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
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
              title: const Text('Settings'),
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
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Small screen: Use Column
                      return Column(
                        children: [
                          // Year Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                            ),
                            items: _years.map((String year) {
                              return DropdownMenuItem<String>(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedYear = newValue!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Month Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a month';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Rent of Month TextField
                          TextFormField(
                            controller: _rentController,
                            decoration: const InputDecoration(
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
                        ],
                      );
                    } else {
                      // Large screen: Use Row
                      return Row(
                        children: [
                          // Year Dropdown
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedYear,
                              decoration: const InputDecoration(
                                labelText: 'Year',
                                border: OutlineInputBorder(),
                              ),
                              items: _years.map((String year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedYear = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a year';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Month Dropdown
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedMonth,
                              decoration: const InputDecoration(
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a month';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Rent of Month TextField
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _rentController,
                              decoration: const InputDecoration(
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
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _advanceRentController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dueRentController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gasController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _electricityController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serviceChargeController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _utilityBillController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                for (int i = 0; i < _additionalControllers.length; i++)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _additionalLabelControllers[i],
                              decoration: const InputDecoration(
                                labelText: 'Field Label',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a label';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _additionalControllers[i],
                              decoration: const InputDecoration(
                                labelText: 'Value',
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeAdditionalField(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _addAdditionalField,
                  child: const Text('Add Additional Field'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noticeController,
                  decoration: const InputDecoration(
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
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Total Bill: $_totalBill',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _calculateTotalBill,
                      child: const Text('Calculate Bill'),
                    ),
                    ElevatedButton(
                      onPressed: _previewData,
                      child: const Text('Preview'),
                    ),
                    ElevatedButton(
                      onPressed: _clearData,
                      child: const Text('Clear',
                        style: TextStyle(
                            color: Colors.red
                        ),
                      ),
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