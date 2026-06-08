import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';
import 'admin.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String message = "";
  String _selectedType = 'user';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String store = _storeController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        (_selectedType == 'admin' && store.isEmpty)) {
      setState(() => message = "Please fill all required fields.");
      return;
    }

    var url = Uri.parse('http://192.168.43.73/projetmobdev/signup.php');

 //var url = Uri.parse('http://192.168.1.10/projetmobdev/signup.php');
  
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
        'type': _selectedType,
        if (_selectedType == 'admin') 'store': store,
      },
    );

    print("Response body: ${response.body}");

    var data = jsonDecode(response.body);

    if (data['error'] == false) {
      if (_selectedType == 'admin') {
        print(store);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen(store: store)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Shopping')),
        );
      }
    } else {
      setState(() => message = data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Sign Up",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (message.isNotEmpty)
                  Text(message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email",
                    hintText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: "Password",
                    hintText: "Enter your password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: ['user', 'admin'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedType == 'admin')
                  TextFormField(
                    controller: _storeController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.store),
                      labelText: "Store Name",
                      hintText: "e.g., MusicStore or BookStore",
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _signUp,
                    child:
                        const Text("Sign Up", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
