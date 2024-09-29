import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'auction.dart'; // Import the auction page

// Main Function to Initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(), // Updated to use HomeScreen as the main page
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noitcua App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      }),
                    ],
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/flutterfire_300x.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to Noitcua!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ReverseAuctionHomePage(), // Embedded the auction page here
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionItem extends StatefulWidget {
  final int initialTime;
  final double initialPrice;
  final String imageUrl;
  final String productName;

  const AuctionItem({
    super.key,
    required this.initialTime,
    required this.initialPrice,
    required this.imageUrl,
    required this.productName,
  });

  @override
  _AuctionItemState createState() => _AuctionItemState();
}

class _AuctionItemState extends State<AuctionItem> {
  late int _timeLeft;
  late double _price;
  bool _isHovering = false;
  Timer? _timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    _price = widget.initialPrice;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && _price > 0) {
        setState(() {
          _timeLeft--;
          _price = (_price - 0.5).clamp(0.0, double.infinity); // Ensure price doesn't go below zero
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/placeholder.png'); // Placeholder image in case of network error
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (_isHovering)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Time left: $_timeLeft seconds',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Current price: \$${_price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReverseAuctionHomePage extends StatelessWidget {
  const ReverseAuctionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Featured Listings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AuctionList(), // Displays the list of auctions
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuctionPage()), // Navigate to the auction page
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Make an auction'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionList extends StatelessWidget {
  const AuctionList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var auctionListings = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: auctionListings.length,
          itemBuilder: (context, index) {
            var auction = auctionListings[index].data() as Map<String, dynamic>;

            // Safeguard: Check if 'images' field exists and is not empty
            List<dynamic>? images = auction['images'] as List<dynamic>?;
            String imageUrl = images != null && images.isNotEmpty 
              ? images[0] 
              : 'assets/placeholder.png'; // Fallback to local placeholder if no images

            return AuctionItem(
              initialTime: auction['duration'].toInt(), // Auction duration in seconds
              initialPrice: auction['price'].toDouble(), // Auction starting price
              imageUrl: imageUrl, // Safe image URL with fallback
              productName: auction['title'], // Product name
            );
          },
        );
      },
    );
  }
}
