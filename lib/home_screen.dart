import 'package:flutter/material.dart';

import '/basket_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text("Home Screen", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          // Navigate to the basket list screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BasketListScreen(),
            ),
          );
        },
        child: const Text("Go to the basket list screen"),
      )),
    );
  }
}
