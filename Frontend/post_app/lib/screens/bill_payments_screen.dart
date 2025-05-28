import 'package:flutter/material.dart';

class BillPaymentsScreen extends StatefulWidget {
  const BillPaymentsScreen({super.key});

  @override
  State<BillPaymentsScreen> createState() => _BillPaymentsScreenState();
}

class _BillPaymentsScreenState extends State<BillPaymentsScreen>
    with SingleTickerProviderStateMixin {
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bill Payments', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 245, 160, 13),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                          child: Text(type, style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBillType = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a bill type' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: _getInputDecoration('Customer Name', Icons.person),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please enter customer name'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              _buildSectionCard(
                title: 'Bill Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: _getInputDecoration('Account Number / Bill ID', Icons.confirmation_number),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please enter account number or bill ID'
                          : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _amountController,
                      decoration: _getInputDecoration('Amount (LKR)', Icons.attach_money)
                          .copyWith(prefixText: 'LKR '),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter amount';
                        double? amount = double.tryParse(value);
                        return (amount == null || amount <= 0)
                            ? 'Please enter a valid amount'
                            : null;
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
              _buildSectionCard(
                title: 'Payment Method',
                child: DropdownButtonFormField<String>(
                  decoration: _getInputDecoration('Select Payment Method', Icons.payment),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a payment method' : null,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildSectionCard(
                title: 'Additional Options',
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Save this biller for future payments', style: TextStyle(color: Colors.black)),
                      subtitle: const Text('Quick access for next time', style: TextStyle(color: Colors.black)),
                      value: _saveForFuture,
                      onChanged: (bool? value) {
                        setState(() {
                          _saveForFuture = value ?? false;
                        });
                      },
                      activeColor: Colors.orange,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Send payment confirmation', style: TextStyle(color: Colors.black)),
                      subtitle: const Text('Receive SMS/Email notification', style: TextStyle(color: Colors.black)),
                      value: _sendNotification,
                      onChanged: (bool? value) {
                        setState(() {
                          _sendNotification = value ?? true;
                        });
                      },
                      activeColor: Colors.orange,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
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

              GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) {
                  _animationController.reverse();
                  if (_formKey.currentState!.validate()) {
                    _showPaymentConfirmation();
                  }
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 20, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Pay Bill',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
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
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
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
              const Text('Confirm Payment', style: TextStyle(color: Colors.black)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to pay this bill?', style: TextStyle(color: Colors.black)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Bill Type', _selectedBillType ?? ''),
                    _buildSummaryRow('Amount', 'LKR ${_amountController.text}'),
                    _buildSummaryRow(
                      'Total',
                      'LKR ${(double.tryParse(_amountController.text) ?? 0) + 5.0}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.black),
            SizedBox(width: 8),
            Text('Payment processed successfully!', style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.orange.shade100,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
