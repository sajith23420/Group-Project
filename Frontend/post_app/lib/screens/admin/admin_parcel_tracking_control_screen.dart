import 'package:flutter/material.dart';
import 'package:post_app/services/mail_api_service.dart';
import 'package:post_app/models/mail_model.dart';
import 'package:post_app/models/enums.dart';
import 'package:post_app/services/api_client.dart';
import 'package:post_app/services/token_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminParcelTrackingControlScreen extends StatefulWidget {
  const AdminParcelTrackingControlScreen({super.key});

  @override
  State<AdminParcelTrackingControlScreen> createState() =>
      _AdminParcelTrackingControlScreenState();
}

class _AdminParcelTrackingControlScreenState
    extends State<AdminParcelTrackingControlScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final MailApiService _mailApiService;
  List<MailModel> _parcels = [];
  List<MailModel> _allParcels = []; // Store all parcels for search reset
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final tokenProvider = TokenProvider(FirebaseAuth.instance);
    final apiClient = ApiClient(tokenProvider);
    _mailApiService = MailApiService(apiClient);
    _fetchAllParcels();
  }

  Future<void> _fetchAllParcels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final parcels = await _mailApiService.adminGetAllMails();
      setState(() {
        _allParcels = parcels;
        _parcels = parcels;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load parcels.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchParcel() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _parcels = _allParcels;
      });
      return;
    }
    setState(() {
      _parcels = _allParcels.where((p) => p.mailId.contains(query)).toList();
    });
  }

  Future<void> _updateParcelStatus(
      MailModel parcel, ParcelStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _mailApiService.adminUpdateMailStatus(
        parcel.mailId,
        AdminUpdateMailStatusRequest(status: newStatus),
      );
      await _fetchAllParcels();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated for ${parcel.mailId}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100], // Light yellow theme
        title: const Text('Parcel Tracking Control',
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Tracking Number',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchParcel,
                      ),
                    ),
                    onSubmitted: (_) => _searchParcel(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchAllParcels,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red))),
            if (!_isLoading && _error == null)
              Expanded(
                child: _parcels.isEmpty
                    ? const Center(child: Text('No parcels found.'))
                    : ListView.separated(
                        itemCount: _parcels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final parcel = _parcels[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tracking #: ${parcel.mailId}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Chip(
                                        label: Text(parcel.status
                                            .toString()
                                            .split('.')
                                            .last),
                                        backgroundColor: Colors.blue.shade50,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Sender: ${parcel.senderName}'),
                                  Text('Receiver: ${parcel.receiverName}'),
                                  Text('Address: ${parcel.receiverAddress}'),
                                  Text('Weight: ${parcel.weight} kg'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Update Status:'),
                                          const SizedBox(width: 8),
                                          DropdownButton<ParcelStatus>(
                                            value: parcel.status,
                                            items: ParcelStatus.values
                                                .map((status) {
                                              return DropdownMenuItem(
                                                value: status,
                                                child: Text(status
                                                    .toString()
                                                    .split('.')
                                                    .last),
                                              );
                                            }).toList(),
                                            onChanged: (newStatus) {
                                              if (newStatus != null &&
                                                  newStatus != parcel.status) {
                                                _updateParcelStatus(
                                                    parcel, newStatus);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Delete Parcel',
                                        onPressed: () =>
                                            _confirmDeleteParcel(parcel),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        onPressed: _showAddParcelDialog,
        tooltip: 'Add Parcel',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddParcelDialog() {
    final userIdController = TextEditingController();
    final senderNameController = TextEditingController();
    final receiverNameController = TextEditingController();
    final receiverAddressController = TextEditingController();
    final weightController = TextEditingController();
    final receiverEmailController =
        TextEditingController(); // Add email controller

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Parcel'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: senderNameController,
                  decoration: const InputDecoration(hintText: 'Sender Name'),
                ),
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(hintText: 'Receiver NIC'),
                ),
                TextField(
                  controller: receiverNameController,
                  decoration: const InputDecoration(hintText: 'Receiver Name'),
                ),
                TextField(
                  controller: receiverAddressController,
                  decoration:
                      const InputDecoration(hintText: 'Receiver Address'),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(hintText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  // Add email text field
                  controller: receiverEmailController,
                  decoration: const InputDecoration(hintText: 'Receiver Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addParcel(
                  userIdController.text,
                  senderNameController.text,
                  receiverNameController.text,
                  receiverAddressController.text,
                  double.tryParse(weightController.text) ?? 0.0,
                  receiverEmailController.text, // Pass email
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addParcel(
    String userId,
    String senderName,
    String receiverName,
    String receiverAddress,
    double weight,
    String receiverEmail, // Add email parameter
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final request = CreateMailRequest(
        userId: userId,
        senderName: senderName,
        receiverName: receiverName,
        receiverAddress: receiverAddress,
        weight: weight,
        receiverEmail: receiverEmail, // Add email to request
      );
      final response = await _mailApiService.createMail(request);
      await _fetchAllParcels(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Parcel added with Tracking #: ${response.mail.mailId}')),
      );

      // Save parcel details to Firebase Firestore
      await FirebaseFirestore.instance
          .collection('parcels')
          .doc(response.mail.mailId)
          .set({
        'mailId': response.mail.mailId,
        'userId': userId,
        'senderName': senderName,
        'receiverName': receiverName,
        'receiverAddress': receiverAddress,
        'weight': weight,
        'receiverEmail': receiverEmail,
        'status': response.mail.status.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        // Send tracking email
        final emailRequest = SendTrackingEmailRequest(
          recipientEmail: receiverEmail,
          trackingNumber: response.mail.mailId,
          receiverName: receiverName,
          senderName: senderName,
        );
        await _mailApiService.sendTrackingEmail(emailRequest);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tracking email sent to $receiverEmail')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send tracking email.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add parcel: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeleteParcel(MailModel parcel) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete parcel ${parcel.mailId}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteParcel(parcel.mailId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteParcel(String mailId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Implement actual API call to delete parcel
      await _mailApiService.deleteParcel(mailId);
      await _fetchAllParcels(); // Refresh the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parcel $mailId deleted successfully.')),
      );
    } catch (e) {
      // Display the specific error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete parcel: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
