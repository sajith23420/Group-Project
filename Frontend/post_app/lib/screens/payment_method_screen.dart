import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example card data (replace with real data in production)
    final List<Map<String, String>> cards = [
      {
        'type': 'Visa',
        'number': '**** 1234',
        'expiry': '12/27',
        'color': '0xFFe3e3e3',
        'logo': 'assets/images/visa.png',
      },
      {
        'type': 'Mastercard',
        'number': '**** 5678',
        'expiry': '09/26',
        'color': '0xFFe3e3e3',
        'logo': 'assets/images/mastercard.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pinkAccent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: cards.length,
                separatorBuilder: (context, i) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.pinkAccent.withOpacity(0.08),
                        radius: 26,
                        child: card['logo'] != null
                            ? Image.asset(
                                card['logo']!,
                                width: 32,
                                height: 32,
                                errorBuilder: (c, e, s) => const Icon(
                                    Icons.credit_card,
                                    color: Colors.pinkAccent,
                                    size: 28),
                              )
                            : const Icon(Icons.credit_card,
                                color: Colors.pinkAccent, size: 28),
                      ),
                      title: Text(
                        card['type'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            card['number'] ?? '',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Exp: ${card['expiry']}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black38),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.pinkAccent),
                        onPressed: () {
                          // TODO: Implement delete functionality
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Colors.pinkAccent),
                label: const Text('Add New Card',
                    style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.pinkAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _AddCardDialog(),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _holderController,
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    prefixIcon:
                        const Icon(Icons.person, color: Colors.pinkAccent),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter cardholder name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    prefixIcon:
                        const Icon(Icons.credit_card, color: Colors.pinkAccent),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter card number';
                    if (value.length != 16)
                      return 'Card number must be 16 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: InputDecoration(
                          labelText: 'Expiry (MM/YY)',
                          prefixIcon: const Icon(Icons.date_range,
                              color: Colors.pinkAccent),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter expiry';
                          final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                          if (!regex.hasMatch(value)) return 'Invalid format';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.pinkAccent),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter CVV';
                          if (value.length != 3) return 'CVV must be 3 digits';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Save card details
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add Card',
                          style: TextStyle(fontSize: 15)),
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
