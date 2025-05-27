import 'package:flutter/material.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  // The 6 original services (cannot be deleted)
  final List<Map<String, dynamic>> _originalServices = const [
    {'title': 'Parcel Tracking', 'icon': Icons.local_shipping},
    {'title': 'Money Order', 'icon': Icons.attach_money},
    {'title': 'Bill Payments', 'icon': Icons.payment},
    {'title': 'Postal Holiday', 'icon': Icons.calendar_today},
    {'title': 'Search Nearby Post Office', 'icon': Icons.location_on},
    {'title': 'Fines', 'icon': Icons.gavel},
  ];

  // Admin-added services (can be deleted)
  final List<Map<String, dynamic>> _addedServices = [];

  void _showAddServiceDialog() {
    String newServiceName = '';
    IconData? selectedIcon;
    final icons = [
      Icons.star,
      Icons.mail,
      Icons.home,
      Icons.settings,
      Icons.favorite,
      Icons.directions_bus,
      Icons.cake,
      Icons.wifi,
      Icons.security,
      Icons.book,
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Service Name'),
                onChanged: (value) => newServiceName = value,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: icons.map((icon) {
                  return ChoiceChip(
                    label: Icon(icon),
                    selected: selectedIcon == icon,
                    onSelected: (_) {
                      setState(() {
                        selectedIcon = icon;
                      });
                      // Rebuild dialog
                      Navigator.of(context).pop();
                      _showAddServiceDialog();
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
              onPressed: () {
                if (newServiceName.trim().isNotEmpty && selectedIcon != null) {
                  setState(() {
                    _addedServices.add({
                      'title': newServiceName.trim(),
                      'icon': selectedIcon,
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
  }

  @override
  Widget build(BuildContext context) {
    final allServices = [..._originalServices, ..._addedServices];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100], // Light purple theme
        title: const Text('Manage Services',
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: Colors.purple[200],
        child: const Icon(Icons.add, color: Colors.black),
        tooltip: 'Add Service',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allServices.length,
        itemBuilder: (context, index) {
          final service = allServices[index];
          final isOriginal = index < _originalServices.length;
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(service['icon'], color: Colors.purple[400]),
              title: Text(service['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: isOriginal
                  ? const Icon(Icons.lock, color: Colors.grey, size: 20)
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _addedServices
                              .removeAt(index - _originalServices.length);
                        });
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
