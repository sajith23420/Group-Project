import 'package:flutter/material.dart';

class BillPaymentsScreen extends StatefulWidget {
  const BillPaymentsScreen({super.key});

  @override
  State<BillPaymentsScreen> createState() => _BillPaymentsScreenState();
}

class _BillPaymentsScreenState extends State<BillPaymentsScreen> {
  String? _selectedBillType;
  String? _selectedPaymentMethod;
  bool _saveForFuture = false;
  bool _sendNotification = true;

  final List<String> _billTypes = [
    'Electricity Bill',
    'Water Bill',
    'Phone Bill (Mobile)',
    'Phone Bill (Landline)',
    'Internet Bill',
    'Gas Bill',
    'Cable TV',
    'Insurance',
    'Credit Card',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Digital Wallet',
    'Online Banking',
  ];

  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bill Payments'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Bill Type Selection
              _buildSectionCard(
                title: 'Bill Information',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: _getInputDecoration('Bill Type', Icons.receipt),
                      value: _selectedBillType,
                      items: _billTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBillType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a bill type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: _getInputDecoration('Customer Name', Icons.person),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16.0),

              // Bill Details
              _buildSectionCard(
                title: 'Bill Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: _getInputDecoration('Account Number / Bill ID', Icons.confirmation_number),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter account number or bill ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _amountController,
                      decoration: _getInputDecoration('Amount (LKR)', Icons.attach_money)
                          .copyWith(prefixText: 'LKR '),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        double? amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _getInputDecoration('Description (Optional)', Icons.description),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Payment Method
              _buildSectionCard(
                title: 'Payment Method',
                child: DropdownButtonFormField<String>(
                  decoration: _getInputDecoration('Select Payment Method', Icons.payment),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16.0),

              // Additional Options
              _buildSectionCard(
                title: 'Additional Options',
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Save this biller for future payments'),
                      subtitle: const Text('Quick access for next time'),
                      value: _saveForFuture,
                      onChanged: (bool? value) {
                        setState(() {
                          _saveForFuture = value ?? false;
                        });
                      },
                      activeColor: Colors.blue.shade600,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Send payment confirmation'),
                      subtitle: const Text('Receive SMS/Email notification'),
                      value: _sendNotification,
                      onChanged: (bool? value) {
                        setState(() {
                          _sendNotification = value ?? true;
                        });
                      },
                      activeColor: Colors.blue.shade600,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // Payment Summary Card
              if (_amountController.text.isNotEmpty && _selectedBillType != null)
                _buildSectionCard(
                  title: 'Payment Summary',
                  child: Column(
                    children: [
                      _buildSummaryRow('Bill Type', _selectedBillType ?? ''),
                      _buildSummaryRow('Amount', 'LKR ${_amountController.text}'),
                      _buildSummaryRow('Payment Method', _selectedPaymentMethod ?? 'Not selected'),
                      if (_customerNameController.text.isNotEmpty)
                        _buildSummaryRow('Customer', _customerNameController.text),
                      const Divider(),
                      _buildSummaryRow('Service Fee', 'LKR 5.00', isSmall: true),
                      _buildSummaryRow(
                        'Total Amount', 
                        'LKR ${(double.tryParse(_amountController.text) ?? 0) + 5.0}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24.0),

              // Pay Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  elevation: 4,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _showPaymentConfirmation();
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pay Bill',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.blue.shade600),
      prefixIcon: Icon(icon, color: Colors.blue.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.blue.shade50,
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 8),
              const Text('Confirm Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to pay this bill?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Bill Type', _selectedBillType ?? ''),
                    _buildSummaryRow('Amount', 'LKR ${_amountController.text}'),
                    _buildSummaryRow('Total', 'LKR ${(double.tryParse(_amountController.text) ?? 0) + 5.0}', isBold: true),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment();
              },
              child: const Text('Confirm & Pay'),
            ),
          ],
        );
      },
    );
  }

  void _processPayment() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Payment processed successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Here you would typically:
    // - Process the actual payment
    // - Send to backend API
    // - Handle success/error responses
    // - Navigate to receipt/confirmation screen
  }
}