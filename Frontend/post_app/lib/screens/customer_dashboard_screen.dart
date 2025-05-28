import 'package:flutter/material.dart';
import 'package:post_app/screens/parcel_tracking_screen.dart';
import 'package:post_app/screens/money_order_screen.dart';
import 'package:post_app/screens/bill_payments_screen.dart';
import 'package:post_app/screens/search_post_office_screen.dart';
import 'package:post_app/screens/fines_screen.dart';
import 'package:post_app/screens/login_screen.dart';
import 'package:post_app/screens/feedbacks_page.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:post_app/providers/user_provider.dart'; // Import UserProvider
import 'package:post_app/models/user_model.dart'; // Import UserModel
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:post_app/screens/postal_holiday_screen.dart'; // Import PostalHolidayScreen
// For logout

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _greeting = '';
  // String? _userName; // Will be replaced by UserProvider
  final PageController _newsPageController = PageController();
  int _currentNewsPage = 0;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    // _fetchUserName(); // No longer needed, UserProvider will supply user data
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour == 12) {
      _greeting = 'Good Afternoon';
    } else if (hour < 18) {
      _greeting = 'Good Evening';
    } else {
      _greeting = 'Good Evening';
    }
  }

  // void _fetchUserName() async { // No longer needed
  //   setState(() {
  //     _userName = 'User';
  //   });
  // }

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? currentUser = userProvider.user;

    // DEBUG: Print user info
    print('DEBUG: currentUser.email = \\${currentUser?.email}');
    print(
        'DEBUG: currentUser.profilePictureUrl = \\${currentUser?.profilePictureUrl}');

    final List<Map<String, dynamic>> services = [
      {'title': 'Parcel Tracking', 'icon': Icons.local_shipping},
      {'title': 'Money Order', 'icon': Icons.attach_money},
      {'title': 'Bill Payments', 'icon': Icons.payment},
      {'title': 'Search Nearby\nPost Office', 'icon': Icons.location_on},
      {'title': 'Fines', 'icon': Icons.gavel},
      {'title': 'Postal Holiday', 'icon': Icons.hotel},
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.pinkAccent,
            title: Row(
              children: [
                Image.asset("assets/post_icon.png", height: 40),
                const SizedBox(width: 10),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.displayName ??
                  "User Name"), // Use displayName from provider
              accountEmail: Text(currentUser?.email ??
                  "user.email@example.com"), // Use email from provider
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                child: (currentUser?.profilePictureUrl != null &&
                        currentUser!.profilePictureUrl!.isNotEmpty)
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: currentUser.profilePictureUrl!
                                  .startsWith('http')
                              ? currentUser.profilePictureUrl!
                              : getFullImageUrl(currentUser.profilePictureUrl),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                              Icons.account_circle,
                              size: 70,
                              color: Colors.grey[400]),
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      )
                    : (currentUser?.email != null &&
                            currentUser!.email!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(currentUser.email!)}&background=F48FB1&color=fff&size=140',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 70,
                            color: Colors.grey[400],
                          )),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to EditProfileScreen - Assuming MyProfileScreen handles this or direct navigation
                Navigator.pushNamed(context,
                    '/my_profile'); // Or directly to edit if MyProfileScreen is not the hub
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Add Payment Card'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Add Payment Card screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to a general settings screen if different from NotificationSettingsScreen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log Out'),
              onTap: () async {
                // Make onPressed async
                Navigator.pop(context); // Close drawer
                // Clear UserProvider
                Provider.of<UserProvider>(context, listen: false).clearUser();

                // TODO: Implement actual Firebase logout logic if not handled by clearing provider and navigating
                // await FirebaseAuth.instance.signOut(); // Example if using Firebase Auth directly for signout

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'SansSerif',
                color: Color.fromARGB(255, 0, 0, 0), // Set to #FFD500
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/post1.jpeg",
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Overlay for gradient effect (optional, for text readability)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Greeting and name (bottom left)
                  Positioned(
                    left: 16,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser?.displayName ??
                              "User", // Use displayName from provider
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Weather icon and temperature (top right)
                  Positioned(
                    top: 12,
                    right: 18,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.cloud,
                              color: Colors.grey, size: 22),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "32°C",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  context,
                  services[index]['title'] as String,
                  services[index]['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Latest News',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 180,
              child: PageView(
                controller: _newsPageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentNewsPage = page;
                  });
                },
                children: const [
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: AssetImage('assets/news1.jpg'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: AssetImage('assets/news2.png'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: AssetImage('assets/news3.jpg'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentNewsPage == index
                        ? Colors.pinkAccent
                        : Colors.white,
                  ),
                );
              }),
            ),
            // Feedback button moved to the bottom
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.feedback,
                    color: Colors.white), // Icon color white
                label: const Text('Give Feedback',
                    style: TextStyle(color: Colors.white)), // Text color white
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.pinkAccent, // Button background pinkAccent
                  side: const BorderSide(color: Colors.pinkAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbacksPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    Widget? screen;
    String normalizedTitle = title.replaceAll('\n', ' ');

    Color iconColor;
    switch (normalizedTitle) {
      case 'Parcel Tracking':
        screen = const ParcelTrackingScreen();
        iconColor = Colors.blue; // Home
        break;
      case 'Money Order':
        screen = const MoneyOrderScreen();
        iconColor = Colors.green; // About
        break;
      case 'Bill Payments':
        screen = const BillPaymentsScreen();
        iconColor = Colors.orange; // Notifications
        break;
      case 'Postal Holiday':
        screen = const PostalHolidayScreen();
        iconColor = Colors.blue;
        break;
      case 'Search Nearby Post Office':
        screen = const SearchPostOfficeScreen();
        iconColor = Colors.teal; // Custom
        break;
      case 'Fines':
        screen = const FinesScreen();
        iconColor = Colors.red; // Custom
        break;
      // Removed: case 'Stamp Collection': ...
      default:
        iconColor = Theme.of(context).primaryColor;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen!),
            );
          }
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to fetch news images from Firestore

  String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Replace with your actual backend base URL
    return 'http://localhost:3000$url';
  }
}
