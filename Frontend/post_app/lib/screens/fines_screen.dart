import 'package:flutter/material.dart';

class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  final TextEditingController _refController = TextEditingController();
  bool _showSummary = false;
  String? _offense = 'Speeding';
  String? _amount; // Now editable by user
  String? _dueDate = '2025-06-15';
  String? _status = 'Pending';
  String? _selectedPayment;

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'label': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    {
      'label': 'GovPay',
      'icon': Icons.account_balance_wallet,
    },
    {
      'label': 'Pay at Post Office',
      'icon': Icons.local_post_office,
    },
  ];

  void _scanQRCode() {
    // Implement QR code scanning logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code scanning not implemented.')),
    );
  }

  void _checkFineDetails() {
    // Simulate fetching fine details (offense, dueDate, status), but do not set amount
    setState(() {
      _showSummary = true;
      _offense = 'Speeding';
      _dueDate = '2025-06-15';
      _status = 'Pending';
      // _amount is not set here; user will type it
    });
  }

  void _proceedToPay() {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }
    if (_amount == null || _amount!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the fine amount.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
            'Your payment of LKR $_amount for $_offense has been received via $_selectedPayment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Pay Traffic Fines',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: 'FAQ',
            onPressed: () {
              // Show FAQ or help
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('FAQ'),
                  content: const Text(
                      'For questions about paying fines, please visit the Sri Lanka Post website or contact your nearest post office.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 1: Enter Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.redAccent)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _refController,
                            decoration: const InputDecoration(
                              labelText: 'Fine Reference Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: Colors.redAccent, size: 30),
                          onPressed: _scanQRCode,
                          tooltip: 'Scan QR Code',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Check Fine Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _checkFineDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Card 2: Fine Summary
            if (_showSummary)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fine Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.redAccent)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.gavel, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          const Text('Offense:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Text(_offense ?? '',
                              style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              color: Colors.redAccent),
                          const SizedBox(width: 10),
                          const Text('Fine Amount:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter amount (LKR)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                              ),
                              onChanged: (val) => setState(() => _amount = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.redAccent),
                          const SizedBox(width: 10),
                          const Text('Due Date:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Text(_dueDate ?? '',
                              style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                              _status == 'Pending'
                                  ? Icons.hourglass_bottom
                                  : Icons.warning,
                              color: _status == 'Pending'
                                  ? Colors.orange
                                  : Colors.red),
                          const SizedBox(width: 10),
                          const Text('Status:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Text(_status ?? '',
                              style: TextStyle(
                                  color: _status == 'Pending'
                                      ? Colors.orange
                                      : Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_showSummary) const SizedBox(height: 22),
            // Card 3: Payment Method
            if (_showSummary)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.redAccent)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _paymentOptions.map((option) {
                          final selected = _selectedPayment == option['label'];
                          return GestureDetector(
                            onTap: () {
                              setState(
                                  () => _selectedPayment = option['label']);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    selected ? Colors.redAccent : Colors.white,
                                border: Border.all(
                                    color: selected
                                        ? Colors.redAccent
                                        : Colors.grey.shade300,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(option['icon'],
                                      color: selected
                                          ? Colors.white
                                          : Colors.redAccent,
                                      size: 28),
                                  const SizedBox(height: 6),
                                  Text(option['label'],
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            if (_showSummary) const SizedBox(height: 30),
            // Proceed to Pay Button
            if (_showSummary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Proceed to Pay'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
