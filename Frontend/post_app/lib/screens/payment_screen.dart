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
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  late final String _transactionId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.pinkAccent,
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
                        color: Colors.pinkAccent
                      )
                    ),
                  ],
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
                              borderSide: const BorderSide(color: Colors.pinkAccent),
                            ),
                            prefixIcon: const Icon(Icons.credit_card, color: Colors.pinkAccent),
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
                              borderSide: const BorderSide(color: Colors.pinkAccent),
                            ),
                            prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
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
                                    borderSide: const BorderSide(color: Colors.pinkAccent),
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
                                    borderSide: const BorderSide(color: Colors.pinkAccent),
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
                          activeColor: Colors.pinkAccent,
                        ),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: Icon(Icons.qr_code, size: 40, color: Colors.pinkAccent),
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
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey;
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.yellow;
                    }
                    return Colors.pinkAccent;
                  },
                ),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16.0),
                ),
                elevation: MaterialStateProperty.all(4),
              ),
              onPressed: _isProcessing 
                ? null 
                : () {
                    if (_selectedPaymentMethod <= 1) {
                      if (_formKey.currentState!.validate()) {
                        _processPayment();
                      }
                    } else {
                      _processPayment();
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
            Icon(icon, color: Colors.pinkAccent),
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