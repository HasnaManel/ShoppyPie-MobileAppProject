import 'package:flutter/material.dart';
import 'signIn.dart';
import 'adminMusicStore.dart';
import 'adminBookStore.dart';

class AdminScreen extends StatelessWidget {
  final String store;
  const AdminScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    Widget? storeWidget;
    if (store.toLowerCase() == 'musicstore') {
      storeWidget = AdminMusicStore();
    } else if (store.toLowerCase() == 'bookstore') {
      storeWidget = AdminBookStore();
    } else {
      storeWidget = const Center(child: Text("Unknown store"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: storeWidget,
      ),
    );
  }
}
