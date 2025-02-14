// ignore_for_file: prefer_const_constructors

import 'package:artha/DB/keuangan_helper.dart';
import 'package:artha/widgets/InfoCard.dart';
import 'package:artha/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import 'monthly_totals_chart.dart'; // Import the chart file

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  Map<String, double> monthlyTotals = {};
  final KeuanganHelper _keuanganHelper = KeuanganHelper.instance;

  // List of months and selected month
  List<String> months = [];
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    _getUsername();
    _fetchUniqueMonths(); // Fetch unique months from the database
  }

  // Get current month in 'YYYY-MM' format
  String getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // Fetch the unique months and update the state
  Future<void> _fetchUniqueMonths() async {
    List<String> dbMonths = await _keuanganHelper.getUniqueMonths();
    setState(() {
      months = dbMonths;
      String currentMonth = getCurrentMonth();

      // Set default selected month to the current month if available in the list
      if (months.contains(currentMonth)) {
        selectedMonth = currentMonth;
      } else if (months.isNotEmpty) {
        selectedMonth = months[
            0]; // Fall back to the first month if current month is not in the list
      }

      // Display totals for the selected month
      if (selectedMonth != null) {
        _displayMonthlyTotals(selectedMonth!);
      }
    });
  }

  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username =
          prefs.getString('username'); // Get username from SharedPreferences
    });
  }

  Future<void> _displayMonthlyTotals(String month) async {
    // Periksa apakah 'month' valid (contoh: '2024-12')
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(month)) {
      throw FormatException('Invalid month format: $month');
    }

    // Ambil data bulan saat ini
    List<Map<String, dynamic>> monthlyData =
        await _keuanganHelper.totalByMonth(month);

    // Ambil data bulan lalu
    DateTime selectedDate = DateTime.parse('$month-01'); // Format yang valid
    DateTime lastMonthDate = DateTime(
      selectedDate.year,
      selectedDate.month - 1,
    );

    String lastMonth =
        '${lastMonthDate.year}-${lastMonthDate.month.toString().padLeft(2, '0')}';

    List<Map<String, dynamic>> lastMonthData =
        await _keuanganHelper.totalByMonth(lastMonth);

    setState(() {
      if (monthlyData.isNotEmpty) {
        monthlyTotals = {
          'uangmasuk': monthlyData[0]['totalUangMasuk'] ?? 0.0,
          'uangkeluar': monthlyData[0]['totalUangKeluar'] ?? 0.0,
        };
      } else {
        monthlyTotals = {'uangmasuk': 0.0, 'uangkeluar': 0.0};
      }

      if (lastMonthData.isNotEmpty) {
        monthlyTotals['saldoLalu'] =
            (lastMonthData[0]['totalUangMasuk'] ?? 0.0) -
                (lastMonthData[0]['totalUangKeluar'] ?? 0.0);
      } else {
        monthlyTotals['saldoLalu'] = 0.0;
      }
    });
  }

// Function to format the month from 'YYYY-MM' to 'Month'
  String formatSelectedMonth(String month) {
    final parts = month.split('-');
    final monthNumber = int.parse(parts[1]);
    return DateFormat('MMMM')
        .format(DateTime(0, monthNumber)); // Get month name
  }

  // Function to format currency
  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(amount);
  }

  // Function to convert month format from 'YYYY-MM' to 'Month YYYY'
  String formatMonth(String month) {
    final parts = month.split('-');
    final year = parts[0];
    final monthNumber = int.parse(parts[1]);
    final monthName =
        DateFormat('MMMM').format(DateTime(0, monthNumber)); // Get month name
    return '$monthName $year'; // Return in 'Month YYYY' format
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove login status
    await prefs.remove('username'); // Remove username

    // Navigate to login page and clear all previous routes
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigate to login page
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
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Call logout function if confirmed
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Function to reload the data
  void _reloadData() {
    _fetchUniqueMonths(); // Refresh the unique months
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Reload icon
            onPressed: _reloadData, // Call reload function
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout, // Show logout confirmation
          ),
        ],
      ),
      drawer: AppDrawer(), // Use the new AppDrawer widget
      body: SingleChildScrollView(
        child: Center(
          child: username != null
              ? Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Add padding around the content
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Add the MonthlyTotalsChart widget above the dropdown
                      MonthlyTotalsChart(), // No data passed to the chart

                      SizedBox(height: 15),

                      // Month selection dropdown inside a Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedMonth,
                            hint: Text('Pilih Bulan'),
                            items: months.map((String month) {
                              return DropdownMenuItem<String>(
                                value: month,
                                child: Text(formatMonth(
                                    month)), // Display month in 'Month Year' format
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              // Set the new value and call _displayMonthlyTotals
                              setState(() {
                                selectedMonth = newValue;
                              });

                              // Fetch data for the selected month
                              if (newValue != null) {
                                await _displayMonthlyTotals(newValue);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      InfoCard(
                        title: 'Saldo Akhir Bulan Lalu',
                        value: formatCurrency(monthlyTotals['saldoLalu'] ?? 0),
                        titleColor: Colors.blue,
                        valueColor: Colors.blue,
                      ),
                      SizedBox(height: 15),

                      InfoCard(
                        title:
                            'Total Pemasukan ${selectedMonth != null ? formatSelectedMonth(selectedMonth!) : 'N/A'}',
                        value: formatCurrency(monthlyTotals['uangmasuk'] ?? 0),
                        titleColor: Colors.green,
                        valueColor: Colors.green,
                      ),
                      SizedBox(height: 15),

                      InfoCard(
                        title:
                            'Total Pengeluaran ${selectedMonth != null ? formatSelectedMonth(selectedMonth!) : 'N/A'}',
                        value: formatCurrency(monthlyTotals['uangkeluar'] ?? 0),
                        titleColor: Colors.red,
                        valueColor: Colors.red,
                      ),
                      SizedBox(height: 15),

                      InfoCard(
                        title:
                            'Saldo ${selectedMonth != null ? formatSelectedMonth(selectedMonth!) : 'N/A'}',
                        value: formatCurrency(
                          (monthlyTotals['saldoLalu'] ?? 0) +
                              (monthlyTotals['uangmasuk'] ?? 0) -
                              (monthlyTotals['uangkeluar'] ?? 0),
                        ),
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(), // Show loader while username is loading
        ),
      ),
    );
  }
}
