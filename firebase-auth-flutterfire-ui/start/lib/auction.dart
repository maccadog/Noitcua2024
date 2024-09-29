import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage

class AuctionPage extends StatefulWidget {
  const AuctionPage({super.key});

  @override
  _AuctionPageState createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double _sliderValue = 1;
  List<File> _images = [];
  Timer? _timer;

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? pickedImages = await picker.pickMultiImage();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        if (mounted) {
          setState(() {
            _images = pickedImages.map((image) => File(image.path)).toList();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  // Method to submit auction details to Firestore and upload images to Firebase Storage
  Future<void> _submitAuction() async {
    if (_titleController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _images.isNotEmpty) {
      String title = _titleController.text;
      double price = double.tryParse(_priceController.text) ?? 0.0;
      int duration = _sliderValue.toInt();

      // Upload images to Firebase Storage and get URLs
      List<String> imageUrls = await _uploadImagesToStorage();

      // Check if any image URLs were returned
      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images uploaded!')),
        );
        return;
      }

      // Create auction entry in Firestore
      await FirebaseFirestore.instance.collection('auctions').add({
        'title': title,
        'price': price,
        'duration': duration,
        'images': imageUrls, // Store the image URLs
      }).then((value) {
        print('Auction created with ID: ${value.id}'); // Debug log
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auction created successfully!')),
      );

      // Clear fields after submission
      _titleController.clear();
      _priceController.clear();
      setState(() {
        _images = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add at least one image.')),
      );
    }
  }

  // Method to upload images to Firebase Storage and get their URLs
  Future<List<String>> _uploadImagesToStorage() async {
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName = image.path.split('/').last;
      try {
        // Upload the file to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('auction_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(image);

        // Monitor the upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print('Uploading ${snapshot.bytesTransferred} of ${snapshot.totalBytes} bytes');
        });

        // Get the download URL after the file is uploaded
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
        print('Uploaded image URL: $downloadUrl'); // Debug log
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
    return imageUrls;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Auction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title of Listing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter the title of your item',
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Price of Listing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter the price you wish to sell for',
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Auction Duration (days)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _sliderValue,
                min: 1,
                max: 30,
                divisions: 29,
                label: '${_sliderValue.round()} days',
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _sliderValue = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Upload Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Select Images'),
              ),
              const SizedBox(height: 16),

              _images.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              _images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    )
                  : const Text('No images selected'),
              const SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  onPressed: _submitAuction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Submit Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
