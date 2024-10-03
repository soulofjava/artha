// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ResetDataPage extends StatelessWidget {
  // Table name from KeuanganHelper
  static final _tableName = 'keuangan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Data'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Show confirmation dialog
            bool confirmed = await _showConfirmationDialog(context);

            // If user confirms, reset the data
            if (confirmed) {
              await resetTableData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data Reset Successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text('Reset Data'),
        ),
      ),
    );
  }

  // Function to initialize the SQLite database
  Future<Database> _initializeDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'Keuangan.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        // Create a table for the imported data
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            catatan TEXT,
            uangmasuk REAL,
            uangkeluar REAL,
            saldo REAL
          )
        ''');
      },
      version: 1,
    );
  }

  // Function to reset the keuangan table
  Future<void> resetTableData() async {
    final db = await _initializeDb();
    await db.delete(_tableName);
    print('All data in $_tableName table has been deleted.');
  }

  // Function to show confirmation dialog
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This will delete all data in the keuangan table.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm
                child: Text('Yes, Reset'),
              ),
            ],
          ),
        ) ??
        false; // If dialog is dismissed, return false
  }
}
