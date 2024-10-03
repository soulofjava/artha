// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ImportPage extends StatelessWidget {
  // Table and column names from KeuanganHelper
  static final _tableName = 'keuangan';
  static final _columnId = 'id';
  static final _columnTanggal = 'tanggal';
  static final _columnCatatan = 'catatan';
  static final _columnUangMasuk = 'uangmasuk';
  static final _columnUangKeluar = 'uangkeluar';
  static final _columnSaldo = 'saldo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Data'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Pick the Excel file
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx'],
            );

            if (result != null) {
              File file = File(result.files.single.path!);
              // Load and parse the Excel file
              var bytes = file.readAsBytesSync();
              var excel = Excel.decodeBytes(bytes);

              // Assuming data is in the first sheet
              var sheet = excel.sheets[excel.sheets.keys.first]!;

              // Skip the first and last rows
              for (int i = 1; i < sheet.rows.length - 1; i++) {
                var row = sheet.rows[i];

                // Ensure all cells have values before inserting to database
                if (row.length >= 5) {
                  String tanggal = row[0]?.value?.toString() ?? '';
                  String catatan = row[1]?.value?.toString() ?? '';
                  double uangMasuk =
                      double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0;
                  double uangKeluar =
                      double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;
                  double saldo = uangMasuk - uangKeluar;

                  // Insert the data to SQLite database
                  await insertDataToDatabase(
                      tanggal, catatan, uangMasuk, uangKeluar, saldo);
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data Imported Successfully')),
              );
            }
          },
          child: Text('Import Data'),
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
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnTanggal TEXT NOT NULL,
            $_columnCatatan TEXT,
            $_columnUangMasuk REAL,
            $_columnUangKeluar REAL,
            $_columnSaldo REAL
          )
        ''');
      },
      version: 1,
    );
  }

  // Function to insert data into the keuangan table
  Future<void> insertDataToDatabase(String tanggal, String catatan,
      double uangMasuk, double uangKeluar, double saldo) async {
    final db = await _initializeDb();
    await db.insert(
      _tableName,
      {
        _columnTanggal: tanggal,
        _columnCatatan: catatan,
        _columnUangMasuk: uangMasuk,
        _columnUangKeluar: uangKeluar,
        _columnSaldo: saldo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
