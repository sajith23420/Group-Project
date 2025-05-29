import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String senderName;
  final String senderAddress;
  final String recipientName;
  final String recipientAddress;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.senderName,
    required this.senderAddress,
    required this.recipientName,
    required this.recipientAddress,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = ['Credit Card', 'Debit Card', 'Bank Transfer', 'Digital Wallet'];
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // Receiver account details controllers
  final _receiverBankController = TextEditingController();
  final _receiverAccountNumberController = TextEditingController();
  final _receiverAccountHolderController = TextEditingController();
  final _receiverBranchCodeController = TextEditingController();
  final _receiverSwiftCodeController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  final _receiverFormKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  late final String _transactionId = DateTime.now().millisecondsSinceEpoch.toString();

  // List of common banks in Sri Lanka
  final List<String> _sriLankanBanks = [
    'Bank of Ceylon',
    'People\'s Bank',
    'Commercial Bank of Ceylon',
    'Hatton National Bank',
    'Sampath Bank',
    'Nations Trust Bank',
    'DFCC Bank',
    'Union Bank',
    'Pan Asia Banking Corporation',
    'Seylan Bank',
    'Other'
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _receiverBankController.dispose();
    _receiverAccountNumberController.dispose();
    _receiverAccountHolderController.dispose();
    _receiverBranchCodeController.dispose();
    _receiverSwiftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color.fromARGB(255, 106, 240, 135),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Transaction Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildSummaryItem('Sender', widget.senderName),
                    _buildSummaryItem('Sender Address', widget.senderAddress),
                    _buildSummaryItem('Recipient', widget.recipientName),
                    _buildSummaryItem('Recipient Address', widget.recipientAddress),
                    const Divider(thickness: 1),
                    _buildSummaryItem('Amount', 'LKR ${widget.amount.toStringAsFixed(2)}', 
                      valueStyle: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      )
                    ),
                    _buildSummaryItem('Service Fee', 'LKR ${(widget.amount * 0.02).toStringAsFixed(2)}'),
                    const Divider(thickness: 1),
                    _buildSummaryItem('Total', 'LKR ${(widget.amount * 1.02).toStringAsFixed(2)}',
                      valueStyle: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 106, 240, 135)
                      )
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Receiver Account Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _receiverFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance, 
                            color: Color.fromARGB(255, 106, 240, 135)),
                          const SizedBox(width: 8),
                          const Text(
                            'Receiver Account Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Bank Selection Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Bank',
                          labelStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                          ),
                          prefixIcon: const Icon(Icons.business, color: Color.fromARGB(255, 116, 237, 132)),
                        ),
                        items: _sriLankanBanks.map((String bank) {
                          return DropdownMenuItem<String>(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          _receiverBankController.text = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a bank';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12.0),
                      
                      // Account Number Field
                      TextFormField(
                        controller: _receiverAccountNumberController,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          labelStyle: const TextStyle(color: Colors.black54),
                          hintText: 'Enter recipient account number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                          ),
                          prefixIcon: const Icon(Icons.account_balance_wallet, color: Color.fromARGB(255, 116, 237, 132)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          if (value.length < 8) {
                            return 'Account number must be at least 8 digits';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12.0),
                      
                      // Account Holder Name Field
                      TextFormField(
                        controller: _receiverAccountHolderController,
                        decoration: InputDecoration(
                          labelText: 'Account Holder Name',
                          labelStyle: const TextStyle(color: Colors.black54),
                          hintText: 'Enter account holder name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                          ),
                          prefixIcon: const Icon(Icons.person_outline, color: Color.fromARGB(255, 116, 237, 132)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account holder name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12.0),
                      
                      // Branch Code and SWIFT Code in a Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _receiverBranchCodeController,
                              decoration: InputDecoration(
                                labelText: 'Branch Code',
                                labelStyle: const TextStyle(color: Colors.black54),
                                hintText: 'e.g., 001',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: TextFormField(
                              controller: _receiverSwiftCodeController,
                              decoration: InputDecoration(
                                labelText: 'SWIFT Code (Optional)',
                                labelStyle: const TextStyle(color: Colors.black54),
                                hintText: 'e.g., BCEYLKLX',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                                ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12.0),
                      
                      // Information note
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please verify all account details carefully. Incorrect information may result in transfer delays or failures.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Payment Method Selection Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ..._buildPaymentMethodOptions(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Payment Details Card (for Credit/Debit Card)
            if (_selectedPaymentMethod <= 1)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_paymentMethods[_selectedPaymentMethod]} Details',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Card Number Field
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            labelStyle: const TextStyle(color: Colors.black54),
                            hintText: 'XXXX XXXX XXXX XXXX',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                            ),
                            prefixIcon: const Icon(Icons.credit_card, color: Color.fromARGB(255, 116, 237, 132)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter card number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        // Card Holder Name Field
                        TextFormField(
                          controller: _cardHolderController,
                          decoration: InputDecoration(
                            labelText: 'Card Holder Name',
                            labelStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                            ),
                            prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 116, 237, 132)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter card holder name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        // Expiry Date and CVV in a Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryDateController,
                                decoration: InputDecoration(
                                  labelText: 'Expiry Date (MM/YY)',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  hintText: 'MM/YY',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextFormField(
                                controller: _cvvController,
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  hintText: 'XXX',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 116, 237, 132)),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Bank Transfer Instructions
            if (_selectedPaymentMethod == 2)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Transfer Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      const Text('Please transfer the total amount to:'),
                      const SizedBox(height: 8.0),
                      const Text('Bank: Central Bank of Sri Lanka'),
                      const Text('Account Name: Money Order Services Ltd.'),
                      const Text('Account Number: 1234-5678-9012-3456'),
                      const Text('Branch Code: 890123'),
                      Text('Reference: MO-$_transactionId'),
                      const SizedBox(height: 12.0),
                      const Text('Please use your Order Reference as the payment reference.', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            
            // Digital Wallet Options
            if (_selectedPaymentMethod == 3)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Digital Wallet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ListTile(
                        leading: Image.asset('assets/payhere_logo.png', 
                          width: 40, height: 40, 
                          errorBuilder: (context, error, stackTrace) => 
                            Container(width: 40, height: 40, color: Colors.grey[300], 
                              child: const Icon(Icons.wallet, color: Colors.grey))),
                        title: const Text('PayHere'),
                        trailing: Radio<int>(
                          value: 0,
                          groupValue: 0,
                          onChanged: (value) {},
                          activeColor: Color.fromARGB(255, 116, 237, 132),
                        ),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: Icon(Icons.qr_code, size: 40, color: Color.fromARGB(255, 116, 237, 132)),
                        title: Text('Scan QR to Pay'),
                        subtitle: Text('Using any banking app'),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code_2, size: 150, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            const SizedBox(height: 30.0),
            
            // Pay Now Button
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.yellow;
                    }
                    return Color.fromARGB(255, 116, 237, 132);
                  },
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16.0),
                ),
                elevation: WidgetStateProperty.all(4),
              ),
              onPressed: _isProcessing 
                ? null 
                : () {
                    bool isValid = true;
                    
                    // Validate receiver account details
                    if (!_receiverFormKey.currentState!.validate()) {
                      isValid = false;
                    }
                    
                    // Validate payment method specific details
                    if (_selectedPaymentMethod <= 1) {
                      if (!_formKey.currentState!.validate()) {
                        isValid = false;
                      }
                    }
                    
                    if (isValid) {
                      _processPayment();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
              child: _isProcessing 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Processing...', style: TextStyle(fontSize: 16)),
                    ],
                  )
                : const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 12.0),
            
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel Transaction',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            
            const SizedBox(height: 24.0),
            
            // Security Info
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Secured by SSL Encryption', 
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaymentMethodOptions() {
    return List.generate(_paymentMethods.length, (index) {
      IconData icon;
      switch (index) {
        case 0:
          icon = Icons.credit_card;
          break;
        case 1:
          icon = Icons.payment;
          break;
        case 2:
          icon = Icons.account_balance;
          break;
        case 3:
          icon = Icons.account_balance_wallet;
          break;
        default:
          icon = Icons.payment;
      }
      
      return RadioListTile<int>(
        title: Row(
          children: [
            Icon(icon, color: Color.fromARGB(255, 116, 237, 132)),
            const SizedBox(width: 10),
            Text(_paymentMethods[index]),
          ],
        ),
        value: index,
        groupValue: _selectedPaymentMethod,
        activeColor: Colors.pinkAccent,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      );
    });
  }
  
  Widget _buildSummaryItem(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            value,
            style: valueStyle ?? const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
  
  void _processPayment() {
    setState(() {
      _isProcessing = true;
    });
    
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Payment Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Your payment of LKR ${(widget.amount * 1.02).toStringAsFixed(2)} has been processed successfully.',
              ),
              const SizedBox(height: 8),
              const Text(
                'A confirmation has been sent to your email address.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: MO-$_transactionId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Recipient: ${_receiverAccountHolderController.text}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Account: ${_receiverAccountNumberController.text}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
      
      setState(() {
        _isProcessing = false;
      });
    });
  }
}