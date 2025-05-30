import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class KandyPostOfficeDetails extends StatelessWidget {
  const KandyPostOfficeDetails({super.key});

  final List<Map<String, dynamic>> postOffices = const [
    {
      'name': 'Kandy General Post Office',
      'address': 'No. 1, Post Office Lane, Kandy 20000',
      'phone': '+94 81 2 222222',
      'hours': '8:00 AM - 6:00 PM',
      'services': [
        'Postal services',
        'Parcel services',
        'Money orders',
        'Registered mail',
        'Express mail',
        'Philately',
      ],
    },
    {
      'name': 'Kandy City Centre Post Office',
      'address': 'KCC, Dalada Veediya, Kandy 20000',
      'phone': '+94 81 2 333444',
      'hours': '8:30 AM - 5:00 PM',
      'services': [
        'Postal services',
        'Parcel services',
        'Money orders',
      ],
    },
    {
      'name': 'Peradeniya Post Office',
      'address': 'Peradeniya Road, Kandy 20400',
      'phone': '+94 81 2 555666',
      'hours': '8:00 AM - 4:30 PM',
      'services': [
        'Postal services',
        'Registered mail',
        'Express mail',
      ],
    },
    {
      'name': 'Katugastota Post Office',
      'address': 'Katugastota, Kandy 20800',
      'phone': '+94 81 2 777888',
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
        title: const Text('Kandy Post Offices'),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: const Color.fromARGB(255, 9, 5, 5),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 246, 245),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(7.2906, 80.6337),
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(7.2906, 80.6337),
                          child: const Icon(Icons.location_on,
                              color: Colors.deepPurple, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
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
                              color: Color.fromARGB(255, 44, 20, 80),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Address: ${office['address']}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 38, 41, 38)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Phone: ${office['phone']}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 25, 27, 25)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hours: ${office['hours']}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 20, 23, 20)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Services:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                          Text(
                            '- ${office['services'].join('\n- ')}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 16, 21, 16)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
