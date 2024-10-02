import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Import file_picker package
import 'DB/keuangan_helper.dart'; // Import your database helper file
import 'package:artha/models/m_keuangan.dart'; // Ensure to import your Keuangan model
import 'package:path/path.dart'; // Import the path package for join function

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final KeuanganHelper databaseHelper = KeuanganHelper.instance;

  bool _isLoading = false; // Track export status
  String _message = ''; // Variable to hold messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Data'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator while exporting
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _exportToExcel,
                    child: Text('Export to Excel'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  ), // Display message
                ],
              ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _message = ''; // Clear previous message
    });

    try {
      // Retrieve all records as a List<Map<String, dynamic>> and map them to List<Keuangan>
      List<Map<String, dynamic>> recordsMap =
          await databaseHelper.queryAllRows();
      List<Keuangan> records =
          recordsMap.map((record) => Keuangan.fromMap(record)).toList();

      // Create a new Excel document
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // Add headers to the sheet
      sheet.appendRow(
          ['ID', 'Tanggal', 'Catatan', 'Uang Masuk', 'Uang Keluar', 'Saldo']);

      // Add data from records to the sheet
      for (var record in records) {
        sheet.appendRow([
          record.id,
          record.tanggal,
          record.catatan,
          record.uangMasuk,
          record.uangKeluar,
          (record.uangMasuk ?? 0) -
              (record.uangKeluar ??
                  0), // Ensure non-null values for calculations
        ]);
      }

      // Use FilePicker to let the user pick the directory to save the file
      String? outputDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select the location to save the Excel file',
      );

      if (outputDirectory != null) {
        String filePath = join(outputDirectory, 'exported_data.xlsx');

        // Save the Excel file
        List<int>? fileBytes = excel.save();
        if (fileBytes != null && fileBytes.isNotEmpty) {
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

          // Update message to indicate success
          setState(() {
            _message = 'Data exported to $filePath';
          });
        } else {
          // Update message to indicate failure
          setState(() {
            _message = 'Failed to export data';
          });
        }
      } else {
        // Update message if no directory was selected
        setState(() {
          _message = 'No directory selected';
        });
      }
    } catch (e) {
      // Update message to indicate an error occurred
      setState(() {
        _message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
}
