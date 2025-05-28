import 'package:flutter/material.dart';

class PostalHolidayScreen extends StatefulWidget {
  const PostalHolidayScreen({Key? key}) : super(key: key);

  @override
  State<PostalHolidayScreen> createState() => _PostalHolidayScreenState();
}

class _PostalHolidayScreenState extends State<PostalHolidayScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedHoliday;
  String? _name;
  String? _address;
  String? _serviceType;
  String? _notes;

  final List<Map<String, String>> _holidays = [
    {'date': '2025-01-15', 'name': 'Thai Pongal'},
    {'date': '2025-02-04', 'name': 'Independence Day'},
    {'date': '2025-04-13', 'name': 'Sinhala & Tamil New Year'},
    {'date': '2025-05-01', 'name': 'May Day'},
    {'date': '2025-05-23', 'name': 'Vesak Full Moon Poya'},
    {'date': '2025-12-25', 'name': 'Christmas Day'},
  ];

  final List<String> _serviceTypes = [
    'Parcel Delivery',
    'Registered Mail',
    'Money Order',
    'Express Delivery',
    'Other',
  ];

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Text(
              'Your booking for $_selectedHoliday has been received.\nThank you, $_name!\n\nAddress: $_address\nService: $_serviceType\nNotes: ${_notes ?? "-"}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Optionally, send booking to backend here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postal Holiday Booking'),
        backgroundColor: Colors.orange[700],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'In Sri Lanka, the Postal Holiday Booking Service allows you to reserve postal delivery or services in advance for public holidays. Book your service to ensure timely delivery even on holidays.',
                      style: TextStyle(fontSize: 15, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Upcoming Public Holidays',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _holidays.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final h = _holidays[i];
                  return RadioListTile<String>(
                    value: '${h['date']} - ${h['name']}',
                    groupValue: _selectedHoliday,
                    onChanged: (val) {
                      setState(() => _selectedHoliday = val);
                    },
                    title: Text(h['name']!,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(h['date']!),
                    activeColor: Colors.orange[700],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Booking Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter your name' : null,
                    onSaved: (val) => _name = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter your address'
                        : null,
                    onSaved: (val) => _address = val,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_post_office),
                    ),
                    items: _serviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    validator: (val) =>
                        val == null ? 'Select a service type' : null,
                    onChanged: (val) => _serviceType = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_alt),
                    ),
                    maxLines: 2,
                    onSaved: (val) => _notes = val,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          _selectedHoliday == null ? null : _submitBooking,
                      label: const Text('Book Postal Service'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
