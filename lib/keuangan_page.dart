// lib/keuangan_page.dart
import 'package:flutter/material.dart';

class KeuanganPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan'),
      ),
      body: Center(
        child: Text(
          'Ini adalah halaman Keuangan',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
