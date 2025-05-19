import 'package:flutter/material.dart';

class SearchPostOfficeScreen extends StatefulWidget {
  const SearchPostOfficeScreen({super.key});

  @override
  State<SearchPostOfficeScreen> createState() => _SearchPostOfficeScreenState();
}

class _SearchPostOfficeScreenState extends State<SearchPostOfficeScreen> {
  final List<String> _allPostOffices = [
    'Colombo Fort Post Office',
    'Kandy Main Post Office',
    'Galle Head Post Office',
    'Jaffna Post Office',
    'Negombo Post Office',
    'Matara Post Office',
    'Trincomalee Post Office',
    'Anuradhapura Post Office',
    'Kurunegala Post Office',
    'Badulla Post Office',
    'Ratnapura Post Office',
    'Nuwara Eliya Post Office',
    'Batticaloa Post Office',
    'Kalutara Post Office',
    'Gampaha Post Office',
    'Matale Post Office',
    'Hambantota Post Office',
    'Vavuniya Post Office',
    'Mannar Post Office',
    'Kilinochchi Post Office',
    'Ampara Post Office',
    'Polonnaruwa Post Office',
    'Puttalam Post Office',
    'Kegalle Post Office',
    'Monaragala Post Office',
    'Dehiwala Post Office',
    'Moratuwa Post Office',
    'Mount Lavinia Post Office',
    'Sri Jayawardenepura Kotte Post Office',
    'Kadawatha Post Office',
    'Wattala Post Office',
    'Peliyagoda Post Office',
    'Maharagama Post Office',
    'Kottawa Post Office',
    'Homagama Post Office',
    'Kesbewa Post Office',
    'Boralesgamuwa Post Office',
    'Nugegoda Post Office',
    'Avissawella Post Office',
    'Bandarawela Post Office',
    'Hatton Post Office',
    'Balangoda Post Office',
    'Tissamaharama Post Office',
    'Dambulla Post Office',
    'Chilaw Post Office',
    'Panadura Post Office',
    'Horana Post Office',
    'Kalmunai Post Office',
    'Point Pedro Post Office',
    'Valvettithurai Post Office',
  ];

  List<String> _filteredPostOffices = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    _filteredPostOffices = _allPostOffices;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPostOffices(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredPostOffices = _allPostOffices
          .where((postOffice) =>
              postOffice.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredPostOffices = _allPostOffices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.pinkAccent.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 24,
                child: Text(
                  'Find Nearby\nPost Offices',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Image.asset(
                  'assets/post_icon.png',
                  width: 100,
                  height: 100,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          // Search and Content Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.pinkAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchPostOffices,
                            decoration: const InputDecoration(
                              hintText: 'Search post offices...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        if (_isSearching)
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.pinkAccent),
                            onPressed: _clearSearch,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Results Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredPostOffices.length} Post Offices Found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Filter/sort functionality
                          },
                          child: Text(
                            'Sort',
                            style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Post Offices List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredPostOffices.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_post_office,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            title: Text(
                              _filteredPostOffices[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Sri Lanka Postal Service',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.pinkAccent,
                            ),
                            onTap: () {
                              // Handle post office selection
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button for location
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle location-based search
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}