import 'package:flutter/material.dart';

class NegomboPostOfficeDetails extends StatelessWidget {
  const NegomboPostOfficeDetails({super.key});

  final List<Map<String, dynamic>> postOffices = const [
    {
      'name': 'Negombo Post Office',
      'address': 'Main Street, Negombo 11500',
      'phone': '+94 31 2 222222',
      'hours': '8:00 AM - 5:00 PM',
      'services': [
        'Postal services',
        'Parcel services',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Negombo Post Offices'),
        backgroundColor: Colors.green[100],
        foregroundColor: const Color.fromARGB(255, 9, 5, 5),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 246, 245),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: postOffices.length,
          itemBuilder: (context, index) {
            final office = postOffices[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 14, 15, 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Address: ${office['address']}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 38, 41, 38)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phone: ${office['phone']}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 25, 27, 25)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hours: ${office['hours']}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 20, 23, 20)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Services:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    Text(
                      '- ${office['services'].join('\n- ')}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 16, 21, 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
