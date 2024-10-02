import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'DB/keuangan_helper.dart';
import 'package:path/path.dart';
import 'models/keuangan.dart';
class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final KeuanganHelper databaseHelper = KeuanganHelper.instance;

  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Data'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Exporting data...'),
                ],
              )
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
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Retrieve all records
      List<Map<String, dynamic>> recordsMap =
          await databaseHelper.queryAllRows();

      // Print the raw map data
      print('Records Map: $recordsMap');

      List<Keuangan> records =
          recordsMap.map((record) => Keuangan.fromMap(record)).toList();

      // Create a new Excel document
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // Add headers to the sheet
      sheet.appendRow(
          ['ID', 'Tanggal', 'Catatan', 'Uang Masuk', 'Uang Keluar', 'Saldo']);

      for (var record in records) {
        // Parse the string values to double

        // Print each record's details, including the calculated saldo
        print(
          'ID: ${record.id}, Tanggal: ${record.tanggal}, Catatan: ${record.catatan}, '
          'Uang Masuk: ${record.uangMasuk}, Uang Keluar: ${record.uangKeluar}, '
          'Saldo: ${record.uangMasuk} - ${record.uangKeluar}',
        );

        // Append row to the sheet
        sheet.appendRow([
          record.id,
          record.tanggal,
          record.catatan,
          record.uangMasuk,
          record.uangKeluar,
          record.uangMasuk - record.uangKeluar,
        ]);
      }

      // Use FilePicker for directory selection
      String? outputDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select the location to save the Excel file',
      );

      if (outputDirectory != null) {
          // Get the current date and time
        DateTime now = DateTime.now();
        String formattedDate = '${now.year}-${now.month}-${now.day}';
        String formattedTime = '${now.hour}-${now.minute}-${now.second}';
        String fileName = 'exported_data_$formattedDate$formattedTime.xlsx';

        String filePath = join(outputDirectory, fileName);


        // Save the Excel file asynchronously
        List<int>? fileBytes = excel.save();
        if (fileBytes != null && fileBytes.isNotEmpty) {
          await File(filePath)
            ..create(recursive: true)
            ..writeAsBytes(fileBytes);

          // Show success message
          setState(() {
            _message = 'Data exported to $filePath';
          });
        } else {
          // Show failure message
          setState(() {
            _message = 'Failed to export data';
          });
        }
      } else {
        setState(() {
          _message = 'No directory selected';
        });
      }
    } catch (e) {
      print('Error: $e'); // Log error for debugging
      setState(() {
        _message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
