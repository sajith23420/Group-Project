

 import 'package:flutter/material.dart';
import 'colombo_post_office_details.dart'; // Make sure this path is correct

class SearchPostOfficeScreen extends StatefulWidget {
  const SearchPostOfficeScreen({super.key});

  @override
  State<SearchPostOfficeScreen> createState() => _SearchPostOfficeScreenState();
}

class _SearchPostOfficeScreenState extends State<SearchPostOfficeScreen> {
  final List<String> allPostOffices = [
    'Colombo Central Post Office',
    'Kandy General Post Office',
    'Galle Post Office',
    'Jaffna Post Office',
    'Anuradhapura Post Office',
    'Kurunegala Post Office',
    'Matara Post Office',
    'Badulla Post Office',
    'Ratnapura Post Office',
    'Negombo Post Office',
    'Kalutara Post Office',
    'Hambantota Post Office',
  ];

  List<String> displayedPostOffices = [];

  @override
  void initState() {
    super.initState();
    displayedPostOffices = List.from(allPostOffices);
  }

  void _filterPostOffices(String query) {
    setState(() {
      displayedPostOffices = allPostOffices
          .where((postOffice) =>
              postOffice.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Nearby Post Office',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 249, 253, 249),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Search Post Office',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              onChanged: _filterPostOffices,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedPostOffices.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.local_post_office, color: Colors.black),
                    title: Text(
                      displayedPostOffices[index],
                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      if (displayedPostOffices[index] == 'Colombo Central Post Office') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ColomboPostOfficeDetails()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tapped: ${displayedPostOffices[index]} details',
                              style: const TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.grey[300],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
