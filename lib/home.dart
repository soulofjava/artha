// ignore_for_file: prefer_const_constructors

import 'package:artha/reset_data_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Import halaman login
import 'keuangan_page.dart'; // Import halaman keuangan
import 'user_page.dart'; // Import halaman pengguna (dari user_page.dart)
import 'import_page.dart'; // Import halaman import
import 'export_page.dart'; // Import halaman export

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
          color:
              Color(0xFFE8F5E9), // Warna latar belakang hijau muda untuk drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50), // Warna hijau gelap untuk header
                ),
                child: Center(
                  child: Image.asset(
                    'lib/images/logo.jpg', // Ganti teks dengan gambar logo
                    height: 80, // Atur tinggi gambar sesuai kebutuhan
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance,
                  color: Color(0xFF4CAF50), // Warna ikon untuk Keuangan
                ),
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
                leading: Icon(
                  Icons.import_export,
                  color: Color(0xFF4CAF50), // Warna ikon untuk Import
                ),
                title: Text('Import Data'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ImportPage()), // Navigasi ke halaman import
                  );
                },
              ),
              Divider(), // Pemisah antara item menu
              ListTile(
                leading: Icon(
                  Icons.file_download,
                  color: Color(0xFF4CAF50), // Warna ikon untuk Export
                ),
                title: Text('Export Data'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExportPage()), // Navigasi ke halaman export
                  );
                },
              ),
              Divider(), // Pemisah antara item menu
              ListTile(
                leading: Icon(
                  Icons.restart_alt,
                  color: Color(0xFF4CAF50), // Warna ikon untuk Export
                ),
                title: Text('Reset Data'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ResetDataPage()), // Navigasi ke halaman export
                  );
                },
              ),
              Divider(), // Pemisah antara item menu
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Color(0xFF4CAF50), // Warna ikon untuk Pengguna
                ),
                title: Text('Pengguna'), // Mengganti 'User' menjadi 'Pengguna'
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserPage()), // Navigasi ke halaman pengguna
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
