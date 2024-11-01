import 'package:artha/keuangan_page.dart';
import 'package:artha/import_page.dart';
import 'package:flutter/material.dart';
import 'package:artha/export_page.dart';
import 'package:artha/reset_data_page.dart';
import 'package:artha/user_page.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFE8F5E9), // Light green background for drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50), // Dark green color for header
              ),
              child: Center(
                child: Image.asset(
                  'lib/images/logo.jpg', // Replace with your logo image
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance,
                color: Color(0xFF4CAF50), // Green icon for "Keuangan"
              ),
              title: Text('Keuangan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KeuanganPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.import_export,
                color: Color(0xFF4CAF50), // Green icon for Import
              ),
              title: Text('Import Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImportPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.file_download,
                color: Color(0xFF4CAF50), // Green icon for Export
              ),
              title: Text('Export Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExportPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.restart_alt,
                color: Color(0xFF4CAF50), // Green icon for Reset Data
              ),
              title: Text('Reset Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetDataPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Color(0xFF4CAF50), // Green icon for User
              ),
              title: Text('Pengguna'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
