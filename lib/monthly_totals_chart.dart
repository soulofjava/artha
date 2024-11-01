import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyTotalsChart extends StatelessWidget {
  final List<double> monthlyIncome; // List of monthly income values
  final List<double> monthlyExpenses; // List of monthly expense values

  MonthlyTotalsChart(
      {required this.monthlyIncome, required this.monthlyExpenses});

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
