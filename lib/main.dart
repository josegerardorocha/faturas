import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web App',
      theme: ThemeData(
        primaryColor: const Color(0xFF04AA6D),
        scaffoldBackgroundColor: const Color(0xFFF1F1F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF04AA6D),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ---------------- LOGIN PAGE ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _loading = false;

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      var url = Uri.parse('backend/login.php');
      var response =
          await http.post(url, body: {'username': username, 'password': password});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainMenuPage()),
          );
        } else {
          setState(() => _errorMessage = 'Invalid username or password');
        }
      } else {
        setState(() => _errorMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1), // light grey site background
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white, // white box like W3Schools examples
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF04AA6D), // W3Schools green
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF04AA6D), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF04AA6D), width: 2),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04AA6D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
