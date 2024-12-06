// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:artha/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'DB/database_helper.dart';
import 'models/user.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _showFingerprintButton = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn(); // Check login status at initialization
  }

  Future<void> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Check if biometric authentication is possible
      bool canAuthenticate = await auth.canCheckBiometrics;
      setState(() {
        _showFingerprintButton =
            canAuthenticate; // Show button if biometrics are available
      });

      // If already logged in, optionally perform auto-authentication
      bool isAuthenticated = await _authenticateWithFingerprint();
      if (isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  // Method for fingerprint authentication
  Future<bool> _authenticateWithFingerprint() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isAuthenticated = false;

    if (canCheckBiometrics) {
      try {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Gunakan sidik jari untuk masuk',
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );
      } catch (e) {
        print(e);
      }
    }
    return isAuthenticated;
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Username dan Password harus diisi!',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dbHelper = DatabaseHelper();
    User? user = await dbHelper.getUser(
      _usernameController.text,
      _passwordController.text,
    );

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', user.username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Invalid Credentials!',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/images/logo.jpg',
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF388E3C)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF388E3C)),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shadowColor: Color(0xFF4CAF50).withOpacity(0.5),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Color(0xFF4CAF50)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Show fingerprint button if the user is already logged in and biometrics are available
              if (_showFingerprintButton)
                ElevatedButton.icon(
                  onPressed: () async {
                    bool isAuthenticated = await _authenticateWithFingerprint();
                    if (isAuthenticated) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  },
                  icon: Icon(Icons.fingerprint),
                  label: Text('Masuk dengan Sidik Jari'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50),
                    shadowColor: Color(0xFF4CAF50).withOpacity(0.5),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(),
                    ),
                  );
                },
                child: Text(
                  'Belum punya akun? Daftar',
                  style: TextStyle(color: Color(0xFF388E3C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
