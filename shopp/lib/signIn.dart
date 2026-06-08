import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';
import 'admin.dart';
import 'signUp.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String message = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => message = "Please fill all fields.");
      return;
    }

    var url = Uri.parse('http://192.168.43.73/projetmobdev/login.php');

     //var url = Uri.parse('http://192.168.1.10/projetmobdev/login.php');

    
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password
      }, // Make sure the keys are 'email' and 'password'
    );

    print("Response body: ${response.body}");

    var data = jsonDecode(response.body);

    if (data['error'] == false) {
      ref.read(userIdProvider.notifier).state =
          int.parse(data['id'].toString());
      String userType = data['type'].toString().toLowerCase();

      if (userType == 'admin') {
        var store = data['store'];
        print("Store from backend: '${data['store']}'");

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AdminScreen(store: store)));
      } else {
        Navigator.push(
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
                const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your email'
                      : null,
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your password'
                      : null,
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
                    onPressed: _signIn,
                    child: const Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
