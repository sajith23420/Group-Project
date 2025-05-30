import 'package:flutter/material.dart';
import 'colombo_post_office_details.dart'; // Make sure this path is correct
import 'kandy_post_office_details.dart'; // Make sure this path is correct

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
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      backgroundColor: const Color(0xFFF4F8FB),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search Post Office',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
                onChanged: _filterPostOffices,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedPostOffices.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.local_post_office,
                          color: Colors.teal, size: 28),
                    ),
                    title: Text(
                      displayedPostOffices[index],
                      style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.arrow_forward_ios,
                          color: Colors.teal, size: 18),
                    ),
                    onTap: () {
                      if (displayedPostOffices[index] ==
                          'Colombo Central Post Office') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ColomboPostOfficeDetails()),
                        );
                      } else if (displayedPostOffices[index] ==
                          'Kandy General Post Office') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const KandyPostOfficeDetails()),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Post Office Details'),
                            content: Text(
                                'Details for ${displayedPostOffices[index]} coming soon!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
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
