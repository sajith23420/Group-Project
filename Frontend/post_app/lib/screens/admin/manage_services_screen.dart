import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  // The 6 original services (cannot be deleted)
  final List<Map<String, dynamic>> _originalServices = const [
    {'title': 'Parcel Tracking', 'icon': 'local_shipping'},
    {'title': 'Money Order', 'icon': 'attach_money'},
    {'title': 'Bill Payments', 'icon': 'payment'},
    {'title': 'Postal Holiday', 'icon': 'calendar_today'},
    {'title': 'Search Nearby Post Office', 'icon': 'location_on'},
    {'title': 'Fines', 'icon': 'gavel'},
  ];

  List<Map<String, dynamic>> _addedServices = [];
  bool _isLoading = false;

  // Icon mapping
  static const Map<String, IconData> iconMap = {
    'local_shipping': Icons.local_shipping,
    'attach_money': Icons.attach_money,
    'payment': Icons.payment,
    'calendar_today': Icons.calendar_today,
    'location_on': Icons.location_on,
    'gavel': Icons.gavel,
    'star': Icons.star,
    'mail': Icons.mail,
    'home': Icons.home,
    'settings': Icons.settings,
    'favorite': Icons.favorite,
    'directions_bus': Icons.directions_bus,
    'cake': Icons.cake,
    'wifi': Icons.wifi,
    'security': Icons.security,
    'book': Icons.book,
  };

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();
    final allDocs = snapshot.docs.map((doc) => doc.data()).toList();
    // Filter out originals
    _addedServices = allDocs
        .where((s) => !_originalServices.any((o) => o['title'] == s['title']))
        .toList();
    setState(() => _isLoading = false);
  }

  Future<void> _addService(String title, String iconName) async {
    await FirebaseFirestore.instance
        .collection('services')
        .add({'title': title, 'icon': iconName});
    await _fetchServices();
  }

  Future<void> _deleteService(String title) async {
    setState(() => _isLoading = true);
    final query = await FirebaseFirestore.instance
        .collection('services')
        .where('title', isEqualTo: title)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    // Remove from local list immediately for instant UI feedback
    setState(() {
      _addedServices.removeWhere((s) => s['title'] == title);
      _isLoading = false;
    });
    // Optionally, you can call _fetchServices() here if you want to re-sync from Firestore
    // await _fetchServices();
  }

  void _showAddServiceDialog() {
    String newServiceName = '';
    String? selectedIconName;
    final icons = [
      'star',
      'mail',
      'home',
      'settings',
      'favorite',
      'directions_bus',
      'cake',
      'wifi',
      'security',
      'book',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Service'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Service Name'),
                    onChanged: (value) => newServiceName = value,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: icons.map((iconName) {
                      return ChoiceChip(
                        label: Icon(iconMap[iconName]),
                        selected: selectedIconName == iconName,
                        onSelected: (_) {
                          setStateDialog(() {
                            selectedIconName = iconName;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newServiceName.trim().isNotEmpty &&
                        selectedIconName != null) {
                      await _addService(
                          newServiceName.trim(), selectedIconName!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: const Text('Manage Services',
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: Colors.purple[400],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Service',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Services',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount:
                          _originalServices.length + _addedServices.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        final bool isOriginal =
                            index < _originalServices.length;
                        final service = isOriginal
                            ? _originalServices[index]
                            : _addedServices[index - _originalServices.length];
                        final iconData =
                            iconMap[service['icon']] ?? Icons.extension;
                        return Card(
                          color: isOriginal ? Colors.purple[50] : Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(iconData,
                                        size: 40, color: Colors.purple[400]),
                                    const SizedBox(height: 12),
                                    Text(
                                      service['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOriginal)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.lock,
                                      color: Colors.grey, size: 20),
                                )
                              else
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 22),
                                    onPressed: () async {
                                      await _deleteService(service['title']);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tap the + button to add a new service.',
                      style: TextStyle(color: Colors.purple[300]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
