import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ColomboPostOfficeDetails extends StatelessWidget {
  const ColomboPostOfficeDetails({super.key});

  final List<Map<String, dynamic>> postOffices = const [
    {
      'name': 'Colombo Central Post Office',
      'address': 'Janadhipathi Mawatha, Colombo 00100',
      'phone': '+94 11 2 326303',
      'hours': 'Open 24 hours',
      'services': [
        'Postal services',
        'Parcel services',
        'Money orders',
        'Express mail',
      ],
    },
    {
      'name': 'Colombo Fort Post Office',
      'address': 'York Street, Colombo 00100',
      'phone': '+94 11 2 323456',
      'hours': '8:00 AM - 6:00 PM',
      'services': [
        'Postal services',
        'Registered mail',
        'Philately',
      ],
    },
    {
      'name': 'Colombo 07 Post Office',
      'address': 'Wijerama Mawatha, Colombo 00700',
      'phone': '+94 11 2 334455',
      'hours': '8:30 AM - 5:00 PM',
      'services': [
        'Postal services',
        'Parcel services',
        'Money orders',
      ],
    },
    {
      'name': 'Colombo 05 Post Office',
      'address': 'Havelock Road, Colombo 00500',
      'phone': '+94 11 2 345678',
      'hours': '8:00 AM - 5:00 PM',
      'services': [
        'Postal services',
        'Express mail',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colombo Post Offices'),
        backgroundColor: Colors.orange[100],
        foregroundColor: Colors.black,
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
                    initialCenter: LatLng(6.9271, 79.8612), // Colombo
                    initialZoom: 13.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(6.9271, 79.8612),
                          child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                              color: Color.fromARGB(255, 80, 44, 20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Address: ${office['address']}',
                            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 38, 41, 38)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Phone: ${office['phone']}',
                            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 25, 27, 25)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hours: ${office['hours']}',
                            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 20, 23, 20)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Services:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          Text(
                            '- ${office['services'].join('\n- ')}',
                            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 16, 21, 16)),
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
