import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class ShopScreen extends StatelessWidget {
  ShopScreen({super.key});

  final List<Map<String, String>> products = [
    {
      'name': 'Herbal Supplement',
      'image': 'assets/images/supplement.png',
      'description': 'Boosts immunity and balances energy.',
    },
    {
      'name': 'Detox Smoothie',
      'image': 'assets/images/smoothie.png',
      'description': 'Cleanses the liver and revitalizes the body.',
    },
    {
      'name': 'Healing Herbs',
      'image': 'assets/images/herbs.png',
      'description': 'Hand-picked herbs for natural healing.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(children: [
          // Background parchment image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
            ),
          ),

          // Content
          Column(
            children: [
              Lottie.asset(
                'assets/animations/shop_nature.json',
                height: 160,
                fit: BoxFit.contain,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      color: Colors.yellow.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Image.asset(
                          product['image']!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          product['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Besom',
                          ),
                        ),
                        subtitle: Text(
                          product['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Besom',
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: medicalColors['primary'],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Add to cart or show detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("${product['name']} added to cart!"),
                              ),
                            );
                          },
                          child: const Text('Buy'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          //shoping basket
          Positioned(
            bottom: 80,
            right: 48,
            child: GestureDetector(
              onTap: () {
                // Navigate to cart or checkout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Feature is unavailable now..."),
                  ),
                );
              },
              child: Column(
                children: [
                  Image.asset('assets/images/basket.png',
                      width: 80, height: 80, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  Text(
                    'Shopping Basket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Besom',
                      color: Colors.brown.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
