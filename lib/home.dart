// lib/home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Import halaman login
import 'keuangan_page.dart'; // Import halaman keuangan
import 'user_page.dart'; // Import halaman user

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username =
          prefs.getString('username'); // Ambil username dari SharedPreferences
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Hapus status login
    await prefs.remove('username'); // Hapus username

    // Navigasi ke halaman login dan hapus semua halaman sebelumnya
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Kembali ke halaman login
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Panggil fungsi logout jika pengguna memilih untuk logout
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed:
                _confirmLogout, // Panggil fungsi konfirmasi logout saat tombol ditekan
          ),
        ],
      ),
      drawer: Drawer(
        // Tambahkan drawer untuk sidebar menu
        child: Container(
          color: Colors.blue[50], // Warna latar belakang drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue, // Warna latar belakang header
                ),
                child: Center(
                  // Mengatur teks agar berada di tengah
                  child: Text(
                    'Artha', // Ganti tulisan menjadi "Artha"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_balance,
                    color: Colors.blue), // Ikon untuk Keuangan
                title: Text('Keuangan'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            KeuanganPage()), // Navigasi ke halaman keuangan
                  );
                },
              ),
              Divider(), // Pemisah antara item menu
              ListTile(
                leading:
                    Icon(Icons.person, color: Colors.blue), // Ikon untuk User
                title: Text('User'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserPage()), // Navigasi ke halaman user
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: username != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, $username!', // Tampilkan nama pengguna
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                ],
              )
            : CircularProgressIndicator(), // Tampilkan loader saat memuat username
      ),
    );
  }
}
