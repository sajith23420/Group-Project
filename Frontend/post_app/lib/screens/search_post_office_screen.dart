

 import 'package:flutter/material.dart';
import 'colombo_post_office_details.dart';  // Import the new details screen

class SearchPostOfficeScreen extends StatefulWidget {
  const SearchPostOfficeScreen({super.key});

  @override
  State<SearchPostOfficeScreen> createState() => _SearchPostOfficeScreenState();
}

class _SearchPostOfficeScreenState extends State<SearchPostOfficeScreen> {
  // Placeholder data (REPLACE WITH YOUR REAL DATA!)
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
    'Hambantota Post Office'
  ];

  List<String> displayedPostOffices = [];

  @override
  void initState() {
    super.initState();
    displayedPostOffices = List.from(allPostOffices); // Initialize displayed list with all data
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
        title: const Text('Search Nearby Post Office'),
        backgroundColor: Colors.blue[700], // Darker blue for the AppBar
        foregroundColor: Colors.white, // White text on the AppBar
      ),
      backgroundColor: Colors.blue[50], // Very light blue background
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.blueGrey),
              decoration: InputDecoration(
                labelText: 'Search Post Office',
                labelStyle: TextStyle(color: Colors.blue[400]),
                prefixIcon: Icon(Icons.search, color: Colors.blue[400]),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder( // When the TextField is focused
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2.0),
                ),
              ),
              onChanged: _filterPostOffices, // Calls _filterPostOffices when text changes
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: displayedPostOffices.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,  // White cards for contrast
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,  // Slight shadow for visual appeal
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners for the card
                  ),
                  child: ListTile( // Using listtile
                    leading: Icon(Icons.local_post_office, color: Colors.blue[500]), // Blue icon
                    title: Text(
                      displayedPostOffices[index],
                      style: const TextStyle(fontSize: 16.0, color: Colors.blueGrey), // Dark blue-grey text
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[400]), // Lighter blue arrow
                    onTap: () {
                      // Navigate to the Colombo Post Office Details screen ONLY if it's Colombo Post Office
                      if (displayedPostOffices[index] == 'Colombo Central Post Office') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ColomboPostOfficeDetails(),
                          ),
                        );
                      } else { // Show message for non colombo branches.
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Details not Available: ${displayedPostOffices[index]} details', style: const TextStyle(color: Colors.white),),
                            backgroundColor: Colors.blue[600],
                          ),
                        );
                      }
                    }
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