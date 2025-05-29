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

  final List<Map<String, dynamic>> _addedServices = [];

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Add New Service',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Service Name'),
                    onChanged: (value) => newServiceName = value,
                  ),
                  const SizedBox(height: 14),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                  ),
                  onPressed: () {
                    if (newServiceName.trim().isNotEmpty &&
                        selectedIconName != null) {
                      setState(() {
                        _addedServices.add({
                          'title': newServiceName.trim(),
                          'icon': selectedIconName,
                        });
                      });
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

  void _deleteService(int index, bool isOriginal) {
    if (!isOriginal) {
      setState(() {
        _addedServices.removeAt(index - _originalServices.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allServices = [..._originalServices, ..._addedServices];
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text('Manage Services',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceDialog,
        backgroundColor: Colors.blue[400],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New Service',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Services',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                itemCount: allServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final service = allServices[index];
                  final iconData = iconMap[service['icon']] ?? Icons.extension;
                  final isOriginal = index < _originalServices.length;
                  return Card(
                    color: Colors.blue[50],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.13),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Icon(iconData,
                                    size: 38, color: Colors.blue[700]),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                service['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isOriginal)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 22),
                              tooltip: 'Delete Service',
                              onPressed: () =>
                                  _deleteService(index, isOriginal),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'You can add or delete your own services. Default services cannot be deleted.',
                style: TextStyle(color: Colors.blue[300], fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
