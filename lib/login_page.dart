import 'package:flutter/material.dart';
import 'package:artha/register_page.dart'; // Pastikan untuk mengimpor halaman Register
import 'package:shared_preferences/shared_preferences.dart';
import 'DB/database_helper.dart';
import 'models/user.dart';
import 'home.dart'; // Import halaman home

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedIn(); // Cek status login saat halaman diinisialisasi
  }

  Future<void> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false; // Ambil status login
    if (isLoggedIn) {
      // Jika sudah login, arahkan ke halaman Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
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
      // Simpan status login di SharedPreferences
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
      backgroundColor: Color(0xFFE8F5E9), // Warna latar belakang hijau muda
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menambahkan gambar logo
              Image.asset(
                'lib/images/logo.jpg',
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              // Judul Halaman
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C), // Warna hijau gelap
                ),
              ),
              SizedBox(height: 20),
              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF388E3C)), // Hijau gelap saat fokus
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF388E3C)), // Hijau gelap saat fokus
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shadowColor:
                      Color(0xFF4CAF50).withOpacity(0.5), // Warna bayangan
                  elevation: 8, // Menambahkan bayangan untuk efek kedalaman
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Color(0xFF4CAF50)), // Border hijau
                  ),
                ),
              ),
              SizedBox(height: 10), // Jarak antara tombol dan tautan register
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
                  style: TextStyle(
                      color: Color(0xFF388E3C)), // Hijau gelap untuk teks
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
