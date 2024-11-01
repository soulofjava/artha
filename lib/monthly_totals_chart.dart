import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:artha/DB/keuangan_helper.dart';
import 'package:intl/intl.dart';

class MonthlyTotalsChart extends StatefulWidget {
  @override
  _MonthlyTotalsChartState createState() => _MonthlyTotalsChartState();
}

class _MonthlyTotalsChartState extends State<MonthlyTotalsChart> {
  final KeuanganHelper _keuanganHelper = KeuanganHelper.instance;
  List<double> monthlyIncome = [];
  List<double> monthlyExpenses = [];

  // Static list of abbreviated month names
  final List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    // Initialize income and expenses lists
    monthlyIncome = List.filled(12, 0); // One for each month
    monthlyExpenses = List.filled(12, 0); // One for each month

    // Fetch totals for each month from SQLite
    for (int month = 1; month <= 12; month++) {
      String monthStr = month < 10 ? '0$month' : '$month';
      String yearMonth =
          '${DateTime.now().year}-$monthStr'; // Assuming this year's data
      List<Map<String, dynamic>> monthlyData =
          await _keuanganHelper.totalByMonth(yearMonth);

      if (monthlyData.isNotEmpty) {
        monthlyIncome[month - 1] = monthlyData[0]['totalUangMasuk'] ?? 0.0;
        monthlyExpenses[month - 1] = monthlyData[0]['totalUangKeluar'] ?? 0.0;
      }
    }

    setState(() {}); // Trigger a rebuild with the fetched data
  }

  // Function to format currency in Rupiah
  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 300, // Height of the chart
      child: Column(
        children: [
          // Title showing the current year
          Text(
            '${DateTime.now().year}', // Display current year
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10), // Spacing between title and chart
          Expanded(
            // Make chart take remaining space
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < monthNames.length) {
                          return RotatedBox(
                            quarterTurns: 1, // Rotate labels
                            child: Text(monthNames[index],
                                style: TextStyle(
                                    fontSize: 10)), // Adjust font size
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Hide vertical labels
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false), // Disable grid lines
                borderData: FlBorderData(show: true),
                minY: 0, // Set the minimum Y value
                maxY: 15000000, // Set the maximum Y value to 15 million
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(monthlyIncome.length, (index) {
                      return FlSpot(index.toDouble(), monthlyIncome[index]);
                    }),
                    isCurved: true,
                    color: Colors.green,
                    dotData: FlDotData(show: false), // Hide dots
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(monthlyExpenses.length, (index) {
                      return FlSpot(index.toDouble(), monthlyExpenses[index]);
                    }),
                    isCurved: true,
                    color: Colors.red,
                    dotData: FlDotData(show: false), // Hide dots
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // Display formatted currency for totals below the chart
          Text(
              'Total Uang Masuk ${DateTime.now().year}: ${formatCurrency(monthlyIncome.reduce((a, b) => a + b))}'),
          Text(
              'Total Uang Keluar ${DateTime.now().year}: ${formatCurrency(monthlyExpenses.reduce((a, b) => a + b))}'),
        ],
      ),
    );
  }
}
