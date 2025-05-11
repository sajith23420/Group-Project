import 'package:flutter/material.dart';
import 'dart:async'; // For PageController and Timer if needed for auto-scroll

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  String _greeting = '';
  final PageController _newsPageController = PageController();
  int _currentNewsPage = 0;
  final int _newsImageCount = 3; // Number of images in the carousel

  @override
  void initState() {
    super.initState();
    _setGreeting();
    // Optional: Auto-scroll for news carousel
    // Timer.periodic(const Duration(seconds: 5), (Timer timer) {
    //   if (_currentNewsPage < _newsImageCount - 1) {
    //     _currentNewsPage++;
    //   } else {
    //     _currentNewsPage = 0;
    //   }
    //   if (_newsPageController.hasClients) {
    //     _newsPageController.animateToPage(
    //       _currentNewsPage,
    //       duration: const Duration(milliseconds: 350),
    //       curve: Curves.easeIn,
    //     );
    //   }
    // });
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour == 12) { // 12:00 PM to 12:59 PM
      _greeting = 'Good Afternoon';
    } else if (hour < 18) { // 1:00 PM (13:00) to 5:59 PM (17:59)
      _greeting = 'Good Evening';
    } else { // 6:00 PM (18:00) onwards
      _greeting = 'Good Night';
    }
  }

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the services based on the new request
    final List<Map<String, dynamic>> services = [
      {'title': 'Parcel Tracking', 'icon': Icons.local_shipping},
      {'title': 'Money Order', 'icon': Icons.attach_money},
      {'title': 'Bill Payments', 'icon': Icons.payment},
      {'title': 'Postal Holiday', 'icon': Icons.calendar_today},
      {'title': 'Search Nearby\nPost Office', 'icon': Icons.location_on}, // Added \n for better fit
      {'title': 'Fines', 'icon': Icons.gavel},
      {'title': 'Stamp Collection', 'icon': Icons.collections_bookmark},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SL Post'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Handle profile icon tap
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Image and Greeting
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100], // Changed color for better visibility
                  borderRadius: BorderRadius.circular(12),
                  // You can add an image here later:
                  // image: DecorationImage(
                  //   image: AssetImage('assets/your_header_image.png'), // Add your image to assets
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Center(
                  child: Text(
                    '$_greeting, User Name!\n(Header Image Placeholder)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Services Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.9, // Adjusted for potentially taller text due to '\n'
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return _buildServiceGridItem(
                    context,
                    services[index]['title'] as String,
                    services[index]['icon'] as IconData,
                  );
                },
              ),
              const SizedBox(height: 24.0),

              // Latest News Carousel
              const Text(
                'Latest News',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 150, // Adjust height as needed for your images
                child: PageView.builder(
                  controller: _newsPageController,
                  itemCount: _newsImageCount,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentNewsPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    // Replace with your actual image widgets
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.7),
                        ),
                        child: Center(
                          child: Text(
                            'News Image ${index + 1}',
                            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dot indicators for news carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_newsImageCount, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentNewsPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGridItem(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          // Handle service item tap for 'title'
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 36.0, color: Theme.of(context).primaryColor), // Slightly smaller icon
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // Padding for text
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.0), // Slightly smaller font
                maxLines: 2, // Allow for two lines for "Search Nearby Post Office"
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
