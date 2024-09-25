import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:start/auction.dart';
import 'firebase_options.dart';

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
      home: HomeScreen(), // Updated to use HomeScreen as the main page
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    _price = widget.initialPrice;
    Timer.periodic(const Duration(seconds: 1), (timer) {
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Current price: \$${_price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
  final List<Map<String, dynamic>> products = [
    {
      'name': '1987 Honda Accord',
      'initialPrice': 5000.0,
      'initialTime': 3600,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0MXwvD6nDU43UjWGT3tYESlnzwQxO87TH-Q&s',
    },
    {
      'name': 'Kids Jeans',
      'initialPrice': 300.0,
      'initialTime': 1800,
      'imageUrl': 'https://www.kidrepublic.co.nz/user/images/85908.jpg',
    },
    {
      'name': 'HP Laptop',
      'initialPrice': 8000.0,
      'initialTime': 7200,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ98O8WMdb_VjGK56F6N8FLgIbD-G81qcnVQw&s',
    },
    {
      'name': 'Nike Air Force 1',
      'initialPrice': 200.0,
      'initialTime': 3600,
      'imageUrl': 'https://asnovel.de/cdn/shop/products/SBBSale.jpg?v=1637874889',
    },
    {
      'name': 'Tesla Model S',
      'initialPrice': 10000.0,
      'initialTime': 10800,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuGhwhyGPU-e_Ns13u10W8M-JWDiPV5uahpg&s',
    },
    {
      'name': 'RayBand Sunglasses',
      'initialPrice': 500.0,
      'initialTime': 5400,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRj4Dm1ENmrHn_XsX8HLwWAUAjT5gXWgWDTnA&s',
    },
  ];

  ReverseAuctionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noitcua'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Featured listings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return AuctionItem(
                    initialTime: products[index]['initialTime'],
                    initialPrice: products[index]['initialPrice'],
                    imageUrl: products[index]['imageUrl'],
                    productName: products[index]['name'],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuctionPage(AuctionPage)), // Ensure this points to your AuctionPage
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

// aseihjfiwghwiuhgqoihoh