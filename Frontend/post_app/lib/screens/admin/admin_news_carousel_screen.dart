import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminNewsCarouselScreen extends StatefulWidget {
  const AdminNewsCarouselScreen({super.key});

  @override
  State<AdminNewsCarouselScreen> createState() =>
      _AdminNewsCarouselScreenState();
}

class _AdminNewsCarouselScreenState extends State<AdminNewsCarouselScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('news_images/$fileName');
      String url;
      if (kIsWeb) {
        // For web, upload as bytes
        final bytes = await pickedFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        // For mobile/desktop, upload as file
        final file = File(pickedFile.path);
        await ref.putFile(file);
      }
      url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('news_carousel')
          .add({'imageUrl': url, 'timestamp': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String docId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('news_carousel')
          .doc(docId)
          .delete();
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage News Carousel'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Upload 3 News Images for Carousel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('news_carousel')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DocumentSnapshot> docs =
                      snapshot.hasData ? snapshot.data!.docs : [];
                  // Always show 3 boxes, fill with images if available
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      String? imageUrl;
                      String? docId;
                      if (index < docs.length) {
                        imageUrl = docs[index]['imageUrl'] as String?;
                        docId = docs[index].id;
                      }
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: GestureDetector(
                            onTap: _isUploading
                                ? null
                                : () async {
                                    if (imageUrl == null) {
                                      await _pickAndUploadImageForIndex(
                                          index, docs);
                                    }
                                  },
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.pinkAccent,
                                  width: 2,
                                ),
                              ),
                              child: imageUrl != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            size: 40)),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: _isUploading
                                                ? null
                                                : () => _deleteImage(
                                                    docId!, imageUrl!),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: _isUploading
                                          ? const CircularProgressIndicator()
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.pinkAccent),
                                                SizedBox(height: 8),
                                                Text('Add Image',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.pinkAccent)),
                                              ],
                                            ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
                'Tap a box to add or replace an image. Only 3 images will be shown in the carousel.'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImageForIndex(
      int index, List<DocumentSnapshot> docs) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('news_images/$fileName');
      String url;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        final file = File(pickedFile.path);
        await ref.putFile(file);
      }
      url = await ref.getDownloadURL();
      // If already 3 images, replace the one at this index
      if (docs.length == 3) {
        // Delete old image from storage
        final oldDoc = docs[index];
        final oldUrl = oldDoc['imageUrl'] as String;
        final oldRef = FirebaseStorage.instance.refFromURL(oldUrl);
        await oldRef.delete();
        await FirebaseFirestore.instance
            .collection('news_carousel')
            .doc(oldDoc.id)
            .update(
                {'imageUrl': url, 'timestamp': FieldValue.serverTimestamp()});
      } else {
        await FirebaseFirestore.instance
            .collection('news_carousel')
            .add({'imageUrl': url, 'timestamp': FieldValue.serverTimestamp()});
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
