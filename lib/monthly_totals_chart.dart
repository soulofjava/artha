import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:artha/DB/keuangan_helper.dart';

class MonthlyTotalsChart extends StatefulWidget {
  @override
  _MonthlyTotalsChartState createState() => _MonthlyTotalsChartState();
}

class _MonthlyTotalsChartState extends State<MonthlyTotalsChart> {
  final KeuanganHelper _keuanganHelper = KeuanganHelper.instance;
  List<double> monthlyIncome =
      List.filled(12, 0); // Initialize with 0 for each month
  List<double> monthlyExpenses =
      List.filled(12, 0); // Initialize with 0 for each month

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    // Fetch monthly totals from the database and update state
    for (int month = 1; month <= 12; month++) {
      String monthStr = month < 10 ? '0$month' : '$month';
      String yearMonth = '${DateTime.now().year}-$monthStr';
      List<Map<String, dynamic>> monthlyData =
          await _keuanganHelper.totalByMonth(yearMonth);

      if (monthlyData.isNotEmpty) {
        monthlyIncome[month - 1] = monthlyData[0]['totalUangMasuk'] ?? 0.0;
        monthlyExpenses[month - 1] = monthlyData[0]['totalUangKeluar'] ?? 0.0;
      }
    }

    setState(() {}); // Trigger a rebuild with the fetched data
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 250, // Height of the chart
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Jan');
                    case 1:
                      return Text('Feb');
                    case 2:
                      return Text('Mar');
                    case 3:
                      return Text('Apr');
                    case 4:
                      return Text('May');
                    case 5:
                      return Text('Jun');
                    case 6:
                      return Text('Jul');
                    case 7:
                      return Text('Aug');
                    case 8:
                      return Text('Sep');
                    case 9:
                      return Text('Oct');
                    case 10:
                      return Text('Nov');
                    case 11:
                      return Text('Dec');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(monthlyIncome.length, (index) {
                return FlSpot(index.toDouble(), monthlyIncome[index]);
              }),
              isCurved: true,
              color: Colors.green,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: List.generate(monthlyExpenses.length, (index) {
                return FlSpot(index.toDouble(), monthlyExpenses[index]);
              }),
              isCurved: true,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
