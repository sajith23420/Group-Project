import 'package:flutter/material.dart';
import 'package:post_app/services/api_client.dart';
import 'package:post_app/services/mail_api_service.dart';
import 'package:post_app/models/mail_model.dart'; // Assuming MailModel is used for parcels
import 'package:post_app/services/token_provider.dart'; // Import TokenProvider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ParcelTrackingScreen extends StatefulWidget {
  const ParcelTrackingScreen({super.key});

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  final TextEditingController _nicController = TextEditingController();
  late final TokenProvider _tokenProvider;
  late final ApiClient _apiClient;
  late final MailApiService _mailApiService;
  List<MailModel> _parcels = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tokenProvider = TokenProvider(FirebaseAuth.instance);
    _apiClient = ApiClient(_tokenProvider);
    _mailApiService = MailApiService(_apiClient);
  }

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  Future<void> _trackParcel() async {
    final nic = _nicController.text.trim();
    if (nic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your NIC number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetchedParcels = await _mailApiService.getParcelsByNic(nic);
      setState(() {
        _parcels = fetchedParcels;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching parcels: ${e.toString()}';
        _parcels = [];
      });
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
        title: const Text('Parcel Tracking'),
        backgroundColor: Colors.red, // Changed to red
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Track Your Parcel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Changed to red
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _nicController,
              decoration: InputDecoration(
                labelText: 'Enter your NIC Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: const Icon(Icons.search,
                    color: Colors.red), // Changed to red
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _trackParcel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Changed to red
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Track Parcel',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20.0),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            if (!_isLoading && _error == null && _parcels.isNotEmpty)
              ..._parcels.map((parcel) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parcel ID: ${parcel.mailId}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                              'Status: ${parcel.status.toString().split('.').last}'),
                          Text('Sender: ${parcel.senderName}'),
                          Text('Receiver: ${parcel.receiverName}'),
                          Text('Address: ${parcel.receiverAddress}'),
                          Text('Weight: ${parcel.weight} kg'),
                          Text('Created At: ${parcel.createdAt.toLocal()}'),
                          Text('Updated At: ${parcel.updatedAt.toLocal()}'),
                        ],
                      ),
                    ),
                  )),
            if (!_isLoading && _error == null && _parcels.isEmpty)
              const Center(
                child: Text(
                  'No parcels found for the provided NIC.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
