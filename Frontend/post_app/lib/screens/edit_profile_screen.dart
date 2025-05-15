import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Uncomment and add dependency for image picking
// import 'dart:io'; // Uncomment for File

class EditProfileScreen extends StatefulWidget { // Changed to StatefulWidget
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> { // Added State class
  // GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();
  // File? _pickedImage; // State variable to hold the picked image

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Or .camera
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       _pickedImage = File(pickedFile.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      // backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null, // Use picked image
                      backgroundColor: Colors.grey[300], // Placeholder background
                      child: // _pickedImage == null ?
                          const Icon(Icons.person, size: 60, color: Colors.grey), // Fallback icon
                          // : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // _pickImage(); // Call image picker function
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image picker functionality not implemented yet')),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                // Initial value can be set here if you have user data
                // initialValue: 'User Name',
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                // initialValue: 'user.email@example.com',
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                // initial value: '+94 ...',
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                // initialValue: 'User Address',
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // if (_formKey.currentState!.validate()) {
                  //   // Save profile changes
                  // }
                },
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
